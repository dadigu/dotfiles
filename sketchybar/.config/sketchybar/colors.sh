#!/bin/bash

# Source dotfiles .env for API keys (gitignored)
[ -f "$HOME/dotfiles/.env" ] && source "$HOME/dotfiles/.env"

export FONT="SF Pro"

### Catppuccin Macchiato
export BLACK=0xff181926
export WHITE=0xffcad3f5
export RED=0xffed8796
export GREEN=0xffa6da95
export BLUE=0xff8aadf4
export YELLOW=0xffeed49f
export ORANGE=0xfff5a97f
export MAGENTA=0xffc6a0f6
export GREY=0xff939ab7
export CYAN=0xff91d7e3
export TRANSPARENT=0x00000000
export BG0=0xff24273a
export BG1=0x8024273a
export BG2=0x80494d64

# General bar colors
export BAR_COLOR=$TRANSPARENT
export BAR_BORDER_COLOR=$BG2
export BACKGROUND_0=$BG0
export BACKGROUND_1=$BG1
export BACKGROUND_2=$BG2
export ICON_COLOR=$WHITE
export LABEL_COLOR=$WHITE
