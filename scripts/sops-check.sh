#!/bin/bash

# Configuration can be set in repository's local .sops-config
CONFIG_FILE=".sops-config"
DEFAULT_SENSITIVE_FILES_LIST=".sops-required-files"

# Default patterns to check (if not gitignored)
DEFAULT_PATTERNS=(
    ".env"
    ".envrc"
    "*.key"
    "secrets.*"
    "credentials.*"
)

# Load custom configuration if available
SENSITIVE_FILES_LIST="$DEFAULT_SENSITIVE_FILES_LIST"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Function to check if a file is gitignored
is_gitignored() {
    local file="$1"
    git check-ignore -q "$file"
    return $?
}

# Function to check if a file is SOPS-encrypted
is_sops_encrypted() {
    local file="$1"

    # Skip check if file doesn't exist
    if [ ! -f "$file" ]; then
        return 0
    fi

    # More robust SOPS detection with different formats (YAML, JSON, ENV)
    if grep -q "sops:" "$file" || grep -q "ENC\[" "$file" || grep -q "encrypted_" "$file"; then
        return 0 # File appears to be encrypted
    else
        return 1 # File is not encrypted
    fi
}

# Function to check if a file matches any of the default patterns
matches_default_pattern() {
    local filepath="$1"
    local basename=$(basename "$filepath")

    for pattern in "${DEFAULT_PATTERNS[@]}"; do
        # Convert glob pattern to regex
        local regex="${pattern//./\\.}" # Escape dots
        regex="${regex//\*/.*}"         # Convert * to .*
        regex="^${regex}$"              # Anchor to start and end
        if [[ $basename =~ $regex ]]; then
            return 0
        fi
    done
    return 1
}

# Function to normalize path
normalize_path() {
    local path="$1"
    # Remove leading ./ if present
    echo "${path#./}"
}

# Track if we found any unencrypted files
UNENCRYPTED_FILES=()

# If specific files are provided as arguments, check only those
if [ $# -gt 0 ]; then
    for filepath in "$@"; do
        # Normalize path
        filepath=$(normalize_path "$filepath")

        # Skip if file is gitignored
        if is_gitignored "$filepath"; then
            continue
        fi

        # Check if file matches default patterns or is in sensitive files list
        if matches_default_pattern "$filepath" || ([ -f "$SENSITIVE_FILES_LIST" ] && grep -q "^$filepath$" "$SENSITIVE_FILES_LIST"); then
            if ! is_sops_encrypted "$filepath"; then
                UNENCRYPTED_FILES+=("$filepath")
            fi
        fi
    done
else
    # Check default patterns first
    for pattern in "${DEFAULT_PATTERNS[@]}"; do
        # Use find to handle globs and check each matching file
        while IFS= read -r -d '' filepath; do
            # Normalize path
            filepath=$(normalize_path "$filepath")

            # Skip gitignored files
            if is_gitignored "$filepath"; then
                continue
            fi

            if ! is_sops_encrypted "$filepath"; then
                UNENCRYPTED_FILES+=("$filepath")
            fi
        done < <(find . -name "$pattern" -type f -print0 2>/dev/null)
    done

    # Check files from sensitive files list if it exists
    if [ -f "$SENSITIVE_FILES_LIST" ]; then
        while IFS= read -r line; do
            # Skip empty lines and comments
            [[ -z "$line" || "$line" =~ ^# ]] && continue

            # Support globs if they're specified
            if [[ "$line" == *"*"* ]]; then
                while IFS= read -r -d '' filepath; do
                    # Normalize path
                    filepath=$(normalize_path "$filepath")

                    if [ -f "$filepath" ] && ! is_gitignored "$filepath" && ! is_sops_encrypted "$filepath"; then
                        UNENCRYPTED_FILES+=("$filepath")
                    fi
                done < <(find . -name "$line" -type f -print0 2>/dev/null)
            else
                # Direct file check
                filepath=$(normalize_path "$line")
                if [ -f "$filepath" ] && ! is_gitignored "$filepath" && ! is_sops_encrypted "$filepath"; then
                    UNENCRYPTED_FILES+=("$filepath")
                fi
            fi
        done <"$SENSITIVE_FILES_LIST"
    fi
fi

# If unencrypted files were found, block the commit
if [ ${#UNENCRYPTED_FILES[@]} -gt 0 ]; then
    echo "ERROR: The following files must be encrypted with SOPS before committing:"
    for file in "${UNENCRYPTED_FILES[@]}"; do
        echo "  - $file"
    done
    echo "Please encrypt these files using 'sops -e -i <file>' and try again."
    exit 1
fi

exit 0
