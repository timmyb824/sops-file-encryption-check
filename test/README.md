# SOPS Encryption Check Test Files

This directory contains test files for verifying the SOPS encryption check pre-commit hook.

## Test Cases

1. Default patterns (`.env`, `.envrc`, etc.)
2. Custom patterns from `.sops-required-files`
3. Gitignored files (should be skipped)
4. Already encrypted files (should pass)
5. Non-sensitive files (should pass)
