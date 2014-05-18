#!/usr/bin/env bash

export NONINTERACTIVE=true
export PRIVATE_INSTALL=false

# FIXME: make the installer idempotent

export INSTALL_TO_VAGRANT=false
export INSTALL_TO_HOST=true

export INSTALLER_VERSION=0.1

if $INSTALL_TO_VAGRANT == true; then
    export USER="vagrant"
    export DATA_DIR="/vagrant/data"
elif $INSTALL_TO_HOST == true; then
    export USER="picform"
    export DATA_DIR="/home/$USER/picform-installer-$INSTALL_VERSION/data"
    if ! [ -d "/home/$USER" ]; then
	adduser $USER
    fi
fi


# setup a secure .ssh environment

if $INSTALL_TO_VAGRANT == true; then
    echo not now
    # mv /home/vagrant/.ssh /home/vagrant/.ssh.old
    # mkdir -p /home/vagrant/.ssh
    # chmod 700 /home/vagrant/.ssh
    # chown -R vagrant.vagrant /home/vagrant/.ssh
elif $INSTALL_TO_HOST == true; then
    echo nothing to do for now
fi

	# setup a proper sources.list
if $INSTALL_TO_VAGRANT == true; then
    cp $DATA_DIR/sources.list /etc/apt
    cat $DATA_DIR/id_rsa.pub >> /home/$USER/.ssh/authorized_keys
fi

if ! dpkg -l | grep -q mysql-server; then
    apt-get update

    # FIXME: add something here to abort installation if it detects that it will remove any packages
    
    apt-get install -y git emacs apg libclass-methodmaker-perl w3m-el mew bbdb nmap super libssl-dev chase libxml2-dev link-grammar liblink-grammar4 liblink-grammar4-dev screen cpanminus perl-doc libssl-dev bbdb openjdk-7-jdk libxml-atom-perl

if ! [ -d "/var/lib/myfrdcsa/codebases/releases" ]; then
    su $USER -c "git clone ssh://readonly@posi.frdcsa.org/gitroot/picform"
fi

