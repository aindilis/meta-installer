#!/usr/bin/env bash

set -v

echo "Installer for Debian Wheezy"

export UPDATE_REPOS=true

export NONINTERACTIVE=true
export PERL_MM_USE_DEFAULT=1

export PRIVATE_INSTALL=false

export THE_SOURCE="/var/lib/myfrdcsa/codebases/releases/myfrdcsa-0.1/myfrdcsa-0.1/frdcsa.bashrc"

# FIXME: make the installer idempotent

export INSTALL_TO_VAGRANT=true
export INSTALL_TO_HOST=false

if [[ $INSTALL_TO_VAGRANT == true && $INSTALL_TO_HOST == true ]] ||
    [[ $INSTALL_TO_VAGRANT == false && $INSTALL_TO_HOST == false ]]; then
    echo "ERROR: Currently only one must be true at a time of INSTALL_TO_VAGRANT and INSTALL_TO_HOST"
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

export APT_UPDATED=0

if [ $APT_UPDATED == 0 ]; then
    apt-get update
    export export APT_UPDATED=1
fi
apt-get install -y build-essential git emacs apg libclass-methodmaker-perl w3m-el mew bbdb nmap super libssl-dev chase libxml2-dev link-grammar liblink-grammar4 liblink-grammar4-dev screen cpanminus perl-doc libssl-dev bbdb openjdk-7-jdk libxml-atom-perl namazu2 namazu2-index-tools apt-file x11-apps dlocate xclip libb-utils-perl libcal-dav-perl libconfig-general-perl libdata-dump-streamer-perl libfile-slurp-perl libfile-which-perl libgetopt-declare-perl libgraph-perl libpadwalker-perl libproc-processtable-perl libstring-shellquote-perl libstring-similarity-perl libtask-weaken-perl libterm-readkey-perl libtie-ixhash-perl libtk-perl libunicode-map8-perl libunicode-string-perl libxml-atom-perl libxml-dumper-perl libxml-perl libxml-twig-perl libnet-telnet-perl liblink-grammar4 liblink-grammar4-dev link-grammar link-grammar-dictionaries-en libuima-addons-java libuima-addons-java-doc libuima-as-java libuima-as-java-doc libuima-adapter-soap-java libuima-adapter-vinci-java libuima-core-java libuima-cpe-java libuima-document-annotation-java libuima-tools-java libuima-vinci-java uima-doc uima-examples uima-utils wordnet wordnet-base wordnet-gui libwordnet-querydata-perl festival wamerican-insane libevent-perl libfile-pid-perl libxml-smart-perl libnet-dbus-perl

if ! dpkg -l | grep wamerican-insane | grep -q '^ii'; then
    echo "ERROR: first major group of packages did not install"
    exit 1
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

    if [ $APT_UPDATED == 0 ]; then
	apt-get update
	export export APT_UPDATED=1
    fi
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

cpanm Try::Tiny Path::Class ExtUtils::CBuilder Crypt::SSLeay RPC::XML Module::Load RPC::XML ExtUtils::MakeMaker PPI File::Remove Test::Object Test::NoWarnings Test::Tester Test::NoWarnings Test::SubCalls Hook::LexWrap Test::SubCalls IO::String Clone Class::Inspector PPI Data::SExpression Test::Deep Data::SExpression Data::URIEncode Lingua::EN::Sentence X11::WMCtrl Mail::Box IO::stringy Object::Realize::Later Test::Pod Digest::HMAC User::Identity MIME::Types Devel::GlobalDestruction Sub::Exporter::Progressive Devel::GlobalDestruction Mail::Box Ubigraph Frontier::RPC Ubigraph Net::Google::Calendar DateTime::Format::ICal DateTime::Event::ICal DateTime::Event::Recurrence DateTime::Set Set::Infinite DateTime::Set DateTime::Event::Recurrence DateTime::Event::ICal DateTime::Format::ICal Net::Google::AuthSub Date::ICal Date::Leapyear Date::ICal Net::Google IPC::Run3 # Net::SSL Crypt::SSLeay

export PERL_MM_OPT=$TMP_PERL_MM_OPT

if ! perldoc -l Crypt::SSLeay; then
    echo "ERROR: CPANM modules did not install"
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

export TMP_PERL_MM_OPT=$PERL_MM_OPT
export PERL_MM_OPT=

if ! perldoc -l Dir::List; then
    cpanm -f Dir::List
fi

export PERL_MM_OPT=$TMP_PERL_MM_OPT

if ! perldoc -l Dir::List; then
    echo "ERROR: didn't install Dir::List correctly"
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

######################################################################################3

