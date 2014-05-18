I apologize for the incoherence of this README.txt

This is the installer for version 1.1 of the FRDCSA.  It will be
adapted when the version 1.1 is actually finished to work with that.
Right now it is really more of an installer for 1.0, but that has been
copied to the 1.1 installer for now.

Before you install, please edit the bootstrap.sh script and choose
whether you want to install to a Vagrant VM or to the "HOST" computer.
The host simply means it is not a vagrant VM, it can still be a VM.

You may choose this by reversing these boolean values.  Please don't
set both to true or both to false.

export INSTALL_TO_VAGRANT=false
export INSTALL_TO_HOST=true

To install, you have to run the ./bootstrap.sh script.  This will get
part of the way through the installation.  It is going to take some
more development to get it to go all the way.

You may also wish to first create a USER and set the value, if you
don't want it to be installed as user andrewdo.  Please note that in
the unreleased 1.0 version it often assumes the directory is owned or
somehow related to the andrewdo.andrewdo user.group.  We need to fix
this to make the whole project work with any user name and any group.
For starters, it is being moved to the .frdcsa .group.

You will need to run the installer repeatedly, and get it unstuck
based on the error messages it gives.

Currently install-script-dependencies, which runs frequently, does not
force installation or .debs or cpan modules, which we are going to
change.  Also, when installing certain GUI elements, such as SPSE2, it
may require you to repeatedly close the application once it has been
opened in order for it to figure out which Tk etc libraries are
missing.  This will be fixed down the road.

Please unzip copy the installer to ~/frdcsa-installer, or change the
value of DATA_DIR to point to the frdcsa-installer/data directory.

The installer currently assumes an ubuntu environment for the Vagrant
installer.  And most likely a Debian derivative for the "host"
installer.

If installing to Vagrant, please edit the vagrant file and point the
id_rsa keys to the appropriate directory.

Please generate an id_rsa and an id_rsa.pub for use with the Vagrant
machine.  And place them in the data dir, so the bootstrap script can
install them, and secure the vagrant VM.

You should also probably put some kind of key into the file
data/frdcsa_git_id_rsa in order for it to access the git repository.

More later.

