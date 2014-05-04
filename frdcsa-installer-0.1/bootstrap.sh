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
    export USER="andrewdo"
    export DATA_DIR="/home/$USER/frdcsa-installer-$INSTALL_VERSION/data"
    if ! [ -d "/home/$USER" ]; then
	adduser $USER
    fi
fi


# setup a secure .ssh environment

if $INSTALL_TO_VAGRANT == true; then
    mv /home/vagrant/.ssh /home/vagrant/.ssh.old
    mkdir -p /home/vagrant/.ssh
    chmod 700 /home/vagrant/.ssh
    chown -R vagrant.vagrant /home/vagrant/.ssh
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

    # http://stackoverflow.com/questions/1202347/how-can-i-pass-a-password-from-a-bash-script-to-aptitude-for-installing-mysql

    # emacs install twittering-mode, ert

    if ! [ -x "/etc/myfrdcsa/config/perllib" ]; then
	mkdir -p /etc/myfrdcsa/config/
	    # FIXME have it write the mysql password to /etc/myfrdcsa/config/perllib
	apg -n 1 -m 16 > /etc/myfrdcsa/config/perllib
	chown $USER.$USER /etc/myfrdcsa/config/perllib
	chmod 600 /etc/myfrdcsa/config/perllib
    fi

    export PASS=`cat /etc/myfrdcsa/config/perllib`
    export DEBIAN_FRONTEND=noninteractive
    apt-get -q -y install mysql-server mysql-client
    echo "Give mysql server time to start up before we try to set a password..."
    sleep 5

    mysql -uroot -e <<EOF
EOSQL "UPDATE mysql.user SET Password=PASSWORD('$PASS') WHERE User='root'; FLUSH PRIVILEGES;"
EOSQL
echo "Done setting mysql password."
EOF
    unset DEBIAN_FRONTEND
fi

if ! [ -d "/var/lib/myfrdcsa/codebases" ]; then
    mkdir -p /var/lib/myfrdcsa/codebases
    chown -R $USER.$USER /var/lib/myfrdcsa
fi

cd /var/lib/myfrdcsa/codebases

if ! grep -q "Host posi.frdcsa.org" /home/$USER/.ssh/config; then
    echo -e "Host posi.frdcsa.org\n\tStrictHostKeyChecking no\n" >> /home/$USER/.ssh/config
    chown $USER.$USER /home/$USER/.ssh/authorized_keys /home/$USER/.ssh/id_rsa /home/$USER/.ssh/config
    cp $DATA_DIR/frdcsa_git_id_rsa /home/$USER/.ssh/id_rsa
    chown $USER.$USER /home/$USER/.ssh/id_rsa
fi

if ! [ -d "/var/lib/myfrdcsa/codebases/releases" ]; then
    su $USER -c "git clone ssh://readonly@posi.frdcsa.org/gitroot/releases"
fi

if ! [ -d "/var/lib/myfrdcsa/codebases/minor" ]; then
    su $USER -c "git clone ssh://readonly@posi.frdcsa.org/gitroot/minor"
fi

cd /home/$USER

if ! [ -d "/home/$USER/.myconfig" ]; then
    su $USER -c "git clone ssh://readonly@posi.frdcsa.org/gitroot/.myconfig"
fi

if ! grep myfrdcsa .bashrc; then
    mv /home/$USER/.emacs.d /home/$USER/.emacs.d.old
    su $USER -c "/home/$USER/.myconfig/bin/install-myconfig.pl"
fi

if ! [ -d "/var/lib/myfrdcsa/codebases/internal" ]; then
    # run the script for updating the perl links
    su $USER -c "mkdir -p /var/lib/myfrdcsa/codebases/internal/"
    su $USER -c "/var/lib/myfrdcsa/codebases/releases/myfrdcsa-0.1/myfrdcsa-0.1/scripts/gen-internal-links.pl"
fi

# verify creation
if ! [ -h "/var/lib/myfrdcsa/codebases/internal/myfrdcsa" ]; then
    echo "ERROR: gen internal links failed, exiting."
    exit 1
fi

if ! [ -h "/usr/share/perl5/MyFRDCSA" ]; then
    /var/lib/myfrdcsa/codebases/internal/myfrdcsa/scripts/gen-perl-links.pl
fi


