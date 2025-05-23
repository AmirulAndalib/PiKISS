#!/bin/bash
#
# Description : Compile QT5 on Raspberry Pi
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.6 (24/Apr/21)
# Compatible  : Raspberry Pi 4
#
# Links       : https://www.cyberpunk.rs/building-raspberry-pi-gui
# Links       : https://www.interelectronix.com/qt-on-the-raspberry-pi-4.html
#
. ../helper.sh || . ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

QT5_SC_URL="https://download.qt.io/official_releases/qt/5.15/5.15.2/single/qt-everywhere-src-5.15.2.tar.xz"
QT5_PKG_URL="https://github.com/koendv/qt5-opengl-raspberrypi/releases/download/v5.15.2-1/qt5-opengl-dev_5.15.2_armhf.deb"
QT5_CREATOR_PKG_URL="https://github.com/koendv/qt5-opengl-raspberrypi/releases/download/v5.15.2-1/qt5-opengl-qtcreator_4.14.1_armhf.deb"
RPI_CONFIGURATION_URL="https://github.com/oniongarlic/qt-raspberrypi-configuration"
INPUT=/tmp/qt5menu.$$

uninstall_qt5() {
    if [[ ! -e /opt/QT5 ]]; then
        return 0
    fi
    echo "Warning!: Qt 5.15.2 already installed."
    echo
    read -p "Do you want to uninstall Qt 5.15.2 (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        [[ -d /opt/QT5 ]] && sudo rm -rf /opt/QT5
        if [[ -e /usr/lib/qt5.15.2 ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

uninstall_qt5_opengl() {
    if [[ ! -e /usr/lib/qt5.15.2 ]]; then
        return 0
    fi
    echo "Warning!: Qt 5.15.2 already installed."
    echo
    read -p "Do you want to uninstall Qt 5.15.2 (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        [[ -d /usr/lib/qt5.15.2 ]] && sudo dpkg -r qt5-opengl-dev qt5-opengl-qtcreator && sudo rm -rf /usr/lib/qt5.15.2
        if [[ -e /usr/lib/qt5.15.2 ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

init() {
    echo
    sudo gpasswd -a "$USER" render

    [[ ! -d /opt/QT5 ]] && sudo mkdir /opt/QT5
    sudo chown "$USER":"$USER" /opt/QT5
    echo "{ \"device\": \"/dev/dri/card1\" }" >>/opt/QT5/eglfs.json

    upgrade_dist
}

install_packages() {
    echo -e "\nInstalling some dependencies...\n"

    sudo apt install -y clang libegl1-mesa-dev libgbm-dev libgles2-mesa-dev mesa-common-dev \
        libclang-dev libatspi-dev build-essential libfontconfig1-dev libdbus-1-dev libfreetype6-dev \
        libicu-dev libinput-dev libxkbcommon-dev libsqlite3-dev libssl-dev libpng-dev libjpeg-dev \
        libglib2.0-dev libraspberrypi-dev qtbase5-dev qt5-qmake qtchooser

    echo
    read -p "Do you need bluetooth library support? [y/n] " yn
    case $yn in
    [Yy]*) sudo apt install -y bluez libbluetooth-dev ;;
    esac

    echo
    read -p "Do you need gstreamer library for Multimedia support? [y/n] " yn
    case $yn in
    [Yy]*) sudo apt install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad libgstreamer-plugins-bad1.0-dev gstreamer1.0-pulseaudio gstreamer1.0-tools gstreamer1.0-alsa ;;
    esac

    echo
    read -p "Do you need audio support? [y/n] " yn
    case $yn in
    [Yy]*) sudo apt install -y libasound2-dev ;;
    esac

    echo
    read -p "Do you need Database support (PostgreSQL, MySQL)? [y/n] " yn
    case $yn in
    [Yy]*) sudo apt install -y libpq-dev libmariadbclient-dev ;;
    esac

    echo
    read -p "Do you need X11 support? [y/n] " yn
    case $yn in
    [Yy]*) sudo apt install -y libx11-dev libxcb1-dev libxkbcommon-x11-dev libx11-xcb-dev libxext-dev ;;
    esac

    echo
    read -p "Do you want experimental VC4 driver instead of Broadcom EGL binary-blobs? [y/n] " yn
    case $yn in
    [Yy]*) sudo apt install -y libgles2-mesa-dev libgbm-dev ;;
    esac
}

download_QT5() {
    if [[ ! -d $HOME/qt-everywhere-src-5.15.2 ]]; then
        download_and_extract "$QT5_SC_URL" "$HOME"
    fi
}

