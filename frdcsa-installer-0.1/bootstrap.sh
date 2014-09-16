#!/usr/bin/env bash

export UPDATE_REPOS=false

export NONINTERACTIVE=true
export PERL_MM_USE_DEFAULT=1

export PRIVATE_INSTALL=false

export THE_SOURCE="/var/lib/myfrdcsa/codebases/releases/myfrdcsa-0.1/myfrdcsa-0.1/frdcsa.bashrc"

# FIXME: make the installer idempotent

export INSTALL_TO_VAGRANT=true
export INSTALL_TO_HOST=false

if [[ $INSTALL_TO_VAGRANT == true && $INSTALL_TO_HOST == true ]] ||
    [[ $INSTALL_TO_VAGRANT == false && $INSTALL_TO_HOST == false ]]; then
    echo "Currently only one must be true at a time of INSTALL_TO_VAGRANT and INSTALL_TO_HOST"
    exit 1
fi

if $INSTALL_TO_VAGRANT == true; then
    export USER="vagrant"
    export GROUP="vagrant"
    export DATA_DIR="/vagrant/data"
elif $INSTALL_TO_HOST == true; then
    export USER="andrewdo"
    export GROUP="andrewdo"
    export DATA_DIR="/home/$USER/frdcsa-installer/data"
    if ! [ -d "/home/$USER" ]; then
	adduser $USER
    fi
fi


# setup a secure .ssh environment

if $INSTALL_TO_VAGRANT == true; then
    if [ ! -d /home/vagrant/.ssh.old ]; then
	mv /home/vagrant/.ssh /home/vagrant/.ssh.old
	mkdir -p /home/vagrant/.ssh
	chmod 700 /home/vagrant/.ssh
	chown -R vagrant.vagrant /home/vagrant/.ssh
    fi
elif $INSTALL_TO_HOST == true; then
    echo nothing to do for now
fi

# setup a proper sources.list
if $INSTALL_TO_VAGRANT == true; then
    # cp $DATA_DIR/sources.list /etc/apt

    # FIXME: add something here to make it idempotent
    if ! grep -q 'andrewdo@justin' /home/$USER/.ssh/authorized_keys; then
	cat $DATA_DIR/id_rsa.pub >> /home/$USER/.ssh/authorized_keys
    fi
fi

if ! dpkg -l | grep xclip | grep -q '^ii'; then
    apt-get update
    apt-get install -y git emacs apg libclass-methodmaker-perl w3m-el mew bbdb nmap super libssl-dev chase libxml2-dev link-grammar liblink-grammar4 liblink-grammar4-dev screen cpanminus perl-doc libssl-dev bbdb openjdk-7-jdk libxml-atom-perl namazu2 namazu2-index-tools apt-file x11-apps dlocate xclip
fi

if ! dpkg -l | grep -E 'mysql-server-[0-9]+' | grep -q '^ii'; then
    

    # FIXME: add something here to abort installation if it detects that it will remove any packages
    
    

    # http://stackoverflow.com/questions/1202347/how-can-i-pass-a-password-from-a-bash-script-to-aptitude-for-installing-mysql

    # emacs install twittering-mode, ert

    if [ ! -x "/etc/myfrdcsa/config/perllib" ]; then
	mkdir -p /etc/myfrdcsa/config/
	# FIXME have it write the mysql password to /etc/myfrdcsa/config/perllib
	apg -n 1 -m 16 > /etc/myfrdcsa/config/perllib
	chown $USER.$GROUP /etc/myfrdcsa/config/perllib
	chmod 600 /etc/myfrdcsa/config/perllib
    fi

    export PASS=`cat /etc/myfrdcsa/config/perllib`

    export DEBIAN_FRONTEND=noninteractive

    # debconf-set-selections <<< "mysql-server-5.1 mysql-server/root_password password $PASS"
    # debconf-set-selections <<< "mysql-server-5.1 mysql-server/root_password_again password $PASS"

    apt-get -q -y install mysql-server mysql-client

    echo "Give mysql server time to start up before we try to set a password..."
    sleep 5

    mysql -uroot <<EOF
