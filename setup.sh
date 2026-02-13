#!/usr/bin/env bash

set -e

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

    to_install=""

    check git
    check nvim neovim
    check tmux
    check make
    check rg ripgrep
    check jq
    check curl
    check wget
    check htop
    check huggingface-cli python-huggingface-hub

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

    # AI tools (AUR on Arch, brew elsewhere)
    missing=""
    command -v opencode &> /dev/null    || missing="$missing\n  paru -S opencode-bin"
    command -v llama-server &> /dev/null || missing="$missing\n  paru -S llama.cpp"

    if [ -n "$missing" ]; then
        if [ -f /etc/arch-release ]; then
            echo -e "\nMissing AI tools (install with paru):$missing"
        elif command -v brew &> /dev/null; then
            brew install opencode llama.cpp
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
    ensure_dir_and_link "$setup_dir/config/init.lua" "$HOME/.config/nvim/init.lua"
    ensure_dir_and_link "$setup_dir/config/spartan.lua" "$HOME/.config/nvim/colors/spartan.lua"
    ensure_dir_and_link "$setup_dir/config/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
    ensure_dir_and_link "$setup_dir/config/tmux.conf" "$HOME/.config/tmux/tmux.conf"
    ensure_dir_and_link "$setup_dir/config/deps.edn" "$HOME/.clojure/deps.edn"

    # Bin scripts
    mkdir -p "$local_bin_dir"
    for f in "$setup_dir/bin/"*; do
        ln -sfv "$f" "$local_bin_dir/$(basename "$f")"
    done

    # Claude Code config
    echo "Setting up Claude Code config"
    mkdir -p "$HOME/.claude/agents"
    mkdir -p "$HOME/.claude/hooks"
    ln -sfv "$setup_dir/config/ai/AGENTS.md" "$HOME/.claude/CLAUDE.md"
    ln -sfv "$setup_dir/config/claude/settings.json" "$HOME/.claude/settings.json"
    ln -sfv "$setup_dir/config/claude/statusline.sh" "$HOME/.claude/statusline.sh"
    chmod +x "$HOME/.claude/statusline.sh"

    for f in "$setup_dir/config/claude/hooks/"*; do
        [ -e "$f" ] || continue
        ln -sfv "$f" "$HOME/.claude/hooks/$(basename "$f")"
        chmod +x "$HOME/.claude/hooks/$(basename "$f")"
    done

    # OpenCode config
    echo "Setting up OpenCode config"
    ensure_dir_and_link "$setup_dir/config/ai/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"
    ensure_dir_and_link "$setup_dir/config/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"

    # Clean up broken symlinks in claude directories
    find -L "$HOME/.claude/agents" -type l -delete 2>/dev/null
    find -L "$HOME/.claude/hooks" -type l -delete 2>/dev/null

    # Sync agents: remove stale, link current
    expected_agents=""
    for f in "$setup_dir/config/claude/agents/"*.md; do
        [ -e "$f" ] || continue
        expected_agents="$expected_agents $(basename "$f")"
    done

    for f in "$HOME/.claude/agents/"*.md; do
        [ -e "$f" ] || continue
        agent=$(basename "$f")
        if ! echo "$expected_agents" | grep -qw "$agent"; then
            echo "Removing stale agent: $agent"
            rm -f "$f"
        fi
    done

    for f in "$setup_dir/config/claude/agents/"*.md; do
        [ -e "$f" ] || continue
        ln -sfv "$f" "$HOME/.claude/agents/$(basename "$f")"
    done
}

main
