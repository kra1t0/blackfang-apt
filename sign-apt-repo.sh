#!/bin/bash

# Set repo variables
REPO_DIR="$(pwd)"
DIST="stable"
COMPONENT="main"
ARCHS=("binary-all" "binary-amd64")
GPG_KEY_ID="YOUR-GPG-KEY-ID-HERE"

echo "[*] Generating Packages and Packages.gz files..."

for ARCH in "${ARCHS[@]}"; do
    TARGET_DIR="$REPO_DIR/dists/$DIST/$COMPONENT/$ARCH"
    if [[ -d "$TARGET_DIR" ]]; then
        echo "    - Processing $ARCH"
        dpkg-scanpackages "$REPO_DIR/pool" /dev/null > "$TARGET_DIR/Packages"
        gzip -kf "$TARGET_DIR/Packages"
    fi
done

echo "[*] Generating Release file with hashes..."

cd "$REPO_DIR/dists/$DIST"

cat > Release <<EOF
Origin: BlackFang
Label: BlackFang APT
Suite: stable
Codename: stable
Architectures: all amd64
Components: main
Description: BlackFang APT Repository
Date: $(date -Ru)
EOF

# Append hash fields for Packages and Packages.gz
{
    echo "MD5Sum:"
    find $COMPONENT -type f \( -name "Packages" -o -name "Packages.gz" \) | while read f; do
        printf " %s %16d %s\n" "$(md5sum < "$f" | cut -d' ' -f1)" "$(stat -c%s "$f")" "$f"
    done

    echo "SHA256:"
    find $COMPONENT -type f \( -name "Packages" -o -name "Packages.gz" \) | while read f; do
        printf " %s %16d %s\n" "$(sha256sum < "$f" | cut -d' ' -f1)" "$(stat -c%s "$f")" "$f"
    done

    echo "SHA512:"
    find $COMPONENT -type f \( -name "Packages" -o -name "Packages.gz" \) | while read f; do
        printf " %s %16d %s\n" "$(sha512sum < "$f" | cut -d' ' -f1)" "$(stat -c%s "$f")" "$f"
    done
} >> Release

echo "[*] Signing Release file..."
gpg --default-key "$GPG_KEY_ID" -abs -o Release.gpg Release
gpg --default-key "$GPG_KEY_ID" --clearsign -o InRelease Release

echo "[✓] Repository signed and release files generated."