if ! [ -x "/root/.cpan" ]; then
    # setup CPAN

    # have it configure it by default

    # FIXME: switch to cpanm
    export PERL_MM_USE_DEFAULT=1
    cpan -J
fi

if ! [ -d "/var/lib/myfrdcsa/codebases/data/" ]; then

    su $USER -c "mkdir -p /var/lib/myfrdcsa/codebases/data/"

    # create all the data dirs as required

    su $USER -c "/var/lib/myfrdcsa/codebases/internal/myfrdcsa/scripts/gen-data-dirs.pl"
fi

# if ! [ -d "/home/$USER/.config/frdcsa/" ]; then
#     su $USER -c "mkdir -p /home/$USER/.config/frdcsa/"
#     # have it write the mysql
# fi

cd /var/lib/myfrdcsa/codebases/internal/kbfs/data

if ! [ -d "/var/lib/myfrdcsa/codebases/internal/kbfs/data/mysql-backups" ]; then
    su $USER -c "mkdir /var/lib/myfrdcsa/codebases/internal/kbfs/data/mysql-backups"
fi

cd /var/lib/myfrdcsa/codebases/internal/kbfs/data/mysql-backups

if ! [ -d "/var/lib/myfrdcsa/codebases/internal/kbfs/data/mysql-backups/mysql-backup" ]; then
    su $USER -c "git clone ssh://readonly@posi.frdcsa.org/gitroot/mysql-backup"

    if ! [ -d "mysql-backup" ]; then
	echo "ERROR: failed to clone mysql-backup, exiting."
	exit 1
    fi
fi

export TEMP_IDENTIFIER=`cat /etc/myfrdcsa/config/perllib`
cd mysql-backup
if ! echo show databases | mysql -u root --password="$TEMP_IDENTIFIER" | grep unilang; then
    for it in `ls -1 *.sql | sed -e 's/\.sql//'`; do
	echo $it ; 
	echo "create database \`$it\`;" | mysql -u root --password="$TEMP_IDENTIFIER" ; 
	cat $it.sql | mysql -u root --password="$TEMP_IDENTIFIER" $it ; 
    done
fi



if ! [ -d "$DATA_DIR/frdcsa-misc" ]; then
    cd /home/$USER
    su $USER -c "git clone ssh://readonly@posi.frdcsa.org/gitroot/frdcsa-misc"
fi

FILE_STAT_INSTALLED=`perldoc -l File::Signature`
if $FILE_STAT_INSTALLED == "" || ! [ -f $FILE_STAT_INSTALLED ]; then
    # DONE: FIXME: manually install File::Stat
    cd /tmp && tar xzf $DATA_DIR/frdcsa-misc/File-Stat-0.01.tar.gz 
    cd File-Stat-0.01/
    perl Makefile.PL
    make
    make install
fi

if false; then
    # FIXME: alter install-script-dependencies run apt-get with -y etc when run with NONINTERACTIVE=true
    /var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies "/var/lib/myfrdcsa/codebases/internal/unilang/start -s -u localhost 9000 -c"
    /var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies "/var/lib/myfrdcsa/codebases/internal/unilang/scripts/web-services/server -u -t XMLRPC"
    /var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies "/var/lib/myfrdcsa/codebases/internal/manager/manager -u --scheduler"

    cd /var/lib/myfrdcsa/codebases/minor/spse
    /var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies "./spse2 -l"

    cd /usr/local/share/perl

    # update this patch to work with the latest version of Tk::GraphViz

    # FIXME: copy the modified patch to the gitroot, along with other modifications
    sudo patch -p0 -i /var/lib/myfrdcsa/codebases/minor/spse/Tk-GraphViz.pm.patch
fi

if ! [ -d "/var/lib/myfrdcsa/codebases/data/freekbs2/theorem-provers" ]; then
    # scp -r andrewdo@justin.frdcsa.org:/var/lib/myfrdcsa/codebases/data/freekbs2/theorem-provers .
    cd /var/lib/myfrdcsa/codebases/data/freekbs2
    sudo cp -ar $DATA_DIR/frdcsa-misc/theorem-provers .
fi

# # get SPSE2 running

if ! [ -d "/var/lib/myfrdcsa/sandbox" ]; then
    su $USER -c "mkdir /var/lib/myfrdcsa/sandbox"
fi

