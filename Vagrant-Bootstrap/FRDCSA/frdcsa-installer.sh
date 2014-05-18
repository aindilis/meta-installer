#!/bin/sh





# we want to git clone it

mkdir doc
# obtain the latest log-as-of-YYYYMMDD.txt file, put it in doc

vagrant box add precise64 http://files.vagrantup.com/precise64.box
cd /var/lib/myfrdcsas/versions/myfrdcsa-1.1/vagrant
mkdir -p sample/vagrant-tutorial
cd sample/vagrant-tutorial
vagrant init precise64
vagrant up

# vagrant ssh

cd /var/lib/myfrdcsas/versions/myfrdcsa-1.1/vagrant/sample/vagrant-tutorial
mkdir site-cookbooks cookbooks databags
cd cookbooks

wget http://pagesofinterest.net/blog/2011/06/secure-git-server-preventing-git-user-logging-in-via-ssh/
wget https://coderwall.com/p/p3bj2a
