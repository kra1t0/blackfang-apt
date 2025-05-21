#!/bin/bash

# Constants
REPO_DIR="$(pwd)/dists/stable"
KEY_ID="9D670521FCBFDDB0698FEA4C79888DF31565EE8D"  # Replace with your GPG key ID or email

# Check if gpg key exists
gpg --list-keys "$KEY_ID" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "[!] GPG key not found: $KEY_ID"
  exit 1
fi

# Step 1: Generate Release file (make sure it exists)
if [ ! -f "$REPO_DIR/Release" ]; then
  echo "[!] Release file not found at $REPO_DIR/Release"
  exit 1
fi

# Step 2: Sign the Release file
cd "$REPO_DIR" || exit 1

# Clear old signatures if they exist
rm -f Release.gpg InRelease

# Detached signature (Release.gpg)
gpg --default-key "$KEY_ID" \
    --output Release.gpg \
    --detach-sign \
    --yes \
    --batch \
    Release

# Inline clear-signed signature (InRelease)
gpg --default-key "$KEY_ID" \
    --output InRelease \
    --clearsign \
    --yes \
    --batch \
    Release

# Step 3: Export public key (optional for clients to trust)
gpg --armor --export "$KEY_ID" > "$REPO_DIR/blackfang.gpg"

# Done
echo "[+] Signing complete. Upload the following to your APT repo root:"
echo "  - dists/stable/Release"
echo "  - dists/stable/Release.gpg"
echo "  - dists/stable/InRelease"
echo "  - dists/stable/blackfang.gpg (optional public key for users)"