if ! [ -d "/var/lib/myfrdcsa/sandbox/opencyc-4.0/opencyc-4.0" ]; then
    # scp -r andrewdo@justin.frdcsa.org:/var/lib/myfrdcsa/codebases/data/freekbs2/theorem-provers .
    su $USER -c "mkdir /var/lib/myfrdcsa/sandbox/opencyc-4.0"
    cd /var/lib/myfrdcsa/sandbox/opencyc-4.0
    su $USER -c "cp -ar $DATA_DIR/frdcsa-misc/opencyc-4.0 ."
fi

# FIXME: do everything to properly install inline java
# have JAVA_HOME correctly asserted

# INSTALL Inline::Java

# # note if kbs2 isn't getting very far, try running this next line again
if true; then
    /var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies /var/lib/myfrdcsa/codebases/minor/spse/scripts/test-use.pl
    /var/lib/myfrdcsa/codebases/minor/package-installation-manager/scripts/install-cpan-modules -f Text::Quote
    /var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies "/var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/kbs2 -c Org::FRDCSA::Verber::PSEx2::Do fast-import do2.kbs"


    cd /var/lib/myfrdcsa/codebases/minor/spse
    # do something about having to constantly close the GUI to get
    # this to work, add some kill switch inside or preinstall the
    # modules.
    /var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies "spse2 -c Org::FRDCSA::Verber::PSEx2::Do"
fi

# FIXME: not installing properly
FILE_SIGNATURE_INSTALLED=`perldoc -l File::Signature`
if $FILE_SIGNATURE_INSTALLED == "" || ! [ -f $FILE_SIGNATURE_INSTALLED ]; then
    cpanm -f File::Signature
fi

if true; then
    cd /var/lib/myfrdcsa/codebases/internal/boss && /var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies boss
    boss etags
fi

# sudo netstat -tulpn
# start unilang

# # figure out how to get the script files into the path

# #### only do this if we didn't install a private install

cd /var/lib/myfrdcsa/codebases/minor/spse
/var/lib/myfrdcsa/codebases/minor/package-installation-manager/scripts/install-cpan-modules Graph::Directed
/var/lib/myfrdcsa/codebases/minor/package-installation-manager/scripts/install-cpan-modules Ubigraph
/var/lib/myfrdcsa/codebases/minor/package-installation-manager/scripts/install-cpan-modules Cal::DAV
/var/lib/myfrdcsa/codebases/minor/package-installation-manager/scripts/install-cpan-modules Net::Google::Calendar

if ! $PRIVATE_INSTALL; then

    cd /var/lib/myfrdcsa/codebases/minor/spse/kbs
    /var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/kbs2 -c Org::FRDCSA::Verber::PSEx2::Do fast-import do2.kbs
    /var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/kbs2 -c Org::PICForm::PIC::Vis::Metadata fast-import metadata.kbs
fi



# ### if private
# ### scp -r 192.168.1.200:.config/frdcsa .

# @ /var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies ./spse2

# # if the environment is 64 bit, do 
# @ sudo dpkg --add-architecture ia32




# # get FRDCSA Applet working

# @ pushd /var/lib/myfrdcsa/codebases/minor/frdcsa-dashboard/data
# @ scp -r andrewdo@justin.frdcsa.org:/var/lib/myfrdcsa/codebases/minor/frdcsa-dashboard/data .
# @ mv data/* .
# @ rmdir data

# @ pushd /var/lib/myfrdcsa/codebases/minor/frdcsa-dashboard/xo
# @ /var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies "./frdcsa-applet"

# # put the stuff in /etc/init.d
# @ (frdcsa-applet &)



# # scp -r 192.168.1.200:.config/frdcsa .

# # for corpus
# rsync -av justin.frdcsa.org:/var/lib/myfrdcsa/sandbox/meteor-0.6/ /var/lib/myfrdcsa/sandbox/meteor-0.6/

# ################## continue later







# # fix the username for this file, or fix the whole concept

# # # sudo apt-get install super

# sudo cp /var/lib/myfrdcsa/codebases/internal/unilang/systems/etc/init.d/unilang /etc/init.d
# sudo chmod 755 /etc/init.d/unilang 
# sudo update-rc.d unilang defaults

# # copy ?the?
# # add frdcsa-applet to the startup applications

# mkdir -p ~/.config/frdcsa/frdcsa-applet
# mkdir -p ~/.config/frdcsa/spse2
# cp /var/lib/myfrdcsa/codebases/minor/spse/spse2.conf  ~/.config/frdcsa/spse2

