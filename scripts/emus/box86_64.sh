#!/bin/bash
#
# Description : Box86-64
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.1 (06/Sep/24)
# Tested      : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ../helper.sh || . ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INPUT=/tmp/box86.$$
BOX_VERSION=$(is_userspace_64_bits && echo "box64" || echo "box86")

uninstall_box() {
    if [[ ! -f /usr/local/bin/$BOX_VERSION ]]; then
        echo -e "\nNothing to uninstall."
        return 0
    fi

    echo -e "\nUninstalling..."
    sudo rm -rf "$HOME/$BOX_VERSION" "/usr/local/bin/$BOX_VERSION" "/etc/binfmt.d/$BOX_VERSION.conf" /usr/lib/i386-linux-gnu/libstdc++.so.6 /usr/lib/i386-linux-gnu/libstdc++.so.5 /usr/lib/i386-linux-gnu/libgcc_s.so.1
    echo -e "Done."
}

menu() {
    while true; do
        dialog --clear \
            --title "[ ${BOX_VERSION} for Raspberry Pi ]" \
            --menu "Choose language:" 11 80 3 \
            Source "Compile sources for Raspberry Pi. Est. time RPi 4: ~5 min." \
            Uninstall "Uninstall ${BOX_VERSION} from your system." \
            Exit "Return to main menu" 2>"${INPUT}"

        menuitem=$(<"${INPUT}")

        case $menuitem in
        Source) clear && compile_box86_or_64 && return 0 ;;
        Uninstall) clear && uninstall_box && return 0 ;;
        Exit) exit 0 ;;
        esac
    done
}

menu
exit_message
