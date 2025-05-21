#!/bin/bash

# === Configuration ===
REPO_NAME="blackfang-apt"
DIST="stable"
COMPONENT="main"
ARCHS=(amd64 all)
KEY_ID="79888DF31565EE8D"
GPG_KEYRING="$HOME/.gnupg/pubring.kbx"

# === Directory structure ===
BASE_DIR="$(pwd)"
DIST_DIR="$BASE_DIR/dists/$DIST"
POOL_DIR="$BASE_DIR/pool/$COMPONENT"

# === Clean old files ===
echo "[+] Cleaning old metadata..."
rm -f $DIST_DIR/Release $DIST_DIR/InRelease $DIST_DIR/Release.gpg

# === Generate Packages.gz ===
echo "[+] Generating Packages.gz for each architecture..."
for ARCH in "${ARCHS[@]}"; do
    ARCH_DIR="$DIST_DIR/$COMPONENT/binary-$ARCH"
    mkdir -p "$ARCH_DIR"
    echo "  -> Processing $ARCH..."
    apt-ftparchive packages "$POOL_DIR" \
        | gzip -9 > "$ARCH_DIR/Packages.gz"
    apt-ftparchive packages "$POOL_DIR" > "$ARCH_DIR/Packages"
done

# === Generate main Release file ===
echo "[+] Generating Release file..."
cat > $DIST_DIR/Release <<EOF
Origin: BlackFang
Label: BlackFang APT
Suite: $DIST
Codename: $DIST
Architectures: ${ARCHS[*]}
Components: $COMPONENT
Description: BlackFang OS APT Repository
EOF

# Include package metadata in Release file
echo "[+] Adding file hashes to Release..."
apt-ftparchive release $DIST_DIR >> $DIST_DIR/Release

# === Sign the Release file ===
echo "[+] Signing Release file..."
gpg --default-key "$KEY_ID" -abs -o "$DIST_DIR/Release.gpg" "$DIST_DIR/Release"
gpg --default-key "$KEY_ID" --clearsign -o "$DIST_DIR/InRelease" "$DIST_DIR/Release"

# === Done ===
echo "[✔] Repository metadata updated and signed successfully."