UPDATE mysql.user SET Password=PASSWORD('$PASS') WHERE User='root'; FLUSH PRIVILEGES;
EOF

    # echo "Give mysql server time to start up before we try to set a password..."
    # sleep 5
    # mysql -uroot -e <<EOF
    # EOSQL "UPDATE mysql.user SET Password=PASSWORD('$PASS') WHERE User='root'; FLUSH PRIVILEGES;"
    # EOSQL
    # echo "Done setting mysql password."
    # EOF

    unset DEBIAN_FRONTEND
fi

if [ ! -d "/var/lib/myfrdcsa/codebases" ]; then
    mkdir -p /var/lib/myfrdcsa/codebases
    chown -R $USER.$GROUP /var/lib/myfrdcsa
fi

cd /var/lib/myfrdcsa/codebases

if ! grep -q "Host posi.frdcsa.org" /home/$USER/.ssh/config; then
    echo -e "Host posi.frdcsa.org\n\tStrictHostKeyChecking no\n" >> /home/$USER/.ssh/config
    chown $USER.$GROUP /home/$USER/.ssh/authorized_keys /home/$USER/.ssh/config
    cp $DATA_DIR/frdcsa_git_id_rsa /home/$USER/.ssh/id_rsa
    chown $USER.$GROUP /home/$USER/.ssh/id_rsa
    chmod 600 /home/$USER/.ssh/id_rsa
fi

if [ ! -d "/var/lib/myfrdcsa/codebases/releases" ]; then
    su $USER -c "git clone ssh://readonly@posi.frdcsa.org/gitroot/releases"
else
    if [ $UPDATE_REPOS == true ]; then
	pushd /var/lib/myfrdcsa/codebases/releases
	su $USER -c "git pull"
	popd
    fi
fi
if [ ! -d "/var/lib/myfrdcsa/codebases/releases" ]; then
    echo "ERROR: Didn't check out /var/lib/myfrdcsa/codebases/releases"
    exit 1
fi

if [ ! -d "/var/lib/myfrdcsa/codebases/minor" ]; then
    su $USER -c "git clone ssh://readonly@posi.frdcsa.org/gitroot/minor"
else
    if [ $UPDATE_REPOS == true ]; then
	pushd /var/lib/myfrdcsa/codebases/minor
	su $USER -c "git pull"
	popd
    fi
fi
if [ ! -d "/var/lib/myfrdcsa/codebases/minor" ]; then
    echo "ERROR: Didn't check out /var/lib/myfrdcsa/codebases/minor"
    exit 1
fi

cd /home/$USER

if [ ! -d "/home/$USER/.myconfig" ]; then
    su $USER -c "git clone ssh://readonly@posi.frdcsa.org/gitroot/.myconfig"
else
    if [ $UPDATE_REPOS == true ]; then
	pushd /home/$USER/.myconfig
	su $USER -c "git pull"
	popd
    fi
fi
if [ ! -d "/home/$USER/.myconfig" ]; then
    echo "ERROR: Didn't check out /home/$USER/.myconfig"
    exit 1
fi

export DATETIMESTAMP=`date "+%Y%m%d%H%M%S"`

if ! grep myfrdcsa .bashrc; then
    mv /home/$USER/.bashrc /home/$USER/.bashrc.$DATETIMESTAMP
    mv /home/$USER/.emacs.d /home/$USER/.emacs.d.$DATETIMESTAMP
    su $USER -c "/home/$USER/.myconfig/bin/install-myconfig.pl"
fi
if ! grep myfrdcsa .bashrc; then
    echo "ERROR: Didn't install /home/$USER/.myconfig correctly"
    exit 1
fi

if [ ! -d "/var/lib/myfrdcsa/codebases/internal" ]; then
    # run the script for updating the perl links
    su $USER -c "mkdir -p /var/lib/myfrdcsa/codebases/internal/"
    su $USER -c "/var/lib/myfrdcsa/codebases/releases/myfrdcsa-0.1/myfrdcsa-0.1/scripts/gen-internal-links.pl"
