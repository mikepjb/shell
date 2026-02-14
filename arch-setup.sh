#!/bin/sh

paru -S \
    minecraft-launcher

pacman -Syu \
    amdgpu_top \
    mitmproxy \
    dosfstools

# also enable networkmanager + bluetooth services after installing gnome
