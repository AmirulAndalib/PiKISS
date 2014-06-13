#!/bin/bash
#
# Description : Install a Framework,CMS to the web server
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.3 (12/Jun/14)
#
# Help        · Wordpress: https://github.com/raspberrypi/documentation/blob/master/usage/wordpress.md
#             ·     Ghost: http://geekytheory.com/ghost-blog-en-raspberry-pi/
#             ·   PyPlate: http://pplware.sapo.pt/linux/dica-como-ter-o-seu-proprio-site-no-raspberry-pi/
#
clear

read -p "Unfinished. You can end the script and submit to PiKiSS Git repo. Press [ENTER]..."
exit

wordpress(){
    cd /var/www
    sudo chown $USER: .
    wget https://wordpress.org/latest.tar.gz
    tar xzf latest.tar.gz
    rm latest.tar.gz
    echo "Installed on /wordpress folder"
}

read -p "Wordpress (latest)? (y/n)" option
case "$option" in
    y*) wordpress ;;
esac