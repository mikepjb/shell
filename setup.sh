#!/bin/sh

set +e

setup_dir=`dirname $(realpath $0)`
local_bin_dir="$HOME/.local/bin"

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
    mkdir -p ~/.claude/skills
    ln -sfv $setup_dir/config/claude/CLAUDE.md $HOME/.claude/CLAUDE.md
    ln -sfv $setup_dir/config/claude/settings.json $HOME/.claude/settings.json
    for f in $setup_dir/config/claude/skills/*.md; do
        skill=`basename $f .md`
        mkdir -p $HOME/.claude/skills/$skill
        ln -sfv $f $HOME/.claude/skills/$skill/SKILL.md
    done
}

# npm_deps() {
#     # if not installed..
#     # sql-formatter
# }

main
