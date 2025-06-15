#!/bin/sh

set +e

setup_dir=$(dirname $(realpath $0))

echo '. ~/.bashrc' > $HOME/.bash_profile

ln -sfv $setup_dir/config/bashrc $HOME/.bashrc
ln -sfv $setup_dir/config/vimrc $HOME/.vimrc
ln -sfv $setup_dir/config/alacritty.toml $HOME/.config/alacritty/alacritty.toml
ln -sfv $setup_dir/config/tmux.conf $HOME/.config/tmux/tmux.conf
ln -sfv $setup_dir/config/gitconfig $HOME/.gitconfig
ln -sfv $setup_dir/config/gitconfig_loveholidays $HOME/.gitconfig_loveholidays

mkdir -p ~/.vim/colors
ln -sfv $setup_dir/config/spartan.vim $HOME/.vim/colors/spartan.vim