fi
if [ ! -h "/var/lib/myfrdcsa/codebases/internal/myfrdcsa" ]; then
    echo "ERROR: gen internal links failed, exiting."
    exit 1
fi

if [ ! -h "/usr/share/perl5/MyFRDCSA" ]; then
    /var/lib/myfrdcsa/codebases/internal/myfrdcsa/scripts/gen-perl-links.pl
fi
if [ ! -h "/usr/share/perl5/MyFRDCSA" ]; then
    echo "ERROR: gen perl links failed, exiting."
    exit 1
fi

if [ ! -x "/root/.cpan" ]; then
    # setup CPAN
    # have it configure it by default
    # FIXME: switch to cpanm
    cpan -J
fi
if [ ! -x "/root/.cpan" ]; then
    echo "ERROR: didn't configure CPAN."
    exit 1
fi

if [ ! -d "/var/lib/myfrdcsa/codebases/data/" ]; then
    su $USER -c "mkdir -p /var/lib/myfrdcsa/codebases/data/"
    # create all the data dirs as required
    su $USER -c "/var/lib/myfrdcsa/codebases/internal/myfrdcsa/scripts/gen-data-dirs.pl"
fi
if [ ! -d "/var/lib/myfrdcsa/codebases/data/" ]; then
    echo "ERROR: gen data dirs failed, exiting."
    exit 1
fi

if $PRIVATE_INSTALL; then
    if [ ! -h /home/$USER/.config/frdcsa ]; then
	cd /home/$USER
	mkdir -p .config
	chown $USER.$GROUP .config
	cd .config
	su $USER -c "git clone ssh://andrewdo@192.168.1.220/gitroot/frdcsa-private"
	ln -s frdcsa-private frdcsa
    else
	if [ $UPDATE_REPOS == true ]; then
	    pushd /home/$USER/.config/frdcsa-private
	    su $USER -c "git pull"
	    popd
	fi
    fi
    if [ ! -h /home/$USER/.config/frdcsa ]; then
	echo "ERROR: didn't checkout /home/$USER/.config/frdcsa properly, exiting."
	exit 1
    fi
else
    if [ ! -h /home/$USER/.config/frdcsa ]; then
	cd /home/$USER
	mkdir -p .config
	chown $USER.$GROUP .config
	cd .config
	su $USER -c "git clone ssh://readonly@posi.frdcsa.org/gitroot/frdcsa-public"
	ln -s frdcsa-public frdcsa
    else
	if [ $UPDATE_REPOS == true ]; then
	    pushd /home/$USER/.config/frdcsa-public
	    su $USER -c "git pull"
	    popd
	fi
    fi
    if [ ! -h /home/$USER/.config/frdcsa ]; then
	echo "ERROR: didn't checkout /home/$USER/.config/frdcsa properly, exiting."
	exit 1
    fi
fi

cd /var/lib/myfrdcsa/codebases/internal/kbfs/data

if [ ! -d "/var/lib/myfrdcsa/codebases/internal/kbfs/data/mysql-backups" ]; then
    su $USER -c "mkdir /var/lib/myfrdcsa/codebases/internal/kbfs/data/mysql-backups"
fi
if [ ! -d "/var/lib/myfrdcsa/codebases/internal/kbfs/data/mysql-backups" ]; then
    echo "ERROR: didn't make /var/lib/myfrdcsa/codebases/internal/kbfs/data/mysql-backups properly, exiting."
    exit 1
fi

cd /var/lib/myfrdcsa/codebases/internal/kbfs/data/mysql-backups

if [ ! -d "/var/lib/myfrdcsa/codebases/internal/kbfs/data/mysql-backups/mysql-backup" ]; then
    su $USER -c "git clone ssh://readonly@posi.frdcsa.org/gitroot/mysql-backup"