echo "STARTING INSTALLATION OF UNILANG: PROCESS IS CONFUSING, PLEASE WAIT UP TO 15 MINUTES FOR IT TO COMPLETE (until you see 'INSTALLATION OF UNILANG COMPLETE')"

if [ ! -f "/etc/init.d/unilang" ]; then
    cat /var/lib/myfrdcsa/codebases/internal/unilang/systems/etc/init.d/unilang | perl -pe "s/<USERNAME>/$USER/sg" > /etc/init.d/unilang
    sudo chmod 755 /etc/init.d/unilang 
    sudo update-rc.d unilang defaults
fi

echo "Stopping UniLang in case it was already running from a previous run of the provisioning script"
/etc/init.d/unilang stop
killall start unilang unilang-client

# export UNILANG_START_DURATION=5
# export UNILANG_INSTALL_SLEEP_DURATION=45
# let UNILANG_INSTALL_SLEEP_DURATION_PLUS_WAIT=$UNILANG_INSTALL_SLEEP_DURATION+5
# export UNILANG_INSTALL_SLEEP_DURATION_PLUS_WAIT

# echo "Starting UniLang to test if it works"
# /etc/init.d/unilang start
# sleep $UNILANG_START_DURATION
# if ! /var/lib/myfrdcsa/codebases/internal/unilang/scripts/check-if-unilang-is-running.pl; then

#     echo "Stopping whatever was running of UniLang after testing if it works"
#     /etc/init.d/unilang stop
#     killall start unilang unilang-client

#     cd /var/lib/myfrdcsa/codebases/internal/unilang

#     echo "Installing UniLang"


#     # FIXME: not working, have to check for whatever processes, like
#     # cpan, cpanm or apt-get are running and if those are still
#     # running to delay longer

#     # echo '/etc/init.d/unilang stop; killall start unilang unilang-client' | at now + 2 minutes

#     /var/lib/myfrdcsa/codebases/internal/perllib/scripts/install-helper.pl -d $UNILANG_INSTALL_SLEEP_DURATION -c "killall install-script-dependencies" -m "Setting timed stopper, duration $UNILANG_INSTALL_SLEEP_DURATION"

#     echo "Trying to launch UniLang to try to get dependencies"

#     CURRENT_NONINTERACTIVE=$NONINTERACTIVE
#     NONINTERACTIVE=true

#     LOOP=true
#     while $LOOP; do
# 	echo "Trying..."
# 	echo `pwd`
# 	if /var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies "./start -s -u localhost 9000 -c -W 5000"; then
# 	    LOOP=false
# 	fi
#     done

#     NONINTERACTIVE=$CURRENT_NONINTERACTIVE

#     echo "Ok, UniLang exited successfully, cleaning up"
#     killall install-helper.pl

# else
#     echo "UniLang is already installed and running; stopping UniLang"
#     /etc/init.d/unilang stop
#     killall start unilang unilang-client
# fi

cd /var/lib/myfrdcsa/codebases/internal/unilang/ && /var/lib/myfrdcsa/codebases/internal/unilang/scripts/install-unilang.pl

if ! /var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/install-script-dependencies "./start -s -u localhost 9000 -c -W 5000"; then
    echo "ERROR: Installation of Unilang failed"
    exit 1
fi

echo "INSTALLATION OF UNILANG COMPLETE"

######################################################################################3

echo "UniLang starting up again to install subsequent agents"
/etc/init.d/unilang start
sleep $UNILANG_START_DURATION

echo "Starting web-services"
su $USER -c "source $THE_SOURCE && cd /var/lib/myfrdcsa/codebases/internal/unilang && NONINTERACTIVE=true install-script-dependencies \"./scripts/web-services/server -u -t XMLRPC -W 10000\""

echo "Starting Manager"
su $USER -c "source $THE_SOURCE && cd /var/lib/myfrdcsa/codebases/internal/manager && NONINTERACTIVE=true install-script-dependencies \"./manager -u --scheduler -W 10000\""

echo "Current batch of agents installed, stopping UniLang for now"
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

export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64

if ! perldoc -l Inline::Java; then
    cd /tmp && tar xzf $DATA_DIR/frdcsa-misc/Inline-Java-0.53.tar.gz
    cd Inline-Java-0.53
    perl Makefile.PL J2SDK=$JAVA_HOME
    make
    make install    
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

cd /var/lib/myfrdcsa/codebases/minor/spse

if ! perldoc -l Graph::Directed; then
    su $USER -c "/var/lib/myfrdcsa/codebases/minor/package-installation-manager/scripts/install-cpan-modules Graph::Directed"
