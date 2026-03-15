#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# update-llama.sh
#
# Idempotent installer for llama.cpp.
# Checks if each tool is on PATH at the correct version. If not, installs it.
#
# Usage:
#   ./update-llama.sh                              # Install/update both if needed
#   ./update-llama.sh --force                      # Reinstall regardless of current version
#   GPU_TARGETS=gfx1030 ./update-llama.sh         # Build for specific GPU (Radeon 780M)
#
# GPU backend:
#   macOS → Metal (native, on by default — no flags needed)
#   Linux → Vulkan (default) or HIP/ROCm (fallback via LLAMACPP_GPU_BACKEND=hip)
#
# AMD GPU targets (gfx1030, gfx1100, etc. - check `rocminfo` or AMD docs)
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
LLAMACPP_GPU_BACKEND="${LLAMACPP_GPU_BACKEND:-vulkan}"
GPU_TARGETS="${GPU_TARGETS:-gfx1103}"  # Radeon 780M (override with GPU_TARGETS=gfxXXXX if different)

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
        if [[ "$LLAMACPP_GPU_BACKEND" == "vulkan" ]]; then
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
        else
            if ! command -v hipcc &>/dev/null; then
                warn "hipcc not found — needed for ROCm/HIP"
                warn "  Debian/Ubuntu: sudo apt-get install hip-runtime-amd"
                warn "  Fedora:        sudo dnf install hip-runtime-amd"
                warn "  Arch:          sudo pacman -S hip-runtime-amd"
                warn "  Or use: LLAMACPP_GPU_BACKEND=vulkan ./update-llama.sh"
            fi

            if ! command -v hipcc &>/dev/null; then
                warn "hipblas not found — needed for ROCm/HIP"
                warn "  Arch:          sudo pacman -S hipblas"
                warn "  Or use: LLAMACPP_GPU_BACKEND=vulkan ./update-llama.sh"
            fi

            if ! pkg-config --exists rocwmma 2>/dev/null && [[ ! -f "/opt/rocm/include/rocwmma/internal/accessors.hpp" ]]; then
                warn "rocwmma not found — optional for matrix operations"
                warn "  Arch:          sudo pacman -S rocwmma"
            fi
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
    #   Linux: Vulkan (default) or HIP/ROCm (fallback)
    local -a flags=(-DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF)

    case "$(uname -s)" in
        Linux)
            case "$LLAMACPP_GPU_BACKEND" in
                vulkan) flags+=(-DGGML_VULKAN=ON) ;;
                hip|*)
                    flags+=(-DGGML_HIP=ON)
                    [[ -n "$GPU_TARGETS" ]] && flags+=(-DGPU_TARGETS="$GPU_TARGETS")
                    ;;
            esac
            ;;
        Darwin)
            flags+=(-DGGML_METAL=ON)              # GPU compute via Metal
            flags+=(-DGGML_METAL_EMBED_LIBRARY=ON) # Embed Metal library in binary
            flags+=(-DGGML_ACCELERATE=ON)         # ARM NEON + Accelerate framework
            flags+=(-DLLAMA_NATIVE=ON)            # Native M1/M2/M3 optimizations
            ;;
    esac

    # Set HIP environment variables for Linux builds
    if [[ "$(uname -s)" == "Linux" && "$LLAMACPP_GPU_BACKEND" == "hip" ]]; then
        export HIPCXX="$(hipconfig -l)/clang"
        export HIP_PATH="$(hipconfig -R)"
        # hurts non-integrated GPU performance but enables use of unified memory
        export GGML_CUDA_ENABLE_UNIFIED_MEMORY=1
    fi

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
