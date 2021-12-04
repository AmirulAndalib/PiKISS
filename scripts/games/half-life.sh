#!/bin/bash
#
# Description : Half Life thks to Salva (Pi Labs)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.13 (04/Dec/21)
# Compatible  : Raspberry Pi (tested)
# Repository  : https://github.com/ValveSoftware/halflife
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES_DEV=(libsdl2-dev)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/half-life-0.20-bin-rpi.tar.gz"
readonly HQ_TEXTURE_PACK_URL="https://gamebanana.com/dl/265907"
readonly SOURCE_CODE_URL="https://github.com/FWGS/xash3d"
readonly ES_TRANSLATION_URL="https://misapuntesde.com/rpi_share/hl-sp-patch.tar.gz"
readonly VAR_DATA_NAME="HALF_LIFE"

runme() {
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/half-life && ./half-life.sh
    echo
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/half-life ~/.local/share/applications/half-life.desktop
}

uninstall() {
    read -p "Do you want to uninstall Half Life (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/half-life ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/half-life ]]; then
    echo -e "Half Life already installed.\n"
    uninstall
    exit 0
fi

generate_icon() {
    if [[ ! -e ~/.local/share/applications/half-life.desktop ]]; then
        cat <<EOF >~/.local/share/applications/half-life.desktop
[Desktop Entry]
Name=Half Life
Exec=${INSTALL_DIR}/half-life/half-life.sh
Icon=${INSTALL_DIR}/half-life/hl.ico
Path=${INSTALL_DIR}/half-life/
Type=Application
Comment=Players assume the role of Gordon Freeman, a scientist who must find his way out of the Black Mesa Research Facility after it is invaded by aliens
Categories=Game;ActionGame;
EOF
    fi
}

post_install() {
    if [[ -f $INSTALL_DIR/half-life/config.cfg ]] && [[ -d $INSTALL_DIR/half-life/valve ]]; then
        echo
        echo "Copying tweaked config.cfg..."
        cp -f "$INSTALL_DIR"/half-life/config.cfg "$INSTALL_DIR"/half-life/valve
    fi

    # if [[ $(get_keyboard_layout) == "es" ]]; then
    #     echo
    #     echo "Detected Latin/Spanish user. Applying translation..."
    #     download_and_extract "$ES_TRANSLATION_URL" "$INSTALL_DIR/half-life"
    # fi
}

download_data_files() {
    DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
    message_magic_air_copy "$VAR_DATA_NAME"
    download_and_extract "$DATA_URL" "$INSTALL_DIR"/half-life
}

install() {
    local DATA_URL
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    generate_icon

    if ! exists_magic_file; then
        echo -e "\nNow copy the /valve directory inside $INSTALL_DIR/half-life and enjoy :)"
        exit_message
    fi

    download_data_files
    post_install
    echo -e "\nDone!."
    runme
}

install_script_message
echo "
Install Half Life on Raspberry Pi
=================================

 · Based on engine at ${SOURCE_CODE_URL}
 · REMEMBER YOU NEED A LEGAL COPY OF THE GAME and copy /valve directory inside $INSTALL_DIR/half-life
 · To play, when installed use Menu > Games > Half-Life or $INSTALL_DIR/half-life/half-life.sh
"
read -p "Press [ENTER] to continue..."

install