# # # test
# # sudo /etc/init.d/unilang start

# # # # sudo shutdown -r now

# pushd /var/lib/myfrdcsa/
# sudo mkdir datasets
# sudo chown andrewdo.andrewdo datasets


# # for workhorse
# @ mkdir -p /var/lib/myfrdcsa/codebases/minor/corpus-manager/data/corpora/gutenberg
# @ pushd /var/lib/myfrdcsa/codebases/minor/workhorse/scripts
# @ chmod +x ./process-corpus.pl
# @ sudo apt-get install liblink-grammar4 liblink-grammar4-dev link-grammar link-grammar-dictionaries-en
# # @ sudo ln -s /usr/include/link-grammar/ /usr/local/include
# @ sudo cp -ar /usr/include/link-grammar/ /usr/local/include

# @ sudo chown andrewdo.andrewdo /var/lib/myfrdcsa
# @ mkdir /var/lib/myfrdcsa/sandbox
# @ mkdir /var/lib/myfrdcsa/codebases/external
# @ scp -r justin.frdcsa.org:/var/lib/myfrdcsa/sandbox/termex-1.49 /var/lib/myfrdcsa/sandbox
# @ pushd /var/lib/myfrdcsa/sandbox/termex-1.49/termex-1.49
# @ perl Makefile.PL
# @ sudo make install

# # @ pushd /var/lib/myfrdcsa/codebases/minor/paperless-office && /var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies ./paperless-office

# popd

# @ /var/lib/myfrdcsa/codebases/minor/package-installation-manager/scripts/install-cpan-modules Module::Build
# @ /var/lib/myfrdcsa/codebases/minor/package-installation-manager/scripts/install-cpan-modules WWW::Mechanize::Cached
# @ /var/lib/myfrdcsa/codebases/minor/package-installation-manager/scripts/install-cpan-modules Yahoo::Search

# /var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies ./process-corpus.pl

# @ /var/lib/myfrdcsa/codebases/minor/package-installation-manager/scripts/install-cpan-modules Archive::Zip

# pushd /var/lib/myfrdcsa/codebases/minor/nlu/systems/annotation
# /var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies ./process-2.pl 

# sudo apt-get install wordnet wordnet-base wordnet-gui libwordnet-querydata-perl
# # install-cpan-modules WordNet::QueryData
# pushd /var/lib/myfrdcsa/codebases/internal/corpus
# /var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies './corpus -h'

# mysql
# > create database sayer_nlu;
# > create database sayer_nlu_textanalysis;

# # now need to copy over all files related to getting various
# # textanalysis items working, such as montylingua, etc

# # areas to improve

# # the .myconfig stuff
# # the database copying and installation
# # the installation of SPSE2-related perl modules




# @ pushd /var/lib/myfrdcsa/codebases/internal/verber/data
# @ scp -r andrewdo@justin.frdcsa.org:/var/lib/myfrdcsa/codebases/internal/verber/data/ .


# # to get 'boss search' working

# namazu2 namazu2-index-tools


# # generally useful but optional
# sudo apt-get install apt-file


# # for clear
if ! [ -d "/etc/clear" ]; then
    cd /etc
    cp -ar $DATA_DIR/frdcsa-misc/etc/clear .
fi
apt-get install -y festival
cd /var/lib/myfrdcsa/codebases/internal/clear && install-script-dependencies "cla -r /var/lib/myfrdcsa/codebases/minor/action-planner/OConnor.pdf"

# cd /var/lib/myfrdcsa/codebases/internal/clear && install-script-dependencies "cla -r <INSERTPDFFILEHERE>"
# sudo apt-get install festival
# sudo scp -r justin.frdcsa.org:/etc/clear /etc












# # for workhorse

# sudo apt-get install libuima-addons-java libuima-addons-java-doc libuima-as-java libuima-as-java-doc libuima-adapter-soap-java libuima-adapter-vinci-java libuima-core-java libuima-cpe-java libuima-document-annotation-java libuima-tools-java libuima-vinci-java uima-doc uima-examples uima-utils


# # as of 20130422

# mkdir /var/lib/myfrdcsa/codebases/internal/boss/data/namazu

# # to get academician

# # verber
# # install-script-dependencies /var/lib/myfrdcsa/codebases/internal/verber
