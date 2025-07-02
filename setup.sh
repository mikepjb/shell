#!/bin/sh

set +e

setup_dir=`dirname $(realpath $0)`
local_bin_dir="$HOME/.local/bin"

main() {
    link_files
}

link_files() {
    echo '. ~/.bashrc' > $HOME/.bash_profile

    mkdir -p ~/.config/nvim
    ln -sfv $setup_dir/config/init.lua $HOME/.config/nvim/init.lua
    ln -sfv $setup_dir/config/bashrc $HOME/.bashrc
    ln -sfv $setup_dir/config/vimrc $HOME/.vimrc
    ln -sfv $setup_dir/config/alacritty.toml $HOME/.config/alacritty/alacritty.toml
    ln -sfv $setup_dir/config/tmux.conf $HOME/.config/tmux/tmux.conf
    ln -sfv $setup_dir/config/gitconfig $HOME/.gitconfig
    ln -sfv $setup_dir/config/gitconfig_loveholidays $HOME/.gitconfig_loveholidays

    mkdir -p ~/.clojure
    ln -sfv $setup_dir/config/deps.edn $HOME/.clojure/deps.edn

    mkdir -p ~/.local/bin
    for f in $setup_dir/bin/*; do
        ln -sfv $f $local_bin_dir/`basename $f`
    done

    mkdir -p ~/.vim/colors
    ln -sfv $setup_dir/config/spartan.vim $HOME/.vim/colors/spartan.vim
    ln -sfv $setup_dir/config/spartan.lua $HOME/.config/nvim/colors/spartan.lua
}

main
