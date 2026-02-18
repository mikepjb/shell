#!/bin/sh

paru -S \
    minecraft-launcher \
    asusctl \
    slack-desktop

pacman -Syu \
    amdgpu_top \
    mitmproxy \
    dosfstools \
    wl-clipboard

# also enable networkmanager + bluetooth services after installing gnome
#
# we set a slower (originally 1000) battery check time to help resolve phantom
# charge events on vivobook
#echo 3000 | sudo tee /sys/module/battery/parameters/cache_time