else
    if [ $UPDATE_REPOS == true ]; then
	pushd /var/lib/myfrdcsa/codebases/internal/kbfs/data/mysql-backups/mysql-backup
	su $USER -c "git pull"
	popd
    fi
fi
if ! [ -d "/var/lib/myfrdcsa/codebases/internal/kbfs/data/mysql-backups/mysql-backup" ]; then
    echo "ERROR: failed to clone mysql-backup, exiting."
    exit 1
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
if ! echo show databases | mysql -u root --password="$TEMP_IDENTIFIER" | grep unilang; then
    echo "ERROR: databases apparently didn't load"
    exit 1
fi

if [ ! -d "$DATA_DIR/frdcsa-misc/etc" ]; then
    cd $DATA_DIR
    su $USER -c "git clone ssh://readonly@posi.frdcsa.org/gitroot/frdcsa-misc"
else
    if [ $UPDATE_REPOS == true ]; then
	pushd $DATA_DIR/frdcsa-misc
	su $USER -c "git pull"
	popd
    fi
fi
if [ ! -d "$DATA_DIR/frdcsa-misc/etc" ]; then
    echo "ERROR: didn't checkout frdcsa-misc properly"
    exit 1
fi

export TMP_PERL_MM_OPT=$PERL_MM_OPT
export PERL_MM_OPT=

if ! perldoc -l File::Signature; then
    cpanm -f File::Signature
fi

export PERL_MM_OPT=$TMP_PERL_MM_OPT

if ! perldoc -l File::Signature; then
    echo "ERROR: didn't install File::Signature correctly"
    exit 1
fi

if ! perldoc -l File::Stat; then
    # DONE: FIXME: manually install File::Stat
    cd /tmp && tar xzf $DATA_DIR/frdcsa-misc/File-Stat-0.01.tar.gz 
    cd File-Stat-0.01/
    perl Makefile.PL
    make
    make install
fi
if ! perldoc -l File::Stat; then
    echo "ERROR: didn't install File::Stat correctly"
    exit 1
fi

if [ ! -f "/etc/init.d/unilang" ]; then
    cat /var/lib/myfrdcsa/codebases/internal/unilang/systems/etc/init.d/unilang | perl -pe "s/<USERNAME>/$USER/sg" > /etc/init.d/unilang
    sudo chmod 755 /etc/init.d/unilang 
    sudo update-rc.d unilang defaults
fi

# /etc/init.d/unilang restart

echo "Stopping UniLang"
/etc/init.d/unilang stop
killall start unilang unilang-client

echo "Starting UniLang"
/etc/init.d/unilang start
sleep 5
if ! /var/lib/myfrdcsa/codebases/internal/unilang/scripts/check-if-unilang-is-running.pl; then

    echo "Stopping UniLang"
    /etc/init.d/unilang stop
    killall start unilang unilang-client

    cd /var/lib/myfrdcsa/codebases/internal/unilang

    echo "Starting UniLang"


    # echo '/etc/init.d/unilang stop; killall start unilang unilang-client' | at now + 2 minutes
    (sleep 10; /etc/init.d/unilang stop; killall start unilang unilang-client) &

    while /var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies "./start -s -u localhost 9000 -c -W 5000"; do
	(sleep 10; /etc/init.d/unilang stop; killall start unilang unilang-client) &
    done

    sleep 11

    echo "Stopped UniLang"
else
    echo "Stopping UniLang"
    /etc/init.d/unilang stop
    killall start unilang unilang-client
fi

/etc/init.d/unilang start
sleep 5

echo "Starting web-services"
su $USER -c "source $THE_SOURCE && cd /var/lib/myfrdcsa/codebases/internal/unilang && install-script-dependencies \"./scripts/web-services/server -u -t XMLRPC -W 10000\""

echo "Starting Manager"
su $USER -c "source $THE_SOURCE && cd /var/lib/myfrdcsa/codebases/internal/manager && install-script-dependencies \"./manager -u --scheduler -W 10000\""

