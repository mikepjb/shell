#!/usr/bin/env sh
# Copy this into your zig projects, use this to download/pin a specific version.
set -eu

ZIG_MIRROR="https://ziglang.org/download"
ZIG_RELEASE="0.17.1"
ZIG_CHECKSUMS=$(cat<<EOF
${ZIG_MIRROR}/${ZIG_RELEASE}/zig-aarch64-linux-${ZIG_RELEASE}.tar.xz a1546d5646eb184437918d6635ca6b762a0e889eac09cef720ee7a1ed3fe7795
${ZIG_MIRROR}/${ZIG_RELEASE}/zig-aarch64-macos-${ZIG_RELEASE}.tar.xz 75f1bc7a1e9852f17ec9a0c1895f767c4ec56d46bc8a834920eece1d0359dd8d
${ZIG_MIRROR}/${ZIG_RELEASE}/zig-x86_64-linux-${ZIG_RELEASE}.tar.xz 3581863e3cbcfd0fce0efc682ce7e9e93da96668a977791d356a26d2a7e9b17a
${ZIG_MIRROR}/${ZIG_RELEASE}/zig-x86_64-macos-${ZIG_RELEASE}.tar.xz 9af07b20319fbd0c92ee46ad23e81d6a782b1aaea2cfb8dcbff35f1d2c7ddbb7
EOF
)

case "${1:-}" in
    --checksum) [ "$#" -eq 1 ] || { echo "Usage: $0 [--checksum]" >&2; exit 1; }; CHECKSUM_MODE=1 ;;
    '') [ "$#" -eq 0 ] || { echo "Usage: $0 [--checksum]" >&2; exit 1; }; CHECKSUM_MODE=0 ;;
    *) echo "Usage: $0 [--checksum]" >&2; exit 1 ;;
esac

# Determine the architecture:
if [ "$(uname -m)" = 'arm64' ] || [ "$(uname -m)" = 'aarch64' ]; then
    ZIG_ARCH="aarch64"
else
    ZIG_ARCH="x86_64"
fi

# Determine the operating system:
case "$(uname)" in
    Linux)
        ZIG_OS="linux"
        ;;
    Darwin)
        ZIG_OS="macos"
        ;;
    *)
        echo "Unknown OS"
        exit 1
        ;;
esac

ZIG_URL="${ZIG_MIRROR}/${ZIG_RELEASE}/zig-${ZIG_ARCH}-${ZIG_OS}-${ZIG_RELEASE}.tar.xz"
if [ "$CHECKSUM_MODE" -eq 0 ]; then
    ZIG_CHECKSUM_EXPECTED=$(echo "$ZIG_CHECKSUMS" | grep -F "$ZIG_URL" | cut -d ' ' -f 2)
fi

# Work out the filename from the URL, as well as the directory without the ".tar.xz" file extension:
ZIG_ARCHIVE="./zig/cache/$(basename "$ZIG_URL")"
ZIG_DIRECTORY=$(basename "$ZIG_ARCHIVE" ".tar.xz")

checksum_actual() {
    if command -v sha256sum > /dev/null; then
        sha256sum "$ZIG_ARCHIVE" | cut -d ' ' -f 1
    elif command -v shasum > /dev/null; then
        shasum -a 256 "$ZIG_ARCHIVE" | cut -d ' ' -f 1
    else
        echo "Neither sha256sum nor shasum available." >&2
        return 1
    fi
}

# Returns 0 if the given file exists and its SHA-256 checksum matches the expected value.
checksum_valid() {
    [ -f "$ZIG_ARCHIVE" ] && [ "$(checksum_actual)" = "$ZIG_CHECKSUM_EXPECTED" ]
}

if [ "$CHECKSUM_MODE" -eq 0 ] && checksum_valid; then # Caching for CI.
    echo "Skip downloading Zig $ZIG_RELEASE."
else
    echo "Downloading Zig $ZIG_RELEASE ..."
    mkdir -p ./zig/cache
    if ! command -v curl > /dev/null; then
        echo "curl is required to download Zig." >&2
        exit 1
    fi
    curl --fail --location --silent --show-error --output "$ZIG_ARCHIVE" "$ZIG_URL"

    if [ "$CHECKSUM_MODE" -eq 1 ]; then
        ZIG_CHECKSUM_ACTUAL=$(checksum_actual)
        printf '%s %s\n' "$ZIG_URL" "$ZIG_CHECKSUM_ACTUAL"
        exit 0
    fi

    # Verify the checksum.
    if ! checksum_valid; then
        echo "Checksum mismatch."
        exit 1
    fi
fi

echo "Extracting $ZIG_ARCHIVE ..."
tar -xf "$ZIG_ARCHIVE"
# NB: Keep archive for caching.

# Replace these existing directories and files so that we can install or upgrade:
rm -rf zig/doc
rm -rf zig/lib
mv "$ZIG_DIRECTORY/LICENSE" zig/
mv "$ZIG_DIRECTORY/README.md" zig/
mv "$ZIG_DIRECTORY/doc" zig/
mv "$ZIG_DIRECTORY/lib" zig/
mv "$ZIG_DIRECTORY/zig" zig/

# We expect to have now moved all directories and files out of the extracted directory.
# Do not force remove so that we can get an error if the above list of files ever changes:
rmdir "$ZIG_DIRECTORY"

# It's up to the user to add this to their path if they want to:
ZIG_BIN="$(pwd)/zig/zig"
echo "Downloading completed ($ZIG_BIN)! Enjoy!"