fi
if ! perldoc -l Graph::Directed; then
    echo "ERROR: Graph::Directed did not install"
    exit 1
fi

if ! perldoc -l Ubigraph; then
    su $USER -c "/var/lib/myfrdcsa/codebases/minor/package-installation-manager/scripts/install-cpan-modules Ubigraph"
fi
if ! perldoc -l Ubigraph; then
    echo "ERROR: Ubigraph did not install"
    exit 1
fi

if ! perldoc -l Cal::DAV; then
    su $USER -c "/var/lib/myfrdcsa/codebases/minor/package-installation-manager/scripts/install-cpan-modules Cal::DAV"
fi
if ! perldoc -l Cal::DAV; then
    echo "ERROR: Cal::DAV did not install"
    exit 1
fi

if ! perldoc -l Net::Google::Calendar; then
    su $USER -c "/var/lib/myfrdcsa/codebases/minor/package-installation-manager/scripts/install-cpan-modules Net::Google::Calendar"
fi
if ! perldoc -l Net::Google::Calendar; then
    echo "ERROR: Net::Google::Calendar did not install"
    exit 1
fi

/etc/init.d/unilang start
sleep $UNILANG_START_DURATION

echo "Starting Test-use"
su $USER -c "source $THE_SOURCE && cd /var/lib/myfrdcsa/codebases/minor/spse/scripts/ && NONINTERACTIVE=true install-script-dependencies ./test-use.pl"

if ! /var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/kbs2 -l | grep -q Org::FRDCSA::Verber::PSEx2::Do; then
    # NOTE THIS must be preceded by install-script-dependencies ./test-use.pl
    su $USER -c "source $THE_SOURCE && cd /var/lib/myfrdcsa/codebases/internal/freekbs2/scripts && NONINTERACTIVE=true install-script-dependencies \"./kbs2 -y -c Org::FRDCSA::Verber::PSEx2::Do fast-import /var/lib/myfrdcsa/codebases/minor/spse/kbs/do2.kbs\""
fi
if ! /var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/kbs2 -l | grep -q Org::FRDCSA::Verber::PSEx2::Do; then
    echo "ERROR: Org::FRDCSA::Verber::PSEx2::Do did not load"
    exit 1
fi

# do something about having to constantly close the GUI to get
# this to work, add some kill switch inside or preinstall the
# modules.

if ! /var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/kbs2 -l | grep -q Org::PICForm::PIC::Vis::Metadata; then
    cd /var/lib/myfrdcsa/codebases/minor/spse/kbs
    echo y | /var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/kbs2 -c Org::PICForm::PIC::Vis::Metadata fast-import metadata.kbs
fi
if ! /var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/kbs2 -l | grep -q Org::PICForm::PIC::Vis::Metadata; then
    echo "ERROR: Org::PICForm::PIC::Vis::Metadata did not load"
    exit 1
fi

# if ! /var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/kbs2 -l | grep -q Org::FRDCSA::Verber::PSEx2::Do; then
#     cd /var/lib/myfrdcsa/codebases/minor/spse/kbs
#     echo y | /var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/kbs2 -c Org::FRDCSA::Verber::PSEx2::Do fast-import do2.kbs
# fi
# if ! /var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/kbs2 -l | grep -q Org::FRDCSA::Verber::PSEx2::Do; then
#     echo "ERROR: Org::FRDCSA::Verber::PSEx2::Do did not load"
#     exit 1
# fi

echo "Starting SPSE2"
su $USER -c "source $THE_SOURCE && cd /var/lib/myfrdcsa/codebases/minor/spse && XAUTHORITY=/home/$USER/.Xauthority NONINTERACTIVE=trueinstall-script-dependencies \"spse2 -c Org::FRDCSA::Verber::PSEx2::Do -W 10000\""

# # update this patch to work with the latest version of Tk::GraphViz
# # FIXME: copy the modified patch to the gitroot, along with other modifications
# cd /usr/local/share/perl
# if [ ! -f /usr/local/share/perl/5.18.1/Tk/GraphViz.pm ] || ! grep -q 'push @{$self->{layout}}, join("",@item);' /usr/local/share/perl/5.18.1/Tk/GraphViz.pm; then 
#     patch -p0 -i /var/lib/myfrdcsa/codebases/minor/spse/Tk-GraphViz.pm.patch
# fi
# if [ ! -f /usr/local/share/perl/5.18.1/Tk/GraphViz.pm ] || ! grep -q 'push @{$self->{layout}}, join("",@item);' /usr/local/share/perl/5.18.1/Tk/GraphViz.pm; then 
#     echo "ERROR: couldn't patch Tk::GraphViz"
#     exit 1
# fi

