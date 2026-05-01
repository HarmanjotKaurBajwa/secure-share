#!/bin/bash

ENC_FILE=$1
KEY_FILE=$2
EXPECTED_HASH=$3

if [ -z "$ENC_FILE" ] || [ -z "$KEY_FILE" ] || [ -z "$EXPECTED_HASH" ]; then
    echo "Usage: ./receive.sh <encrypted_file> <key_file> <expected_hash>"
    exit 1
fi

OUT_FILE="$(basename "$ENC_FILE" .age).dec"

echo "Decrypting file..."
age -d -i "$KEY_FILE" -o "$OUT_FILE" "$ENC_FILE" || {
    echo "Error: Decryption failed!"
    exit 1
}

echo "Generating checksum..."
ACTUAL_HASH=$(shasum -a 256 "$OUT_FILE" | awk '{print $1}')

echo "Verifying checksum..."
if [ "$ACTUAL_HASH" = "$EXPECTED_HASH" ]; then
    echo "Integrity check PASSED"
else
    echo "Integrity check FAILED"
fi
