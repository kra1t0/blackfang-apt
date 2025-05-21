#!/bin/bash

# ========================
# APT Repo Signer Script
# Author: Kra1t (Janindu)
# Description: Signs APT repo Release files and generates GPG artifacts
# ========================

# === CONFIGURATION ===
REPO_DIR="$(pwd)" # Path to the root of your APT repo
DIST="stable"
KEY_ID="9D670521FCBFDDB0698FEA4C79888DF31565EE8D" # Change this to your actual GPG key ID or email

# === Paths ===
DIST_DIR="$REPO_DIR/dists/$DIST"
RELEASE_FILE="$DIST_DIR/Release"
RELEASE_GPG_FILE="$DIST_DIR/Release.gpg"
INRELEASE_FILE="$DIST_DIR/InRelease"
PACKAGES_DIR="$DIST_DIR/main/binary-all"
POOL_DIR="$REPO_DIR/pool"

# === Step 1: Generate Packages.gz ===
echo "[*] Generating Packages.gz from pool..."
dpkg-scanpackages "$POOL_DIR" /dev/null | gzip -9c > "$PACKAGES_DIR/Packages.gz"

# === Step 2: Generate Release file ===
echo "[*] Generating Release file..."
apt-ftparchive release "$DIST_DIR" > "$RELEASE_FILE"

# === Step 3: Sign Release file ===
echo "[*] Signing Release file with GPG key: $KEY_ID"
gpg --default-key "$KEY_ID" --output "$RELEASE_GPG_FILE" -ba "$RELEASE_FILE"
gpg --default-key "$KEY_ID" --output "$INRELEASE_FILE" -abs "$RELEASE_FILE"

# === Step 4: Export GPG public key (for users to trust) ===
echo "[*] Exporting GPG public key..."
gpg --armor --output "$REPO_DIR/blackfang.gpg" --export "$KEY_ID"

# === Done ===
echo "[+] Repo signing complete. Upload the updated files to GitHub."
echo "  - $RELEASE_FILE"
echo "  - $RELEASE_GPG_FILE"
echo "  - $INRELEASE_FILE"
echo "  - blackfang.gpg"

