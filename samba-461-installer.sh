#!/bin/bash

# Date : 2017-03-23
# Verion 0.5 amd64 only.
#
# creator : L.P.H. van Belle
# email : louis@van-belle.nl
#
# Use at own risk.

# ! Due to CVE these packages are signed.
# ! the packages are for AMD64 only

# How are these packages build?
# These build is based on Debian Stretch 4.5.x, but i use the samba.org source to create these packages."
# And they are created in a pbuilder environment.
# These packages are not signed and marked as -nmu (NMU stands for : non maintainer upload)

# I only sign the -bpo package or when im ok with production use.
# These packages need testing first, please report your result on the samba list.
# When i sign them i'll put them in my apt repo, info here : apt.van-belle.nl
# Samba version 4.5.3 is in my repo now.

# ! If you used the previous script, the file : /etc/apt/sources.list.d/samba-test.list
# ! Is recreated with the new samba version number in it. 

# The download location
SET_DOWNLOAD_LOCATION="http://downloads.van-belle.nl/samba4/samba-4.6.1"

# A place to put the downloaded files, so if we rerun the script its not downloading again.
SET_DOWNLOAD_SAVE_TO_FOLDER="/home/samba-dwnld"

# Some small info about this installer
# if you use "all" as first parameter, you get the full packages ( amd64 and i386 )
# Example : bash samba-461-install.sh all
# Use this one if you want to deploy to multple machine ( preffered over http(s) ).
#
# If you dont use any parameter you get the samba based on your "architecture" and only i386 and amd64 are supported.
#
# The download location, if you get the full package, you can put the file on your own web server.
# and change this to your own location, preffered a location very server has access too.
# Now just change the "SET_DOWNLOAD_LOCATION"

I_DID_READ_THIS="no"

################## CODE #################
# make sure this is being run by root
USER=$(whoami)
if [ "$USER" != "root" ]; then
    echo "$(basename $0) must be run by root or with sudo"
    exit 1
fi

if [ "${I_DID_READ_THIS}" = "no" ] ; then
    echo "Please read the info in this script and set the parameter : I_DID_READ_THIS=\"no\" to yes "
    echo " "
    exit 0
fi

if [ -e /etc/os-release ]; then
    source /etc/os-release
    echo "Detected ID = $ID "
    echo " "
    if [ "${ID}" != "debian" ]; then
        echo "Sorry, these packages are created for and on Debian Jessie 8.x. "
        exit 1
    fi
elif [ -e /etc/debian_version ]; then
    SET_VERSION=$(cat /etc/debian_version | awk -F"." {'print $1'})
    if [ "${SET_VERSION}" != "8" ]; then
        echo "Sorry, these packages are created for and on Debian Jessie 8.x "
        exit 1
    fi
fi

echo " "
echo "------------ WARNING, EXPERIMENTAL PACKAGES, USE WITH CARE ------------- "
echo " "
echo "Samba 4.6.1 test installer for debian jessie (amd64 and i386) NOT SIGNED"
echo " "

if [ ! -d ${SET_DOWNLOAD_SAVE_TO_FOLDER} ]; then
    echo "Creating download folder"
    mkdir -p ${SET_DOWNLOAD_SAVE_TO_FOLDER}
    echo " "
fi

SET_ARCH=$(arch)
if [ ${SET_ARCH} = "x86_64" ]; then
    SET_ARCH="amd64"
elif [ "${SET_ARCH}" = "i686" ] || [ "${SET_ARCH}" = "i586" ] || [ "${SET_ARCH}" = "i486" ] || [ "${SET_ARCH}" = "i386" ]; then
    SET_ARCH="i386"
	echo "Sorry, i386 isnt supported yet, only amd64."
	exit 1
fi

echo "Arch is set to : ${SET_ARCH}"
echo "Saving downloaded files to : ${SET_DOWNLOAD_SAVE_TO_FOLDER} "

if [ "${1}" = "all" ]; then
    if [ ! -e ${SET_DOWNLOAD_SAVE_TO_FOLDER}/jessie-samba-461.tar.gz ]; then
        wget -q --no-check-certificate  ${SET_DOWNLOAD_LOCATION}/jessie-samba-461.tar.gz -O "${SET_DOWNLOAD_SAVE_TO_FOLDER}/jessie-samba-461.tar.gz" --show-progress
    else
        echo "Package : jessie-samba-461.tar.gz was already downloaded"
    fi

    mkdir -p /var/www/html/debian/jessie-samba-461 2>/dev/null

    tar -xf ${SET_DOWNLOAD_SAVE_TO_FOLDER}/jessie-samba-461.tar.gz -C /var/www/html/debian/
    echo "deb [trusted=yes] file:/var/www/html/debian/jessie-samba-461 ${SET_ARCH}/" > /etc/apt/sources.list.d/samba-test.list
else
    if [ ! -e ${SET_DOWNLOAD_SAVE_TO_FOLDER}/samba-4.6.1-${SET_ARCH}.tar.gz ]; then
        wget -q --no-check-certificate  ${SET_DOWNLOAD_LOCATION}/samba-4.6.1-${SET_ARCH}.tar.gz -O "${SET_DOWNLOAD_SAVE_TO_FOLDER}/samba-4.6.1-${SET_ARCH}.tar.gz" --show-progress
    else
        echo "Package : jessie-samba-461.tar.gz was already downloaded"
    fi

    mkdir -p /var/www/html/debian/jessie-samba-461 2>/dev/null

    tar -xf ${SET_DOWNLOAD_SAVE_TO_FOLDER}/samba-4.6.1-${SET_ARCH}.tar.gz -C /var/www/html/debian/jessie-samba-461
    echo "deb [trusted=yes] file:/var/www/html/debian/jessie-samba-461 ${SET_ARCH}/" > /etc/apt/sources.list.d/samba-test.list
fi

echo "Samba packages are extracted to the folder : /var/www/html/debian/jessie-samba-461"
echo "Created the apt file : /etc/apt/sources.list.d/samba-test.list"
echo " "
echo "Make sure if you change things, keep the following in your apt sources"
echo "The : [trusted=yes]  is needed because i did not sign these packages"
echo "The line MUST have amd64/ "
echo "The this has todo with the apt-ftparchive command below."
echo " "
echo "You can change this by createing a new packages file in the folder where the deb's are."
echo "These are the commands used for the current packages: "
echo " "
echo "cd /var/www/html/debian/jessie-samba-461"
echo "apt-ftparchive packages amd64/. > amd64/Packages"

echo "Good luck with testing, please report problems to the samba list"
echo ""
echo "Now run : "
echo "sudo apt-get update && sudo apt-cache policy samba"
echo "You should see samba 4.6.1 in the list now"
