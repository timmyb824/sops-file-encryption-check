# SOPS File Encryption Checker

A pre-commit hook to verify that sensitive files are encrypted with [SOPS](https://github.com/mozilla/sops) before being committed.

[![Test SOPS File Encryption Checker](https://github.com/timmyb824/sops-file-encryption-check/actions/workflows/test.yml/badge.svg)](https://github.com/timmyb824/sops-file-encryption-check/actions/workflows/test.yml)

## Features

- Checks for unencrypted sensitive files before commit
- Default patterns for common sensitive files (`.env`, `.envrc`, etc.)
- Support for custom patterns via `.sops-required-files`
- Skips gitignored files automatically
- Comprehensive test suite
- Versioned releases; bump with `pre-commit autoupdate`

## Installation

1. Install [pre-commit](https://pre-commit.com/#install)

2. Add this to your `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/timmyb824/sops-file-encryption-check
    rev: v1.0.0 # Use the latest released tag
    hooks:
      - id: sops-encryption-check
```

3. Install the pre-commit hook:

```bash
pre-commit install
```

4. Keep the hook up to date over time:

```bash
pre-commit autoupdate
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

The project runs two workflows:

- **Test** — on every push and pull request: runs the test suite, verifies the
  pre-commit hook configuration, and tests against a pinned version of SOPS.
- **Release Please** — on push to `main`: maintains a release pull request and,
  when it is merged, publishes the release (see below).

### Releasing

Releases are automated with
[Release Please](https://github.com/googleapis/release-please-action) and use
immutable [semver](https://semver.org/) tags (`vMAJOR.MINOR.PATCH`), which is what
pre-commit expects in the `rev` field. Do **not** create or push tags by hand —
that bypasses the changelog and GitHub Release.

To cut a release:

1. Merge changes to `main` using [Conventional Commits](https://www.conventionalcommits.org/)
   (`fix:` → patch, `feat:` → minor, `feat!:` / `BREAKING CHANGE:` → major).
2. Release Please opens (or updates) a `chore(main): release X.Y.Z` pull request
   with the version bump and `CHANGELOG.md` entry.
3. Merge that pull request. Release Please pushes the `vX.Y.Z` tag and creates the
   matching GitHub Release.

Consumers move to a newer release with `pre-commit autoupdate`.

## License

MIT
