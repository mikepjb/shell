#!/bin/sh

set +e

setup_dir=`dirname $(realpath $0)`
local_bin_dir="$HOME/.local/bin"

# Default to regular claude config, use auto-claude if --auto flag is passed
claude_config="claude"
if [ "$1" = "--auto" ]; then
    claude_config="auto-claude"
fi

main() {
    link_files
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
    echo "Setting up Claude Code with config: $claude_config"
    mkdir -p ~/.claude/skills
    mkdir -p ~/.claude/agents
    mkdir -p ~/.claude/commands
    mkdir -p ~/.claude/hooks
    ln -sfv $setup_dir/config/$claude_config/CLAUDE.md $HOME/.claude/CLAUDE.md
    ln -sfv $setup_dir/config/$claude_config/settings.json $HOME/.claude/settings.json
    ln -sfv $setup_dir/config/$claude_config/statusline.sh $HOME/.claude/statusline.sh
    chmod +x $HOME/.claude/statusline.sh

    # Link hooks
    for f in $setup_dir/config/$claude_config/hooks/*; do
        [ -e "$f" ] || continue
        ln -sfv $f $HOME/.claude/hooks/`basename $f`
        chmod +x $HOME/.claude/hooks/`basename $f`
    done

    # Clean up broken symlinks in claude directories
    find -L $HOME/.claude/commands -type l -delete 2>/dev/null
    find -L $HOME/.claude/agents -type l -delete 2>/dev/null
    find -L $HOME/.claude/skills -type l -delete 2>/dev/null
    find -L $HOME/.claude/hooks -type l -delete 2>/dev/null

    # Build list of expected skills from repo
    expected_skills=""
    for f in $setup_dir/config/$claude_config/skills/*.md; do
        expected_skills="$expected_skills $(basename $f .md)"
    done

    # Clean up skills not in repo
    for dir in $HOME/.claude/skills/*/; do
        skill=$(basename "$dir")
        if ! echo "$expected_skills" | grep -qw "$skill"; then
            echo "Removing stale skill: $skill"
            rm -rf "$dir"
        fi
    done

    # Link skills from repo
    for f in $setup_dir/config/$claude_config/skills/*.md; do
        skill=`basename $f .md`
        mkdir -p $HOME/.claude/skills/$skill
        ln -sfv $f $HOME/.claude/skills/$skill/SKILL.md
    done

    # Build list of expected agents from repo
    expected_agents=""
    for f in $setup_dir/config/$claude_config/agents/*.md; do
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
    for f in $setup_dir/config/$claude_config/agents/*.md; do
        [ -e "$f" ] || continue
        ln -sfv $f $HOME/.claude/agents/`basename $f`
    done

    # Build list of expected commands from repo
    expected_commands=""
    for f in $setup_dir/config/$claude_config/commands/*.md; do
        [ -e "$f" ] || continue
        expected_commands="$expected_commands $(basename $f)"
    done

    # Clean up commands not in repo
    for f in $HOME/.claude/commands/*.md; do
        [ -L "$f" ] || continue
        cmd=$(basename "$f")
        if ! echo "$expected_commands" | grep -qw "$cmd"; then
            echo "Removing stale command: $cmd"
            rm -f "$f"
        fi
    done

    # Link commands from repo
    for f in $setup_dir/config/$claude_config/commands/*.md; do
        [ -e "$f" ] || continue
        ln -sfv $f $HOME/.claude/commands/`basename $f`
    done
}

# npm_deps() {
#     # if not installed..
#     # sql-formatter
# }

main