export TMP_PERL_MM_OPT=$PERL_MM_OPT
export PERL_MM_OPT=

if ! perldoc -l Tk::Month; then
    cpanm -f Tk::Month
fi
export PERL_MM_OPT=$TMP_PERL_MM_OPT

if ! perldoc -l Tk::Month; then
    echo "ERROR: didn't install Tk::Month correctly"
    exit 1
fi

echo "Starting SPSE2"
su $USER -c "source $THE_SOURCE && cd /var/lib/myfrdcsa/codebases/minor/spse && NONINTERACTIVE=true install-script-dependencies \"spse2 -c Org::FRDCSA::Verber::PSEx2::Do -W 20000\""

# /etc/init.d/unilang stop
# killall start unilang unilang-client

su $USER -c "source $THE_SOURCE && cd /var/lib/myfrdcsa/codebases/internal/boss && NONINTERACTIVE=true install-script-dependencies \"./boss\""
su $USER -c "mkdir -p /var/lib/myfrdcsa/codebases/internal/boss/data/namazu"


# sudo netstat -tulpn
# start unilang

# # figure out how to get the script files into the path

# #### only do this if we didn't install a private install

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
if ! [ -f "/var/lib/myfrdcsa/codebases/minor/frdcsa-dashboard/data/scater.gif" ]; then
    echo "ERROR: Did not properly copy frdcsa-dashboard"
    exit 1
fi

su $USER -c "source $THE_SOURCE && cd /var/lib/myfrdcsa/codebases/minor/frdcsa-dashboard/ && NONINTERACTIVE=true install-script-dependencies \"./frdcsa-applet -W\""

# put the stuff in /etc/init.d
# @ (frdcsa-applet &) <- as of Sun Sep 14 21:58:06 CDT 2014, not sure what this is about

# for corpus

if [ ! -d "/var/lib/myfrdcsa/sandbox/meteor-0.6" ]; then
    su $USER -c "mkdir /var/lib/myfrdcsa/sandbox/meteor-0.6"
    cd /var/lib/myfrdcsa/sandbox/meteor-0.6
    su $USER -c "cp -ar $DATA_DIR/frdcsa-misc/meteor-0.6 ."
fi
if [ ! -d "/var/lib/myfrdcsa/sandbox/meteor-0.6" ]; then
    echo "ERROR: Did not copy meteor-0.6 properly"
    exit 1
fi

# # fix the username for this file, or fix the whole concept

# copy ?the?
# add frdcsa-applet to the startup applications


# FIXME: run unilang tests and report on success

# # # sudo shutdown -r now

cd /var/lib/myfrdcsa/
mkdir -p datasets
chown $USER.$GROUP datasets

su $USER -c "mkdir -p /var/lib/myfrdcsa/codebases/minor/corpus-manager/data/corpora/gutenberg"

if [ ! -d "/usr/local/include/link-grammar" ]; then
    cp -ar /usr/include/link-grammar/ /usr/local/include
fi
if [ ! -d "/usr/local/include/link-grammar" ]; then
    echo "ERROR: link-grammar did not copy"
    exit 1
fi

export TMP_PERL_MM_OPT=$PERL_MM_OPT
export PERL_MM_OPT=

if ! perldoc -l Lingua::LinkParser; then
    cpanm -f Lingua::LinkParser
fi
export PERL_MM_OPT=$TMP_PERL_MM_OPT

if ! perldoc -l Lingua::LinkParser; then
    echo "ERROR: didn't install Lingua::LinkParser correctly"
    exit 1
fi

su $USER -c "mkdir -p /var/lib/myfrdcsa/codebases/external"

if ! [ -d "/var/lib/myfrdcsa/sandbox/termex-1.49/termex-1.49" ]; then
    su $USER -c "mkdir /var/lib/myfrdcsa/sandbox/termex-1.49"
    cd /var/lib/myfrdcsa/sandbox/termex-1.49
    su $USER -c "cp -ar $DATA_DIR/frdcsa-misc/termex-1.49 ."
    cd termex-1.49
    su $USER -c "perl Makefile.PL"
    make install
fi
if ! [ -d "/var/lib/myfrdcsa/sandbox/termex-1.49/termex-1.49" ]; then
    echo "ERROR: termex did not install"
    exit 1
fi

if ! [ -d "/var/lib/myfrdcsa/sandbox/stanford-ner-20080306/stanford-ner-20080306" ]; then
    su $USER -c "mkdir /var/lib/myfrdcsa/sandbox/stanford-ner-20080306"
    cd /var/lib/myfrdcsa/sandbox/stanford-ner-20080306
    su $USER -c "cp -ar $DATA_DIR/frdcsa-misc/stanford-ner-20080306 ."
