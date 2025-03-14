# SOPS File Encryption Checker

A pre-commit hook to verify that sensitive files are encrypted with [SOPS](https://github.com/mozilla/sops) before being committed.

[![Test SOPS File Encryption Checker](https://github.com/timmyb824/sops-file-encryption-checker/actions/workflows/test.yml/badge.svg)](https://github.com/timmyb824/sops-file-encryption-checker/actions/workflows/test.yml)

## Features

- Checks for unencrypted sensitive files before commit
- Default patterns for common sensitive files (`.env`, `.envrc`, etc.)
- Support for custom patterns via `.sops-required-files`
- Skips gitignored files automatically
- Comprehensive test suite
- Automatic updates via `latest` tag

## Installation

1. Install [pre-commit](https://pre-commit.com/#install)

2. Add this to your `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/timmyb824/sops-file-encryption-checker
    rev: latest # Always use the latest version
    hooks:
      - id: sops-encryption-check
```

3. Install the pre-commit hook:

```bash
pre-commit install
```

## Configuration

### Default Patterns

The following file patterns are checked by default:

- `.env`
- `.envrc`
- `*.key`
- `secrets.*`
- `credentials.*`

### Custom Patterns

Create a `.sops-required-files` file in your repository root to specify additional files or patterns to check:

```text
secrets/production.yaml
*.secret
config/*.key
```

## Development

### Running Tests

```bash
# Make scripts executable
chmod +x scripts/sops-check.sh
chmod +x test/test-sops-check.sh

# Run tests
./test/test-sops-check.sh
```

### GitHub Actions

The project includes a GitHub Actions workflow that:

1. Runs the test suite
2. Verifies the pre-commit hook configuration
3. Tests against the latest version of SOPS
4. Automatically updates the `latest` tag on successful tests

The `latest` tag is automatically updated whenever tests pass on the main branch, ensuring that users always get the most recent working version.

## License

MIT