echo "Stopping UniLang"
/etc/init.d/unilang stop
killall start unilang unilang-client

if ! [ -d "/var/lib/myfrdcsa/codebases/data/freekbs2/theorem-provers" ]; then
    # scp -r andrewdo@justin.frdcsa.org:/var/lib/myfrdcsa/codebases/data/freekbs2/theorem-provers .
    cd /var/lib/myfrdcsa/codebases/data/freekbs2
    cp -ar $DATA_DIR/frdcsa-misc/theorem-provers .
fi
if ! [ -d "/var/lib/myfrdcsa/codebases/data/freekbs2/theorem-provers" ]; then
    echo "ERROR: Didn't set up freekbs2 theorem-provers properly"
    exit 1
fi

# # get SPSE2 running

if ! [ -d "/var/lib/myfrdcsa/sandbox" ]; then
    # su $USER -c "mkdir /var/lib/myfrdcsa/sandbox"
    mkdir /var/lib/myfrdcsa/sandbox
    chown -R $USER.$GROUP /var/lib/myfrdcsa/sandbox
fi
if ! [ -d "/var/lib/myfrdcsa/sandbox" ]; then
    echo "ERROR: Didn't set up sandbox properly"
    exit 1
fi

if ! [ -d "/var/lib/myfrdcsa/sandbox/opencyc-4.0/opencyc-4.0" ]; then
    su $USER -c "mkdir /var/lib/myfrdcsa/sandbox/opencyc-4.0"
    cd /var/lib/myfrdcsa/sandbox/opencyc-4.0
    su $USER -c "cp -ar $DATA_DIR/frdcsa-misc/opencyc-4.0 ."
fi
if ! [ -d "/var/lib/myfrdcsa/sandbox/opencyc-4.0/opencyc-4.0" ]; then
    echo "ERROR: Didn't set up opencyc-4.0 properly"
    exit 1
fi


# FIXME: do everything to properly install inline java
# have JAVA_HOME correctly asserted

# INSTALL Inline::Java

# # note if kbs2 isn't getting very far, try running this next line again

# /var/lib/myfrdcsa/codebases/minor/package-installation-manager/scripts/install-cpan-modules -f Text::Quote

export TMP_PERL_MM_OPT=$PERL_MM_OPT
export PERL_MM_OPT=

if ! perldoc -l Text::Quote; then
    cpanm --force Text::Quote
fi

export PERL_MM_OPT=$TMP_PERL_MM_OPT

if ! perldoc -l Text::Quote; then
    echo "ERROR: Text::Quote did not install"
    exit 1
fi


export TMP_PERL_MM_OPT=$PERL_MM_OPT
export PERL_MM_OPT=

if ! perldoc -l Tk::GraphViz; then
    cpanm --force Tk::GraphViz
fi

export PERL_MM_OPT=$TMP_PERL_MM_OPT

if ! perldoc -l Tk::GraphViz; then
    echo "ERROR: Tk::GraphViz did not install"
    exit 1
fi

export TMP_PERL_MM_OPT=$PERL_MM_OPT
export PERL_MM_OPT=

if ! perldoc -l Inline::Java; then
    cpanm --force Inline::Java
fi

export PERL_MM_OPT=$TMP_PERL_MM_OPT

if ! perldoc -l Inline::Java; then
    echo "ERROR: Inline::Java did not install"
    exit 1
fi

export TMP_PERL_MM_OPT=$PERL_MM_OPT
export PERL_MM_OPT=

if ! perldoc -l AI::Prolog; then
    cpanm --force AI::Prolog
fi

export PERL_MM_OPT=$TMP_PERL_MM_OPT

if ! perldoc -l AI::Prolog; then
    echo "ERROR: AI::Prolog did not install"
    exit 1
fi

/etc/init.d/unilang start
sleep 5

su $USER -c "source $THE_SOURCE && cd /var/lib/myfrdcsa/codebases/internal/freekbs2/scripts && install-script-dependencies \"./kbs2 -c Org::FRDCSA::Verber::PSEx2::Do fast-import do2.kbs\""

