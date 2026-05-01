#!/bin/bash

FILE=$1
RECIPIENT=$2
PUBKEY=$3

if [ -z "$FILE" ] || [ -z "$RECIPIENT" ] || [ -z "$PUBKEY" ]; then
    echo "Usage: ./send.sh <file> <user@host> <public_key>"
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "File not found!"
    exit 1
fi

echo "Generating checksum..."
CHECKSUM=$(shasum -a 256 "$FILE" | awk '{print $1}')
echo "Checksum: $CHECKSUM"

echo "Encrypting file..."
age -r "$PUBKEY" -o "$FILE.age" "$FILE" || {
    echo "Encryption failed!"
    exit 1
}

echo "Transferring file..."
scp "$FILE.age" "$RECIPIENT:~/" || {
    echo "Transfer failed!"
    exit 1
}

echo "$(date) | $(whoami) | $RECIPIENT | $FILE | sha256:$CHECKSUM | SUCCESS" >> transfer.log

echo "Done."
