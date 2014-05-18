#!/bin/bash

#########################################

echo "Welcome to the Meta-Installer."
echo

source "projects.sh"

echo "Note: The Runtime environment consists of the system itself, as
would be installed on a user's machine.  The Hosting environment is
for if you want to fork the entire project, and includes installing
(possibly several) Vagrant virtual machines.  The Testing environment
involves setting up a Vagrant machine which hosts the Hosting
environment."

echo

PS3='Please choose Environment to install: '
options=( "Runtime" "Hosting" "Testing" "Quit" )
select opt in "${options[@]}"
do
    case $opt in
	"Runtime")
	    echo "You chose the Runtime environment."
	    export INSTALLATION_TYPE="Runtime"
	    break
	    ;;
	"Hosting")	
	    echo "You chose the Hosting environment."
	    export INSTALLATION_TYPE="Hosting"
	    break
	    ;;
	"Testing")
	    echo "You chose the Testing environment."
	    export INSTALLATION_TYPE="Testing"
	    break
	    ;;
	"Quit")
	    echo "Exiting."
	    exit
	    ;;
	*) echo invalid option;;
    esac
done

#########################################

# CHECKS

# check to see if there is sufficient disk space for everything
# FIXME: skip for now

export ARCH=`uname -m`
# select package version

if [ `which apt-get | grep apt-get` ]; then
    export PACKAGE_FORMAT="deb"
    export INSTALLATION_PROGRAM="dpkg -i "
    export PACKAGE_MANAGEMENT_PROGRAM="apt-get install "
elif [ `which rpm | grep rpm` ]; then
    export PACKAGE_FORMAT="rpm"
    export INSTALLATION_PROGRAM="rpm -i "
    export PACKAGE_MANAGEMENT_PROGRAM="yum install "
fi

# INSTALL VAGRANT IF NECESSARY

if [ $INSTALLATION_TYPE == "Hosting" ] || [ $INSTALLATION_TYPE == "Testing" ]; then

# check to see if vagrant is installed on the current machine
    if ! [ `which vagrant | grep vagrant` ]; then

	echo "We need to install Vagrant"
	PS3='Do you want to install Vagrant using the package management system, or download from the Vagrant Website?: '
	options=( "Package Management System" "Vagrant Website" "Quit" )
	select opt in "${options[@]}"
	do
	    case $opt in
		"Package Management System")
		    echo "You chose the Package Management System"
		    sudo $PACKAGE_MANAGEMENT_PROGRAM vagrant
		    if ! [ `which vagrant | grep vagrant` ]; then
			export INSTALL_VAGRANT_FROM_WEBSITE=1
		    fi
		    break
		    ;;
		"Vagrant Website")
		    echo "You chose the Vagrant Website"
		    export INSTALL_VAGRANT_FROM_WEBSITE=1
		    break
		    ;;
		"Quit")
		    echo "Exiting."
		    exit
		    ;;
		*) echo invalid option;;
	    esac
	done
    fi

    if [ $INSTALL_VAGRANT_FROM_WEBSITE == 1 ]; then

        #########################################

        # CONFIGURATION

	export VAGRANT_VERSION="1.6.2"

        # FIXME: add windows and mac support
	VAGRANT_PACKAGE_FILE_PREFIX_A="vagrant_$VAGRANT_VERSION";
	VAGRANT_PACKAGE_FILE_PREFIX_B="_$ARCH.$PACKAGE_FORMAT"
	export VAGRANT_PACKAGE_FILE=$VAGRANT_PACKAGE_FILE_PREFIX_A$VAGRANT_PACKAGE_FILE_PREFIX_B
	export VAGRANT_PACKAGE_URL="https://dl.bintray.com/mitchellh/vagrant/$VAGRANT_PACKAGE_FILE"

        #########################################

        # INSTALLATION
	if [ -x "/usr/bin/wget" ]; then
	    export DOWNLOAD_PROGRAM="wget"
	elif [ -x "/usr/bin/curl" ]; then
	    export DOWNLOAD_PROGRAM="curl"
	else
	    echo "No download program found"
	    exit
	fi

        # download the latest version of vagrant
	# cd /tmp && $DOWNLOAD_PROGRAM $VAGRANT_PACKAGE_URL

	export DOWNLOAD_LOCATION="/tmp/$VAGRANT_PACKAGE_FILE"
	echo $DOWNLOAD_LOCATION
	if [ -e $DOWNLOAD_LOCATION ]; then
	    # FIXME test to make sure installed okay
	    # sudo $INSTALLATION_PROGRAM $DOWNLOAD_LOCATION
	    echo hey
	else
	    echo "Could not find downloaded file"
	    exit
	fi
    fi

    if ! [ `which vagrant | grep vagrant` ]; then
	echo "Could not install Vagrant"
	exit
    fi
fi

#########################################

if ! [ `which git | grep git` ]; then
    sudo $PACKAGE_MANAGEMENT_PROGRAM git
fi

if ! [ `which git | grep git` ]; then
    echo "Could not install git"
    exit
fi

#########################################

if [ `which vagrant | grep vagrant` ]; then
    if [ $ARCH == "i686" ]; then
	echo "Detected an i686 architecture, using 32 bit VMs."
	export VAGRANT_ARCH="32"
    elif [ $ARCH == "x86_64" ]; then
	echo "Detected an x86_64 architecture."
	PS3='Please choose Architecture to install on to install: '
	options=( "Runtime" "Hosting" "Testing" "Quit" )
	select opt in "${options[@]}"
	do
	    case $opt in
		"i686")
    		    echo "You chose i686"
    		    export VAGRANT_ARCH="32"
		    break
    		    ;;
		"x86_64")
    		    echo "You chose x86_64"
    		    export VAGRANT_ARCH="64"
		    break
    		    ;;
		"Quit")
    		    echo "Exiting."
    		    exit
    		    ;;
		*) echo invalid option;;
	    esac
	done
    fi

    # export META_INSTALLER_DEFAULT_VAGRANT_BOX="precise$VAGRANT_ARCH"
    # vagrant box add $SYSTEM http://files.vagrantup.com/$SYSTEM.box

fi

#########################################

# PLATFORMS


#########################################

fi

# sudo mkdir /var/lib/meta-installer
# cd /var/lib/meta-installer