compile_QT5() {
    echo -e "\nCompile QT with 4 cores. Go for a walk or watch 2 movies...\n"

    cd "$HOME/qt-everywhere-src-5.15.2" || exit 1
    PKG_CONFIG_LIBDIR=/usr/lib/arm-linux-gnueabihf/pkgconfig:/usr/share/pkgconfig \
        ../qt-everywhere-src-5.15.2/configure -platform linux-rpi-g++ \
        -v \
        -opengl es2 -eglfs \
        -no-gtk \
        -opensource -confirm-license -release \
        -reduce-exports \
        -force-pkg-config \
        -nomake examples -no-compile-examples \
        -skip qtwayland \
        -skip qtwebengine \
        -no-feature-geoservices_mapboxgl \
        -qt-pcre \
        -no-pch \
        -ssl \
        -evdev \
        -system-freetype \
        -fontconfig \
        -glib \
        -prefix /opt/Qt5 \
        -qpa eglfs

    make_with_all_cores
}

setup() {
    if grep -q 'export LD_LIBRARY_PATH=/opt/QT5/lib' "$HOME"/.bashrc; then
        return 0
    fi
    echo "Adding enviroment variables to bashrc..."
    echo "export LD_LIBRARY_PATH=/opt/QT5/lib" >>"$HOME/.bashrc"
    echo 'export PATH=/opt/QT5/bin:$PATH' >>"$HOME/.bashrc"
    source "$HOME"/.bashrc
}

setup2() {
    if grep -q 'export LD_LIBRARY_PATH=/usr/lib/qt5.15.2/lib' "$HOME"/.bashrc; then
        return 0
    fi
    echo "Adding enviroment variables to bashrc..."
    echo "export LD_LIBRARY_PATH=/usr/lib/qt5.15.2/lib" >>"$HOME/.bashrc"
    echo 'export PATH=/usr/lib/qt5.15.2/bin:$PATH' >>"$HOME/.bashrc"
    source "$HOME"/.bashrc
}

setup_mkspecs() {
    if [[ -d $HOME/qt-raspberrypi-configuration ]]; then
        return 0
    fi
    echo -e "\nSetting up Qt mkspecs configuration files..."
    cd "$HOME" || exit 1
    git clone "$RPI_CONFIGURATION_URL" qt-raspberrypi-configuration && cd "$_" || exit 1
    make install DESTDIR="$HOME/qt-everywhere-src-5.15.2"
}

compile_menu() {
    uninstall_qt5
    install_script_message
    echo "
Compile QT 5
============

· This script compiles QT5 ready for Raspberry Pi 4.
· If you want qtwebengine, remove the -skip qtwebengine line inside this script.
· Make your you have enough space on the device.
· Qt source archive: 560MB, Unpacked Qt Sources: 3.7GB, Build result: ~830MB, Install size: ~232MB (Depends on configuration options and enabled features)
· This process can take about ~6 hours to compile on Rpi 4.
· If you use a Pi with less than 2 GB RAM, then you will need to increase the swap file size.
· Make sure you use a fan to keep your board fresh.
· Consider Overclocking your Pi before running this script.
· If you need additional help, visit https://www.tal.org/tutorials/building-qt-512-raspberry-pi
"

    while true; do
        read -p "Proceed? [y/n] " yn
        case $yn in
        [Yy]*)
            init
            install_packages
            download_QT5
            setup
            setup_mkspecs
            compile_QT5 && echo -e "\nDone!. Just type sudo make install"
            ;;
        [Nn]*) exit ;;
        [Ee]*) exit ;;
        *) echo "Please answer (y)es, (n)o or (e)xit." ;;
        esac
    done
}

install_from_repo() {
    install_script_message
    sudo apt install -y qtbase5-dev qt5-qmake qtchooser
    read -p "Done. Press [ENTER] to come back to the menu..."
    exit
}

install2() {
    uninstall_qt5_opengl
    install_script_message
    echo "
Qt5.15.2 LTS with OpenGL for Raspberry
======================================

· All credits goes to http://www.kdvelectronics.eu/
· This installs Qt5 on /usr/lib/qt5.15.2
· It also creates the qtchooser configuration file /usr/share/qtchooser/qt5.15.2-opengl.conf
· Repo at: https://github.com/koendv/qt5-opengl-raspberrypi

Installing, please wait...
"
    download_and_install "$QT5_PKG_URL"
    echo
    read -p "Do you want to install Qt-creator 4.14.1? (y/N) " response
    if [[ $response =~ [Yy] ]]; then
        download_and_install "$QT5_CREATOR_PKG_URL"
        echo -e "\nRestart or log out from the session to get the icon on Menu > Programming > QT Creator."
    fi
    exit_message
}

menu() {
    while true; do
        dialog --clear \
            --title "[ Qt5 Library ]" \
            --menu "Select from the list:" 12 70 4 \
            5.11 "Binary and get qmake command" \
            5.15.2 "LTS with OpenGL for Raspberry thks to koendv" \
            Compile "5.15.2 LTS from source code. Estimated time: 4-6 hours" \
            Exit "Exit" 2>"${INPUT}"

        menuitem=$(<"${INPUT}")

        case $menuitem in
        5.11)
            clear
            install_from_repo
            ;;
        5.15.2)
            clear
            install2
            ;;
        Compile)
            clear
            compile_menu
            ;;
        Exit) exit ;;
        esac
    done
}

menu
