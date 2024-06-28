#!/bin/bash

RC='\e[0m'
RED='\e[31m'
YELLOW='\e[33m'
GREEN='\e[32m'

TOOLBOX="$HOME/toolbox"

if [ ! -d "$TOOLBOX" ]; then
    echo -e "${YELLOW}Creating Toolbox directory...${RC}"
    mkdir -p "$TOOLBOX"
    echo -e "${GREEN}Toolbox directory created!${RC}"
else
    echo -e "${GREEN}Toolbox directory already exists!${RC}"
fi

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

REQS="curl wget 0ad"

check_env() {
    PACKAGE_MANAGER="pacman"

    if command_exists ${PACKAGE_MANAGER}; then
        echo -e "${YELLOW}Package manager: ${PACKAGE_MANAGER}${RC}"
    else
        echo -e "${RED}Error: Package manager not supported!${RC}"
        exit 1
    fi
}

get_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME

        echo -e "${GREEN}OS: ${OS}${RC}"
    else
        echo -e "${RED}Error: /etc/os-release not found!${RC}"
        exit 1
    fi

    ## Check SuperUser Group
    SUPERUSERGROUP='wheel sudo root'
    for sug in ${SUPERUSERGROUP}; do
        if groups | grep "${sug}"; then
            SUGROUP=${sug}
            echo -e "${YELLOW}Super user group: ${SUGROUP}"
        fi
    done

    ## Check if member of the sudo group.
    if ! groups | grep "${SUGROUP}" >/dev/null; then
        echo -e "${RED}You need to be a member of the sudo group to run me!"
        exit 1
    fi
}

install_deps() {
    DEPS="make cmake jq go tldr unzip tree neovim zsh tmux nodejs npm python3 exa bat ripgrep fd fzf"
    PACKAGER="pacman"

    if ! command_exists yay; then
        echo -e "${RED}yay not found!${RC}"
        echo -e "${YELLOW}Installing yay...${RC}"
        
        sudo ${PACKAGER} --noconfirm -S base-devel make
        cd /opt && sudo git clone https://aur.archlinux.org/yay.git && sudo chown -R "${USER}:${USER}" ./yay-git
        cd yay-git && makepkg --noconfirm -si
        AUR_HELPER="yay"
    else 
        echo -e "${GREEN}yay found!${RC}"
    fi

    sudo ${PACKAGER} --noconfirm -Syu
    sudo ${PACKAGER} --noconfirm -S ${DEPS}

}



get_os
check_env
install_deps