fi
if ! [ -d "/var/lib/myfrdcsa/sandbox/stanford-ner-20080306/stanford-ner-20080306" ]; then
    echo "ERROR: Stanford-Ner-20080306 did not copy"
    exit 1
fi

if ! [ -d "/var/lib/myfrdcsa/sandbox/montylingua-2.1/montylingua-2.1" ]; then
    su $USER -c "mkdir /var/lib/myfrdcsa/sandbox/montylingua-2.1"
    cd /var/lib/myfrdcsa/sandbox/montylingua-2.1
    su $USER -c "cp -ar $DATA_DIR/frdcsa-misc/montylingua-2.1 ."
fi
if ! [ -d "/var/lib/myfrdcsa/sandbox/montylingua-2.1/montylingua-2.1" ]; then
    echo "ERROR: MontyLingua 2.1 did not copy"
    exit 1
fi

# FIXME: do we need to add a cabinet here?
su $USER -c "source $THE_SOURCE && cd /var/lib/myfrdcsa/codebases/minor/paperless-office && NONINTERACTIVE=true install-script-dependencies \"./paperless-office -W\""
su $USER -c "/var/lib/myfrdcsa/codebases/minor/package-installation-manager/scripts/install-cpan-modules Module::Build"
su $USER -c "/var/lib/myfrdcsa/codebases/minor/package-installation-manager/scripts/install-cpan-modules WWW::Mechanize::Cached"
su $USER -c "/var/lib/myfrdcsa/codebases/minor/package-installation-manager/scripts/install-cpan-modules -f Yahoo::Search"
su $USER -c "source $THE_SOURCE && cd /var/lib/myfrdcsa/codebases/minor/workhorse/scripts/ && NONINTERACTIVE=true install-script-dependencies \"./process-corpus.pl -W\""
su $USER -c "/var/lib/myfrdcsa/codebases/minor/package-installation-manager/scripts/install-cpan-modules Archive::Zip"

# FIXME: in order to install this have to link the wordnet dirs and install the wordnet::tools and wordnet::senserelate::allwords

# su $USER -c "source $THE_SOURCE && cd /var/lib/myfrdcsa/codebases/minor/nlu/systems/annotation && NONINTERACTIVE=true install-script-dependencies \"./process-2.pl -W\""

su $USER -c "source $THE_SOURCE && cd /var/lib/myfrdcsa/codebases/internal/corpus && NONINTERACTIVE=true install-script-dependencies \"./corpus -h\""

# for clear
if [ ! -d "/etc/clear" ]; then
    cd /etc
    cp -ar $DATA_DIR/frdcsa-misc/etc/clear .
fi
if [ ! -d "/etc/clear" ]; then
    echo "ERROR: /etc/clear did not copy"
    exit 1
fi  

# su $USER -c "source $THE_SOURCE && cd /var/lib/myfrdcsa/codebases/internal/clear && NONINTERACTIVE=true install-script-dependencies \"cla -r /var/lib/myfrdcsa/codebases/minor/action-planner/OConnor.pdf -W\""

echo "Stopping UniLang"
/etc/init.d/unilang stop
killall start unilang unilang-client

# generally useful but optional

apt-file update
update-dlocatedb
updatedb
su $USER -c "source $THE_SOURCE && cd /var/lib/myfrdcsa/codebases/internal/boss/ && ./boss updatedb -y"
su $USER -c "source $THE_SOURCE && cd /var/lib/myfrdcsa/codebases/internal/boss/ && ./boss etags -y"

# TODO

# replace all instances of cpan installation with cpanm (including in
# helper applications)

# factor out a version of the install which primarily uses
# install-script-dependencies in order to generate a more efficient
# installer using apt-get and cpanm, in order to avoid installing
# packages that are no longer required, and periodically build the
# efficient installer.



# FIXME: get the patch working

# now need to copy over all files related to getting various
# textanalysis items working, such as montylingua, etc

# areas to improve

# the .myconfig stuff
# the database copying and installation
# the installation of SPSE2-related perl modules

# cd /var/lib/myfrdcsa/codebases/internal/verber/data
# scp -r andrewdo@justin.frdcsa.org:/var/lib/myfrdcsa/codebases/internal/verber/data/ .

# get academician
# verber
# NONINTERACTIVE=true install-script-dependencies /var/lib/myfrdcsa/codebases/internal/verber

echo "Finished FRDCSA Install"
