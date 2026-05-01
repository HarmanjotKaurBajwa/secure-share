#!/bin/bash
# Get input arguments: file, recipient, and public key
FILE=$1
RECIPIENT=$2
PUBKEY=$3
# Check if all required arguments are provided
if [ -z "$FILE" ] || [ -z "$RECIPIENT" ] || [ -z "$PUBKEY" ]; then
    echo "Usage: ./send.sh <file> <user@host> <public_key>"
    exit 1
fi
# Check if the file exists
if [ ! -f "$FILE" ]; then
    echo "File not found!"
    exit 1
fi
# Generate SHA-256 checksum of the original file (for integrity verification)
echo "Generating checksum..."
CHECKSUM=$(shasum -a 256 "$FILE" | awk '{print $1}')
echo "Checksum: $CHECKSUM"
# Encrypt the file using recipient's public key (age encryption)
echo "Encrypting file..."
age -r "$PUBKEY" -o "$FILE.age" "$FILE"
# Check if encryption failed
if [ $? -ne 0 ]; then
    echo "Encryption failed!"
    echo "$(date) | $(whoami) | $RECIPIENT | $FILE | sha256:$CHECKSUM | FAILED (encryption error)" >> transfer.log
    exit 1
fi
# Transfer encrypted file securely using SCP over SSH
echo "Transferring file..."
scp "$FILE.age" "$RECIPIENT:~/" 
# Check if transfer failed
if [ $? -ne 0 ]; then
    echo "Transfer failed!"
    echo "$(date) | $(whoami) | $RECIPIENT | $FILE | sha256:$CHECKSUM | FAILED (transfer error)" >> transfer.log
    exit 1
fi
# Log successful transfer
echo "$(date) | $(whoami) | $RECIPIENT | $FILE | sha256:$CHECKSUM | SUCCESS" >> transfer.log

echo "Done."
