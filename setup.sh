#!/usr/bin/env bash

set -e

# need to add rustup.. rust tools
# cargo-llvm-cov for coverage (via cargo install)
#rustup component add rust-analyzer
# install react developer tools chrome extension!

# rocm-smi-lib

setup_dir=$(dirname "$(realpath "$0")")
local_bin_dir="$HOME/.local/bin"

main() {
    install_tools
    link_files
}

ensure_dir_and_link() {
    mkdir -p "$(dirname "$2")"
    ln -sfv "$1" "$2"
}

check() {
    local cli="$1"
    local pacman_pkg="${2:-$1}"
    local brew_pkg="${3:-${2:-$1}}"

    if ! command -v "$cli" &> /dev/null; then
        if [ -f /etc/arch-release ]; then
            to_install="$to_install $pacman_pkg"
        else
            to_install="$to_install $brew_pkg"
        fi
    fi
}

install_tools() {
    echo ""
    echo "Setting up CLI tools"

    local to_install=""

    # wl-clipboard arch only
    check git
    check nvim neovim
    check tmux
    check make
    check rg ripgrep
    check jq
    check yq go-yq yq
    check curl
    check wget
    check htop
    check shellcheck
    check hf huggingface-cli python-huggingface-hub
    check python
    check pip python-pip
    check gopls
    check k3d rancher-k3d-bin k3d
    check kubectl
    check helm
    check docker
    # check docker-buildx # docker-buildx is the arch package.. is there a cli?
    # check 'docker compose?' docker-compose
    check cwebp libwebp-utils
    check clojure
    check 7z p7zip sevenzip

    if [ -z "$to_install" ]; then
        echo "✓ All tools already installed"
    else
        echo "Installing:$to_install"
        if [ -f /etc/arch-release ]; then
            sudo pacman -S --noconfirm $to_install
        elif command -v brew &> /dev/null; then
            brew install $to_install
        else
            echo "Warning: No package manager found (pacman or brew)"
            return 1
        fi
    fi

    echo "✓ Tools installation complete"
}

link_files() {
    echo '. ~/.bashrc' > "$HOME/.bash_profile"

    # Extensionless config files go to $HOME/.$filename
    for config_file in "$setup_dir/config/"*; do
        filename=$(basename "$config_file")
        if [ -d "$config_file" ] || [[ "$filename" == *.* ]]; then
            continue
        fi
        ln -sfv "$config_file" "$HOME/.$filename"
    done

    # Config files with extensions go to specific locations
    ensure_dir_and_link "$setup_dir/config/ghostty.conf" "$HOME/.config/ghostty/config"
    ensure_dir_and_link "$setup_dir/config/init.lua" "$HOME/.config/nvim/init.lua"
    ensure_dir_and_link "$setup_dir/config/spartan.lua" "$HOME/.config/nvim/colors/spartan.lua"
    ensure_dir_and_link "$setup_dir/config/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
    ensure_dir_and_link "$setup_dir/config/tmux.conf" "$HOME/.config/tmux/tmux.conf"
    ensure_dir_and_link "$setup_dir/config/deps.edn" "$HOME/.clojure/deps.edn"
    ensure_dir_and_link "$setup_dir/config/spellbook.yaml" "$HOME/.config/spellbook/spellbook.yaml"
    ensure_dir_and_link "$setup_dir/config/pact.yaml" "$HOME/.config/pact/pact.yaml"
    ensure_dir_and_link "$setup_dir/config/clojure.edn" "$HOME/.config/clojure/deps.edn"

    # Bin scripts
    mkdir -p "$local_bin_dir"
    for f in "$setup_dir/bin/"*; do
        ln -sfv "$f" "$local_bin_dir/$(basename "$f")"
    done
}

main