# do something about having to constantly close the GUI to get
# this to work, add some kill switch inside or preinstall the
# modules.

echo "Starting Test-use"
su $USER -c "source $THE_SOURCE && cd /var/lib/myfrdcsa/codebases/minor/spse/scripts/ && install-script-dependencies ./test-use.pl"

echo "Starting SPSE2"
su $USER -c "source $THE_SOURCE && cd /var/lib/myfrdcsa/codebases/minor/spse && install-script-dependencies \"spse2 -c Org::FRDCSA::Verber::PSEx2::Do -W 10000\""

# update this patch to work with the latest version of Tk::GraphViz
# FIXME: copy the modified patch to the gitroot, along with other modifications
cd /usr/local/share/perl
if ! grep -q 'push @{$self->{layout}}, join("",@item);' /usr/local/share/perl/5.18.1/Tk/GraphViz.pm; then 
    patch -p0 -i /var/lib/myfrdcsa/codebases/minor/spse/Tk-GraphViz.pm.patch
fi
if ! grep -q 'push @{$self->{layout}}, join("",@item);' /usr/local/share/perl/5.18.1/Tk/GraphViz.pm; then 
    echo "ERROR: couldn't patch Tk::GraphViz"
    exit 1
fi

echo "Starting SPSE2"
su $USER -c "source $THE_SOURCE && cd /var/lib/myfrdcsa/codebases/minor/spse && /var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies \"spse2 -c Org::FRDCSA::Verber::PSEx2::Do -W 10000\""

/etc/init.d/unilang stop
killall start unilang unilang-client

echo "Finishing for now";
exit 1



##############################################################################################




if true; then
    cd /var/lib/myfrdcsa/codebases/internal/boss && /var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies ./boss
    su $USER -c "mkdir -p /var/lib/myfrdcsa/codebases/internal/boss/data/namazu"
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

cd /var/lib/myfrdcsa/codebases/minor/spse/kbs
/var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/kbs2 -c Org::PICForm::PIC::Vis::Metadata fast-import metadata.kbs

if [ ! $PRIVATE_INSTALL ]; then
    cd /var/lib/myfrdcsa/codebases/minor/spse/kbs
    /var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/kbs2 -c Org::FRDCSA::Verber::PSEx2::Do fast-import do2.kbs
fi

if [ $ARCH == "x86_64" ]; then
    # dpkg --add-architecture ia32
    dpkg --add-architecture i386
fi

# # get FRDCSA Applet working

if ! [ -f "/var/lib/myfrdcsa/codebases/minor/frdcsa-dashboard/data/scater.gif" ]; then
    # scp -r andrewdo@justin.frdcsa.org:/var/lib/myfrdcsa/codebases/minor/frdcsa-dashboard/data .
    # su $USER -c "mkdir /var/lib/myfrdcsa/sandbox/opencyc-4.0"
    cd /var/lib/myfrdcsa/codebases/minor/frdcsa-dashboard/data/
    su $USER -c "cp -ar $DATA_DIR/frdcsa-misc/frdcsa-dashboard/data/* ."
fi

cd /var/lib/myfrdcsa/codebases/minor/frdcsa-dashboard/
/var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies "./frdcsa-applet -W"

# put the stuff in /etc/init.d
# @ (frdcsa-applet &) <- as of Sun Sep 14 21:58:06 CDT 2014, not sure what this is about

# for corpus

if [ ! -d "/var/lib/myfrdcsa/sandbox/meteor-0.6" ]; then
    su $USER -c "mkdir /var/lib/myfrdcsa/sandbox/meteor-0.6"
    cd /var/lib/myfrdcsa/sandbox/meteor-0.6
    su $USER -c "cp -ar $DATA_DIR/frdcsa-misc/meteor-0.6 ."
fi

# # fix the username for this file, or fix the whole concept

# copy ?the?
# add frdcsa-applet to the startup applications



