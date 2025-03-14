#!/bin/bash

# Create test directory structure
TEST_DIR="$(dirname "$0")/fixtures"
mkdir -p "$TEST_DIR"

# Create test files
echo "DB_PASSWORD=secret" >"$TEST_DIR/.env"
echo "sops:\n    mac: ABC\nDB_PASSWORD: ENC[AES256_GCM,data=secret]" >"$TEST_DIR/.env.encrypted"
echo "API_KEY=12345" >"$TEST_DIR/secrets.yaml"
echo "test_data" >"$TEST_DIR/normal.txt"

# Create .sops-required-files
echo "test/fixtures/secrets.yaml" >"$TEST_DIR/.sops-required-files"

# Run tests
echo "Running SOPS encryption check tests..."

# Test 1: Unencrypted .env file
echo -e "\nTest 1: Unencrypted .env file"
"$(dirname "$0")/../scripts/sops-check.sh" "$TEST_DIR/.env"
if [ $? -eq 1 ]; then
    echo "✅ Test passed: Detected unencrypted .env file"
else
    echo "❌ Test failed: Did not detect unencrypted .env file"
fi

# Test 2: Encrypted .env file
echo -e "\nTest 2: Encrypted .env file"
"$(dirname "$0")/../scripts/sops-check.sh" "$TEST_DIR/.env.encrypted"
if [ $? -eq 0 ]; then
    echo "✅ Test passed: Accepted encrypted .env file"
else
    echo "❌ Test failed: Rejected encrypted .env file"
fi

# Test 3: Custom pattern from .sops-required-files
echo -e "\nTest 3: Custom pattern from .sops-required-files"
"$(dirname "$0")/../scripts/sops-check.sh" "$TEST_DIR/secrets.yaml"
if [ $? -eq 1 ]; then
    echo "✅ Test passed: Detected unencrypted secrets.yaml file"
else
    echo "❌ Test failed: Did not detect unencrypted secrets.yaml file"
fi

# Test 4: Non-sensitive file
echo -e "\nTest 4: Non-sensitive file"
"$(dirname "$0")/../scripts/sops-check.sh" "$TEST_DIR/normal.txt"
if [ $? -eq 0 ]; then
    echo "✅ Test passed: Accepted non-sensitive file"
else
    echo "❌ Test failed: Rejected non-sensitive file"
fi

# Cleanup
echo -e "\nCleaning up test files..."
rm -rf "$TEST_DIR"

echo -e "\nTests complete!"
