#!/bin/bash

if [ `whoami` != root ];
then 
    echo "Must be run as root\n";
    exit
fi

export META_INSTALLER_CONFIG_FILE="meta-installer.conf"
source $META_INSTALLER_CONFIG_FILE

# Meta Installer that installs the vagrant bootstrapper

mkdir -p $META_INSTALL_PROJECT_MAIN_DIR/vagrant-machines
chown -R $META_INSTALLER_PROJECT_USER.$META_INSTALLER_PROJECT_USER $META_INSTALL_PROJECT_MAIN_DIR

cd $META_INSTALL_PROJECT_MAIN_DIR

# mkdir tmp
# cd tmp
# wget $META_INSTALL_LATEST_VAGRANT_DEB
# # FIXME add ability to use different systems, like redhat
# sudo dpkg -i vagrant_*.deb
# # INSTALL GIT
# # FIXME add ability to use different systems, like redhat
# sudo apt-get install -y git

cd $META_INSTALL_PROJECT_MAIN_DIR

# CREATE THE DIRECTORY STRUCTURE

git clone $META_INSTALLER_URI

# ADD A BASE BOX (DEBIAN) FOR VAGRANT

# Use Ubuntu for now until we figure out how to use a Debian box with
# vagrant

vagrant box add $META_INSTALLER_DEFAULT_VAGRANT_BOX $META_INSTALLER_DEFAULT_VAGRANT_BOX_URI

if [ $META_INSTALLER_INSTALL_VAGRANT_BOOTSTRAP == 1 ]; then
    echo "Installing Vagrant"
else
    echo "Not Installing Vagrant"
	# We assume that since we are running this meta-installer
	# script, we don't need to install the Vagrant Bootstrap
	# machine (as that would be an endless regression).  This is
	# probably the Vagrant Bootstrap machine itself.

fi

# Iterate over the directories and set them up as wanted.

# Read from a configuration file, located in /vagrant or elsewhere.

# for $DIR in $META_INSTALLER_MACHINES {
# if not meta-installer
#       cd $DIR
#       vagrant init $DEFAULT_VAGRANT_BOX
# 	vagrant up
# }
