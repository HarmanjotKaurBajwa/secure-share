#!/bin/bash

echo "Setting up SSH..."

mkdir -p ~/.ssh
chmod 700 ~/.ssh

if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
fi

# Avoid duplicate entries
grep -q "$(cat ~/.ssh/id_ed25519.pub)" ~/.ssh/authorized_keys 2>/dev/null || \
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys

chmod 600 ~/.ssh/authorized_keys

eval "$(ssh-agent -s)" >/dev/null
ssh-add ~/.ssh/id_ed25519 >/dev/null 2>&1

echo "SSH ready."

echo "Setting up AGE keys..."

if [ ! -f key.txt ]; then
    age-keygen -o key.txt
    echo "AGE key generated."
else
    echo "AGE key already exists. Skipping generation."
fi

echo "Your public key:"
grep "public key" key.txt

echo "Setup complete."
