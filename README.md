(
 (Develop the <PROJECTNAME> Vagrant Bootstrap VagrantFile which is
  hosted in a git repository, which, given a system with Vagrant
  already correctly installed, creates a virtual machine using
  vagrant which has vagrant all setup, i.e. it installs the
  packages for vagrant etc.  Give this machine a temporary working
  hostname of vagrant.<PROJECTNAME>.org)

 (Then develop the <PROJECTNAME> Hosting Platform Vagrantfile,
  which runs on vagrant.<PROJECTNAME>.org which creates several
  new VMs representing the entire <PROJECTNAME> hosting
  platform, i.e. machines like the git repository, the webserver,
  etc.  All of that (even if for starters that's just one VM
  called say hosting.<PROJECTNAME>.org))

 (Then develop the <PROJECTNAME> Installer Vagrantfile, which
  runs on the hosting.<PROJECTNAME>.org (cluster) and sets up a new
  installation of <PROJECTNAME> for end users to use)

 (From the <PROJECTNAME> Installer Vagrantfile, develop an
  installer which does not require vagrant which installs
  <PROJECTNAME> on a vanilla computer)
 )