# FIXME: run unilang tests and report on success

# # # sudo shutdown -r now

cd /var/lib/myfrdcsa/
mkdir datasets
chown $USER.$GROUP datasets

# for workhorse
sudo apt-get install -y liblink-grammar4 liblink-grammar4-dev link-grammar link-grammar-dictionaries-en libuima-addons-java libuima-addons-java-doc libuima-as-java libuima-as-java-doc libuima-adapter-soap-java libuima-adapter-vinci-java libuima-core-java libuima-cpe-java libuima-document-annotation-java libuima-tools-java libuima-vinci-java uima-doc uima-examples uima-utils

if [ ! -d "/var/lib/myfrdcsa/codebases/minor/corpus-manager/data/corpora/gutenberg" ]; then
    su $USER -c "mkdir -p /var/lib/myfrdcsa/codebases/minor/corpus-manager/data/corpora/gutenberg"

fi

if [ ! -d "/usr/local/include/link-grammar" ]; then
    cp -ar /usr/include/link-grammar/ /usr/local/include
fi

if [ ! -d "/var/lib/myfrdcsa/codebases/external" ]; then
    su $USER -c "mkdir -p /var/lib/myfrdcsa/codebases/external"
fi

if ! [ -d "/var/lib/myfrdcsa/sandbox/termex-1.49/termex-1.49" ]; then
    su $USER -c "mkdir /var/lib/myfrdcsa/sandbox/termex-1.49"
    cd /var/lib/myfrdcsa/sandbox/termex-1.49
    su $USER -c "cp -ar $DATA_DIR/frdcsa-misc/termex-1.49 ."
    cd termex-1.49
    su $USER -c "perl Makefile.PL"
    make install
fi

cd /var/lib/myfrdcsa/codebases/minor/paperless-office

# FIXME: do we need to add a cabinet here?
/var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies "./paperless-office -W"

/var/lib/myfrdcsa/codebases/minor/package-installation-manager/scripts/install-cpan-modules Module::Build
/var/lib/myfrdcsa/codebases/minor/package-installation-manager/scripts/install-cpan-modules WWW::Mechanize::Cached
/var/lib/myfrdcsa/codebases/minor/package-installation-manager/scripts/install-cpan-modules Yahoo::Search

cd /var/lib/myfrdcsa/codebases/minor/workhorse/scripts/
/var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies "./process-corpus.pl -W"

/var/lib/myfrdcsa/codebases/minor/package-installation-manager/scripts/install-cpan-modules Archive::Zip
cd /var/lib/myfrdcsa/codebases/minor/nlu/systems/annotation
/var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies "./process-2.pl -W"

sudo apt-get install -y wordnet wordnet-base wordnet-gui libwordnet-querydata-perl
# /var/lib/myfrdcsa/codebases/minor/package-installation-manager/scripts/install-cpan-modules WordNet::QueryData

cd /var/lib/myfrdcsa/codebases/internal/corpus
/var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies './corpus -h'

# # now need to copy over all files related to getting various
# # textanalysis items working, such as montylingua, etc

# # areas to improve

# # the .myconfig stuff
# # the database copying and installation
# # the installation of SPSE2-related perl modules

# cd /var/lib/myfrdcsa/codebases/internal/verber/data
# scp -r andrewdo@justin.frdcsa.org:/var/lib/myfrdcsa/codebases/internal/verber/data/ .


# generally useful but optional
apt-file update

# for clear
if [ ! -d "/etc/clear" ]; then
    cd /etc
    cp -ar $DATA_DIR/frdcsa-misc/etc/clear .
fi
apt-get install -y festival
cd /var/lib/myfrdcsa/codebases/internal/clear && /var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies "cla -r /var/lib/myfrdcsa/codebases/minor/action-planner/OConnor.pdf -W"

# get academician
# verber
# install-script-dependencies /var/lib/myfrdcsa/codebases/internal/verber

update-dlocatedb
updatedb

