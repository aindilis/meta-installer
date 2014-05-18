PS3='Choose Project to install: '
options=("PICForm" "FunFunctions" "FRDCSA" "Quit")
select opt in "${options[@]}"
do
case $opt in
    "PICForm")
	echo "You chose PICForm"
	export META_INSTALLER_PROJECT_NAME="PICForm"
	export GIT_REPO="https://github.com/meta-installer/PICForm"
	export VERSION=""
	break
	;;
    "FunFunctions")
	echo "You chose FunFunctions"
	export META_INSTALLER_PROJECT_NAME="FunFunctions"
	export GIT_REPO="https://github.com/meta-installer/FunFunctions"
	export VERSION=""
	break
	;;
    "FRDCSA")
	echo "You chose FRDCSA"
	export META_INSTALLER_PROJECT_NAME="FRDCSA" 
	export GIT_REPO="https://github.com/meta-installer/FRDCSA"
	export VERSION="1.1"
	break
	;;
    "Quit")
	echo "Exiting."
	exit
	;;
    *) echo invalid option;;
esac
done

echo $META_INSTALLER_PROJECT_NAME
echo $GIT_REPO
echo $VERSION