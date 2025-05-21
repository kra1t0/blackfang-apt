#!/bin/bash
# Script to GPG-sign APT repo and generate Release files

set -e

# Define paths
REPO_DIR="/path/to/blackfang-apt"
DIST="stable"
ARCHS=("binary-all" "binary-amd64")
KEY_ID="9D670521FCBFDDB0698FEA4C79888DF31565EE8D"

# Change to the repo directory
cd "$REPO_DIR/dists/$DIST"

# Rebuild Packages.gz (optional if packages are updated)
echo "[+] Rebuilding Packages.gz files"
for ARCH in "${ARCHS[@]}"; do
    ARCH_PATH="$REPO_DIR/dists/$DIST/main/$ARCH"
    if [ -d "$ARCH_PATH" ]; then
        echo "  - $ARCH"
        dpkg-scanpackages -m "$REPO_DIR/pool" /dev/null | gzip -9c > "$ARCH_PATH/Packages.gz"
    fi
done

# Generate Release file
echo "[+] Generating Release file"
cat > Release <<EOF
Origin: BlackFang
Label: BlackFang APT
Suite: stable
Version: 1.0
Codename: stable
Date: $(date -Ru)
Architectures: amd64 all
Components: main
Description: Official BlackFang OS APT repository
MD5Sum:
EOF

# Add MD5 hashes
for ARCH in "${ARCHS[@]}"; do
    PKG_FILE="main/$ARCH/Packages.gz"
    [ -f "$PKG_FILE" ] && echo " $(md5sum $PKG_FILE | cut -d' ' -f1) $(wc -c < $PKG_FILE) $PKG_FILE" >> Release
done

# Sign the Release file (detached and clear-signed)
echo "[+] Signing Release file"
gpg --default-key "$KEY_ID" -abs -o Release.gpg Release
gpg --default-key "$KEY_ID" --clearsign -o InRelease Release

# Export public key (optional but recommended)
gpg --armor --export "$KEY_ID" > "$REPO_DIR/blackfang.gpg"

echo "[+] Done. Upload 'InRelease', 'Release.gpg', and 'blackfang.gpg' to GitHub"

# Tip:
# If hosted via GitHub Pages, make sure files are uploaded to:
#   - dists/stable/Release
#   - dists/stable/Release.gpg
#   - dists/stable/InRelease
#   - blackfang.gpg at root or dists/ if preferred

