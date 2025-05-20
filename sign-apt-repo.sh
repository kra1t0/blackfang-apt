#!/bin/bash

# ==============================================================================
#  APT Repo Signing Script for BlackFang APT
#  -----------------------------------------
#  This script creates Package indexes and signs Release files (Release.gpg + InRelease)
#  for all available architectures in a Debian-style repo.
#  Author: Kra1t | https://github.com/kra1t0/blackfang-apt
# ==============================================================================

set -e

REPO_DIR="$(pwd)"
DIST="stable"
COMPONENT="main"
GPG_KEY_ID="9D670521FCBFDDB0698FEA4C79888DF31565EE8D"  # Replace with your GPG key or email

echo "📁 [INFO] Working in: $REPO_DIR"
echo "🔐 [INFO] Using GPG key: $GPG_KEY_ID"

ARCHS=()

# === Step 1: Find all architectures ===
echo "🔎 [STEP 1] Detecting architectures..."
for arch_dir in "$REPO_DIR/dists/$DIST/$COMPONENT/"binary-*; do
    [ -d "$arch_dir" ] || continue
    arch=$(basename "$arch_dir" | cut -d'-' -f2)
    ARCHS+=("$arch")
    echo "  ✔ Found architecture: $arch"
done

# === Step 2: Generate Packages.gz for each architecture ===
echo "📦 [STEP 2] Generating Packages.gz for architectures..."
for arch in "${ARCHS[@]}"; do
    out_dir="$REPO_DIR/dists/$DIST/$COMPONENT/binary-$arch"
    echo "  ➤ Processing $arch..."
    dpkg-scanpackages -m pool > "$out_dir/Packages"
    gzip -9c "$out_dir/Packages" > "$out_dir/Packages.gz"
    echo "    ✅ Packages.gz created in $out_dir"
done

# === Step 3: Create Release file ===
echo "📝 [STEP 3] Creating Release file..."

RELEASE_FILE="$REPO_DIR/dists/$DIST/Release"
{
    echo "Origin: BlackFang"
    echo "Label: BlackFang APT"
    echo "Suite: $DIST"
    echo "Codename: $DIST"
    echo "Version: 1.0"
    echo -n "Architectures:"
    for arch in "${ARCHS[@]}"; do echo -n " $arch"; done
    echo ""
    echo "Components: $COMPONENT"
    echo "Date: $(date -Ru)"
    echo "Description: APT repo for BlackFang tools"
    echo ""
} > "$RELEASE_FILE"

echo "🔐 Adding hashes to Release file..."
cd "$REPO_DIR/dists/$DIST"

{
    echo "Origin: BlackFang"
    echo "Label: BlackFang APT"
    echo "Suite: $DIST"
    echo "Codename: $DIST"
    echo "Version: 1.0"
    echo -n "Architectures:"
    for arch in "${ARCHS[@]}"; do echo -n " $arch"; done
    echo ""
    echo "Components: $COMPONENT"
    echo "Date: $(date -Ru)"
    echo "Description: APT repo for BlackFang tools"
    echo ""
    
    echo "MD5Sum:"
    find . -type f \( -name "Packages" -o -name "Packages.gz" \) | while read -r file; do
        size=$(stat -c%s "$file")
        md5=$(md5sum "$file" | cut -d' ' -f1)
        printf " %s %d %s\n" "$md5" "$size" "$file"
    done

    echo "SHA256:"
    find . -type f \( -name "Packages" -o -name "Packages.gz" \) | while read -r file; do
        size=$(stat -c%s "$file")
        sha256=$(sha256sum "$file" | cut -d' ' -f1)
        printf " %s %d %s\n" "$sha256" "$size" "$file"
    done
} > Release

cd "$REPO_DIR"

# === Step 4: Sign Release file ===
echo "🔏 [STEP 4] Signing Release file..."
gpg --default-key "$GPG_KEY_ID" --output dists/$DIST/Release.gpg -abs dists/$DIST/Release
gpg --default-key "$GPG_KEY_ID" --output dists/$DIST/InRelease -abs --clearsign dists/$DIST/Release

echo "✅ Repo signing complete!"
echo "📁 Created:"
echo " - dists/$DIST/Release"
echo " - dists/$DIST/Release.gpg"
echo " - dists/$DIST/InRelease"

