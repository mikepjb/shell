#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# update-llama.sh
#
# Idempotent installer for llama.cpp.
# Checks if each tool is on PATH at the correct version. If not, installs it.
#
# Usage:
#   ./update-llama.sh          # Install/update both if needed
#   ./update-llama.sh --force  # Reinstall regardless of current version
#
# GPU backend:
#   macOS → Metal (native, on by default — no flags needed)
#   Linux → Vulkan (-DGGML_VULKAN=ON)
#
# Refs:
#   llama.cpp build: https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md
# =============================================================================

# ── Versions ─────────────────────────────────────────────────────────────────
LLAMACPP_VERSION="master"

# ── Config ───────────────────────────────────────────────────────────────────
INSTALL_PREFIX="${HOME}/.local"
LLAMACPP_SRC="${HOME}/.local/src/llama.cpp"
FORCE="${1:-}"

# ── Helpers ──────────────────────────────────────────────────────────────────
log()  { printf '\033[1;34m==>\033[0m \033[1m%s\033[0m\n' "$1"; }
ok()   { printf '\033[1;32m ✓\033[0m  %s\n' "$1"; }
warn() { printf '\033[1;33m !\033[0m  %s\n' "$1"; }
err()  { printf '\033[1;31m ✗\033[0m  %s\n' "$1"; exit 1; }

job_count() {
    if command -v nproc &>/dev/null; then nproc
    elif command -v sysctl &>/dev/null; then sysctl -n hw.ncpu
    else echo 4; fi
}

# ── Version checks ──────────────────────────────────────────────────────────

llamacpp_installed_version() {
    local version_file="${INSTALL_PREFIX}/share/llama.cpp.version"
    if [[ -f "$version_file" ]]; then
        cat "$version_file"
    else
        echo ""
    fi
}

needs_llamacpp() {
    [[ "$FORCE" == "--force" ]] && return 0

    local installed
    installed="$(llamacpp_installed_version)"

    if [[ -z "$installed" ]]; then
        return 0  # not installed
    fi

    if ! command -v llama-cli &>/dev/null; then
        return 0  # version file exists but binary not on PATH
    fi

    [[ "$installed" != "$LLAMACPP_VERSION" ]]
}

# ── Preflight ────────────────────────────────────────────────────────────────

preflight_llama() {
    for cmd in git cmake; do
        command -v "$cmd" &>/dev/null || err "Missing: $cmd"
    done

    command -v gcc &>/dev/null || command -v clang &>/dev/null || err "No C/C++ compiler found"

    if [[ "$(uname -s)" == "Linux" ]]; then
        if ! command -v glslc &>/dev/null; then
            warn "glslc not found — needed for Vulkan shaders"
            warn "  Debian/Ubuntu: sudo apt-get install glslc"
            warn "  Fedora:        sudo dnf install glslc"
            warn "  Arch:          sudo pacman -S shaderc"
        fi
        if ! pkg-config --exists vulkan 2>/dev/null && [[ ! -d "${VULKAN_SDK:-}" ]]; then
            warn "Vulkan SDK not detected"
            warn "  Debian/Ubuntu: sudo apt-get install libvulkan-dev"
            warn "  Fedora:        sudo dnf install vulkan-devel"
        fi
    fi
}

# ── Install llama.cpp ────────────────────────────────────────────────────────

install_llamacpp() {
    log "Installing llama.cpp @ ${LLAMACPP_VERSION}"
    preflight_llama

    local repo="https://github.com/ggml-org/llama.cpp.git"

    # Clone or update source
    if [[ -d "$LLAMACPP_SRC" ]]; then
        cd "$LLAMACPP_SRC"
        git fetch --force
        git checkout "$LLAMACPP_VERSION"
        git submodule update --init --recursive
    else
        mkdir -p "$(dirname "$LLAMACPP_SRC")"
        git clone "$repo" "$LLAMACPP_SRC"
        cd "$LLAMACPP_SRC"
        git fetch origin master --tags --force
        git checkout "$LLAMACPP_VERSION"
        git submodule update --init --recursive
    fi

    # Clean previous build
    rm -rf build

    # CMake flags per platform (following official build docs)
    #   macOS: Explicit Metal + Accelerate + native ARM optimizations
    #   Linux: -DGGML_VULKAN=ON
    local -a flags=(-DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF)

    case "$(uname -s)" in
        Linux)  flags+=(-DGGML_VULKAN=ON) ;;
        Darwin)
            flags+=(-DGGML_METAL=ON)              # GPU compute via Metal
            flags+=(-DGGML_METAL_EMBED_LIBRARY=ON) # Embed Metal library in binary
            flags+=(-DGGML_ACCELERATE=ON)         # ARM NEON + Accelerate framework
            flags+=(-DLLAMA_NATIVE=ON)            # Native M1/M2/M3 optimizations
            ;;
    esac

    cmake -B build "${flags[@]}"
    cmake --build build --config Release -j "$(job_count)"

    # Copy binaries
    mkdir -p "${INSTALL_PREFIX}/bin"
    local bin_dir="build/bin"
    [[ -d "build/bin/Release" ]] && bin_dir="build/bin/Release"

    local count=0
    for f in "${bin_dir}"/llama-*; do
        [[ -x "$f" && -f "$f" ]] || continue
        cp "$f" "${INSTALL_PREFIX}/bin/"
        count=$((count + 1))
    done

    # Record version
    mkdir -p "${INSTALL_PREFIX}/share"
    echo "$LLAMACPP_VERSION" > "${INSTALL_PREFIX}/share/llama.cpp.version"

    ok "llama.cpp ${LLAMACPP_VERSION} — ${count} binaries → ${INSTALL_PREFIX}/bin"
}

# ── Main ─────────────────────────────────────────────────────────────────────

echo ""
log "llama.cpp ${LLAMACPP_VERSION}"
echo ""

if needs_llamacpp; then
    install_llamacpp
else
    ok "llama.cpp $(llamacpp_installed_version) — up to date"
fi

echo ""

echo ""

# PATH reminder
case ":${PATH}:" in
    *":${INSTALL_PREFIX}/bin:"*) ;;
    *)
        warn "${INSTALL_PREFIX}/bin is not on your PATH. Add to your shell profile:"
        echo "  export PATH=\"${INSTALL_PREFIX}/bin:\${PATH}\""
        echo ""
        ;;
esac

log "Done"
