#!/bin/sh

set +e

setup_dir=`dirname $(realpath $0)`
local_bin_dir="$HOME/.local/bin"

main() {
    link_files
    setup_llm_tools
    # npm_deps
}

link_files() {
    echo '. ~/.bashrc' > $HOME/.bash_profile

    mkdir -p ~/.config/nvim
    mkdir -p ~/.config/tmux
    mkdir -p ~/.config/alacritty

    ln -sfv $setup_dir/config/init.lua $HOME/.config/nvim/init.lua
    ln -sfv $setup_dir/config/bashrc $HOME/.bashrc
    ln -sfv $setup_dir/config/npmrc $HOME/.npmrc
    ln -sfv $setup_dir/config/vimrc $HOME/.vimrc
    ln -sfv $setup_dir/config/alacritty.toml $HOME/.config/alacritty/alacritty.toml
    ln -sfv $setup_dir/config/tmux.conf $HOME/.config/tmux/tmux.conf
    ln -sfv $setup_dir/config/gitconfig $HOME/.gitconfig
    ln -sfv $setup_dir/config/gitmessage $HOME/.gitmessage
    ln -sfv $setup_dir/config/gitconfig_loveholidays $HOME/.gitconfig_loveholidays
    ln -sfv $setup_dir/config/gitignore $HOME/.gitignore

    mkdir -p ~/.clojure
    ln -sfv $setup_dir/config/deps.edn $HOME/.clojure/deps.edn

    mkdir -p ~/.local/bin
    for f in $setup_dir/bin/*; do
        ln -sfv $f $local_bin_dir/`basename $f`
    done

    mkdir -p ~/.vim/colors
    ln -sfv $setup_dir/config/spartan.vim $HOME/.vim/colors/spartan.vim
    mkdir -p ~/.config/nvim/colors
    ln -sfv $setup_dir/config/spartan.lua $HOME/.config/nvim/colors/spartan.lua

    # Claude Code config
    echo "Setting up Claude Code config"
    mkdir -p ~/.claude/agents
    mkdir -p ~/.claude/hooks
    ln -sfv $setup_dir/config/claude/CLAUDE.md $HOME/.claude/CLAUDE.md
    ln -sfv $setup_dir/config/claude/settings.json $HOME/.claude/settings.json
    ln -sfv $setup_dir/config/claude/statusline.sh $HOME/.claude/statusline.sh
    chmod +x $HOME/.claude/statusline.sh

    # Link hooks
    for f in $setup_dir/config/claude/hooks/*; do
        [ -e "$f" ] || continue
        ln -sfv $f $HOME/.claude/hooks/`basename $f`
        chmod +x $HOME/.claude/hooks/`basename $f`
    done

    # Clean up broken symlinks in claude directories
    find -L $HOME/.claude/agents -type l -delete 2>/dev/null
    find -L $HOME/.claude/hooks -type l -delete 2>/dev/null

    # Build list of expected agents from repo
    expected_agents=""
    for f in $setup_dir/config/claude/agents/*.md; do
        [ -e "$f" ] || continue
        expected_agents="$expected_agents $(basename $f)"
    done

    # Clean up agents not in repo
    for f in $HOME/.claude/agents/*.md; do
        [ -e "$f" ] || continue
        agent=$(basename "$f")
        if ! echo "$expected_agents" | grep -qw "$agent"; then
            echo "Removing stale agent: $agent"
            rm -f "$f"
        fi
    done

    # Link agents from repo
    for f in $setup_dir/config/claude/agents/*.md; do
        [ -e "$f" ] || continue
        ln -sfv $f $HOME/.claude/agents/`basename $f`
    done
}

setup_llm_tools() {
    echo ""
    echo "Setting up LLM tools (Ollama, OpenCode, Qwen 3.2 8B)"

    # Install Ollama if not present
    if ! command -v ollama &> /dev/null; then
        echo "Installing Ollama..."
        curl -fsSL https://ollama.ai/install.sh | sh
    else
        echo "✓ Ollama already installed"
    fi

    # Install OpenCode if not present
    if ! command -v opencode &> /dev/null; then
        echo "Installing OpenCode..."
        curl -fsSL https://opencode.ai/install | bash
    else
        echo "✓ OpenCode already installed"
    fi

    # Check if Ollama service is running, start if needed
    if ! pgrep -x ollama > /dev/null; then
        echo "Starting Ollama service..."
        nohup ollama serve > /tmp/ollama.log 2>&1 &
        sleep 3
    else
        echo "✓ Ollama service already running"
    fi

    # Pull Qwen 3.2 8B model
    echo "Pulling Qwen 3.2 8B model..."
    ollama pull qwen3:8b

    # Configure context window for OpenCode (32k tokens)
    echo "Configuring model context window..."
    (sleep 1; echo "/set parameter num_ctx 32768"; echo "/save qwen3:8b"; sleep 1) | ollama run qwen3:8b > /dev/null 2>&1 &

    # Create OpenCode configuration directory and config file
    mkdir -p ~/.config/opencode
    cat > ~/.config/opencode/opencode.json <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "qwen3:8b": {
          "name": "qwen3:8b"
        }
      }
    }
  }
}
EOF

    echo "✓ LLM setup complete"
    echo ""
    echo "Usage:"
    echo "  Start Ollama:  ollama serve"
    echo "  Use OpenCode:  opencode"
    echo "  Chat directly: ollama run qwen3:8b"
}

# npm_deps() {
#     # if not installed..
#     # sql-formatter
# }

main
