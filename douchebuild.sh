#!/bin/bash

underline=`tput smul`
nounderline=`tput rmul`
bolded=`tput bold`
normal=`tput sgr0`
yyn=`null`
export user=$(whoami);

echo
echo "
"
echo -e "\033[1mA few words from Cyanogen (copied from his posts of nightlies/RCs and stable cm releases)

CyanogenMod is a free, community built distribution of Android 2.3 (Gingerbread) which greatly extends the capabilities of your phone.

#include <std_disclaimer.h>
/*
 * Your warranty is now void.
 *
 * I am not responsible for bricked devices, dead SD cards,
 * thermonuclear war, or you getting fired because the alarm app failed. Please
 * do some research if you have any concerns about features included in this ROM
 * before flashing it! YOU are choosing to make these modifications, and if
 * you point the finger at me for messing up your device, I will laugh at you.
 */

\033[0m"
echo "
This is an AOSP-based build with extra contributions from many people
which you can use without any type of Google applications. I found a
link from some other project that can be used to restore the Google
parts, which can be found below or elsewhere in the thread. I've still
included the various hardware-specific code, which seems to be slowly
being open-sourced anyway.

Visit the CHANGELOG for a full list of changes and features!
http://cyanogenmod.com/changelog

All source code is available at the CyanogenMod Github!
http://github.com/CyanogenMod

If you'd like to to contribute to CyanogenMod, checkout our Gerrit
instance. http://review.cyanogenmod.com/

INSTRUCTIONS:
- First time flashing CM 7 to your N1 (or coming from another ROM)?
1. Unlock/root your device and install Clockwork Recovery via ROM Manager or Amon_RA's recovery image: http://forum.xda-developers.com/showthread.php?t=611829
2. Do a Nandroid backup!
3. Update your radio if necessary
4. WIPE
5. Install the ROM
5. Optionally install the Google Addon

- Upgrading from earlier CM7 or nightly build?
1. Do a Nandroid Backup!
2. Install the ROM (your Google apps will be backed up automatically)

HOW TO REPORT BUGS OR PROBLEMS?
- Was it a hard reboot? Get me the file "/proc/last_kmsg".
- Was it a soft reboot or a "boot loop"? Run "adb logcat" and get me the full output.
- Pastebin links preferred
- Please use the issue tracker whenever possible!

Please visit the CyanogenMod Wiki (http://wiki.cyanogenmod.com/) for
step-by-step installation walkthroughs and tons of other useful
information.

The preferred method of installation is via ROM Manager, or you can
head over to the CM Forums for manual downloads.

Thank you to EVERYONE involved in helping with testing, coding,
debugging and documenting! Enjoy!

-------------------------"
echo -e '\E[37;44m'"\033[1m
${underline}            This script only needs to be run the very first time you want to install all the CM dependencies on your computer.  If you have already done that, then stop now, and instead run the build.sh script from your desktop (e.g. - ~/Desktop/build.sh)\033[0m"
echo "
This is just a compilation of the wiki/guide given from http://wiki.cyanogenmod.com

Thank @Cyanogen and #teamdouche for the ROMs and CM7${nounderline}

This is gonna take some time and HDD space to complete.  If you don't
have the time to leave your computer running or you don't have 7GB on
your HDD, please quit and try again when the requirements (time/space)
meet the resources you have available. "

echo "
Are we clear? (y/n)"
read _clear
if [ "$_clear" != "y" ]; then echo -e '\E[37;40m'"\033[1m
You sir/madam are an #epicfail (jk). Please read the above and try again.
\033[0m"; exit 0; fi


##http://wiki.cyanogenmod.com/index.php?title=Building_from_source


cd;
echo -e '\E[37;40m'"\033[1m
                                Let's BEGIN!.
\033[0m"
echo "Please provide sudo pass"
sudo echo "ok!"

##add repo for java and get dependencies for 32bit linux
sudo add-apt-repository "deb http://archive.canonical.com/ maverick partner"
sudo apt-get update;
##apt-get files needed to build
echo -e '\E[37;40m'"\033[1m
                                Installing dependencies!.
\033[0m"

DEPENDENCIES="git-core gnupg flex bison gperf libsdl1.2-dev libesd0-dev libwxgtk2.6-dev squashfs-tools build-essential zip curl libncurses5-dev zlib1g-dev sun-java6-jdk pngcrush schedtool"

sudo apt-get install -y ${DEPENDENCIES}

##find if x64 or 32bit (uname -m)
if [ `uname -m | sed 's/x86_//;s/i[3-6]86/32/'` != "32" ]; then
   MLIBDEPS="g++-multilib lib32z1-dev lib32ncurses5-dev lib32readline5-dev gcc-4.3-multilib g++-4.3-multilib"
   sudo apt-get install -y ${MLIBDEPS}
fi

##get the sdk/adb/fastboot
echo
echo
echo Download the Android SDK/ADB needed to extract the proprietary files from your phone
echo -e '\E[37;40m'"\033[1mDo you have SDK/ADB installed?\033[0m (y/n)?"
read -n1 -p ""
echo
[[ $REPLY = [nN] ]] && 	{
		##the android-sdk name changes every time google releases a new sdk. inform me to update
		wget http://dl.google.com/android/android-sdk_r13-linux_x86.tgz;
		tar xvzf android-sdk_r*.tgz;
		mv android-sdk_r* ~/;
		cd ~/android-sdk*;
		cd tools;
		./android update sdk -u;
		./android update adb;
		cd ~/android-sdk*/platform-tools/;
		##fastboot will be downloaded from my dropbox dir. if update available please inform me
		wget http://dl.dropbox.com/u/6751304/fastboot;
		sudo cp adb /usr/bin/adb;
		sudo cp fastboot /usr/bin/fastboot;
		sudo chmod 755 /usr/bin/adb;
		sudo chmod 755 /usr/bin/fastboot;
echo -e '\E[37;40m'"\033[1m
                                ADB/Fastboot download complete!.
\033[0m"

} || echo "You already have the files, skipped";

echo
echo

cd
mkdir -p ~/bin

if [[ -d ~/android/system ]] ; then
    echo '~/android/system' 'Directory Already Exists'
else
    mkdir -p ~/android/system
fi


##get repo
curl https://raw.github.com/android/tools_repo/master/repo > ~/bin/repo
chmod a+x ~/bin/repo
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
export PATH=$PATH:$HOME/bin

cd ~/android/system/
##initialize repo
repo init -u git://github.com/CyanogenMod/android.git -b gingerbread --repo-url=git://github.com/android/tools_repo.git
echo -e '\E[37;40m'"\033[1m
                                Repo initialized! (Please note that this is gonna take emmmm... SOOOOOOOOME time to complete.
\033[0m"

repo sync -j8
while [ "$yyn" != "y" ]; do
echo -e '\E[37;40m'"\033[1m Did the repo synchronization completed successfully? (y/n) \033[0m"
read yyn
echo -e '\E[37;40m'"\033[1m Doublechecking... \033[0m"
repo sync
done
echo -e '\E[37;40m'"\033[1m
                                First sync completed! (that took some time didn't it).
\033[0m"

echo

_udev_v="skip"
_idev_p="skip"
_incompatible="0"


##FUNCTIONS
##
##	Prints vendors selection menu

vendor_menu() {
    echo "VENDORS:"
	echo 1.	Commitiva
	echo 2.	Geeksphone
	echo 3.	HTC
	echo 4.	Motorola
	echo 5.	Samsung
	echo 6.	Viewsonic
	echo 7.	ZTE
	echo 8.	LG
	echo "9. Barnes & Noble"
	echo 10. Emulator
}

## Prints HTC devices selection menu
HTCdev_menu() {
	echo "HTC DEVICES:"
	echo 1.	Ace
	echo 2.	Aria
	echo 3.	Desire CDMA
	echo 4.	Desire GSM
	echo 5.	Dream
	echo 6.	Evo 4G
	echo 7.	Glacier
	echo 8.	Hero CDMA
	echo 9.	Hero GSM
	echo 10.Incredible
	echo 11.Legend
	echo 12.Magic
	echo 13.Passion
	echo 14.Slide
	echo 15.Vision
	echo 16.Wildfire
        echo 17.Leo
        echo 18.Incredible 2
	echo "19.Tattoo/Click"
}

## Prints Samsung devices selection menu
Samsungdev_menu() {
	echo "SAMSUNG DEVICES:"
	echo 1.	Galaxy S
	echo 2.	Nexus S
	echo 3.	Captivate
	echo 4.	Vibrant
	echo 5.	Galaxy S II
	echo 6.	Fascinate
	echo 7.	Nexus S 4G

}

## Prints Motorola devices selection menu
Motodev_menu() {
	echo "MOTOROLA DEVICES:"
	echo 1.	Droid
	echo 2.	Cliq XT
	echo 3.	Droid X
}

## Prints LG devices selection menu
LGdev_menu() {
	echo "LG DEVICES:"
	echo 1.	G2x
	echo 2.	Optimus 2X
}


##VARIABLES: $_vendor , $_device , $_udev_v

##Show all vendors to select one
vendor_menu
echo
echo -n "Select Vendor (1-10, or vendor name): "
read vendor

# if not valid, then it'll be caught in the vendor case
#while [[ $vendor -lt 1 || $vendor -gt 10 ]]; do
#	echo "Selection ERROR..."
#	echo -n "Select Vendor(1-10): "
#	read vendor
#done
#echo

case  $vendor in
    1|Commitiva) echo "Vendor=Commitiva, Device=Z71"
	_vendor="Commtiva"
	_device="z71"
	_udev_v="skip"
	;;
    2|Geeksphone) echo "Vendor=Geeksphone, Device=One"
	_vendor="geeksphone"
	_device="one"
	_udev_v="skip"
	;;

## Prints HTC devices selection menu
    3|HTC) HTCdev_menu
	echo
	echo -n "Select Device(1-19): "
	read device
	while [[ $device -lt 1 || $device -gt 19 ]]; do
	    echo "Selection ERROR.."
	    echo -n "Select Device(1-19): "
	    read device
	done
	echo
	case $device in
	    1) echo "Vendor=HTC, Device=Ace"
		_vendor="htc"
		_device="ace"
		_udev_v="0bb4"
		;;
	    2) echo "Vendor=HTC, Device=Aria"
		_vendor="htc"
		_device="liberty"
		_udev_v="0bb4"
		;;
	    3) echo "Vendor=HTC, Device=Desire CDMA"
		_vendor="htc"
		_device="bravoc"
		_udev_v="0bb4"
		;;
	    4) echo "Vendor=HTC, Device=Desire GSM"
		_vendor="htc"
		_device="bravo"
		_udev_v="0bb4"
		;;
	    5) echo "Vendor=HTC, Device=Dream"
		_vendor="htc"
		_device="dream_sapphire"
		_udev_v="0bb4"
                _incompatible="dream"
		;;
	    6) echo "Vendor=HTC, Device=Evo 4G"
		_vendor="htc"
		_device="supersonic"
		_udev_v="0bb4"
		;;
	    7) echo "Vendor=HTC, Device=Glacier"
		_vendor="htc"
		_device="glacier"
		_udev_v="0bb4"
		;;
	    8) echo "Vendor=HTC, Device=Hero CDMA"
		_vendor="htc"
		_device="heroc"
		_udev_v="0bb4"
		_idev_p="0c9a"
		;;
	    9) echo "Vendor=HTC, Device=Hero GSM"
		_vendor="htc"
		_device="hero"
		_udev_v="0bb4"
		_idev_p="0c99"
		;;
	    10) echo "Vendor=HTC, Device=Incredible"
		_vendor="htc"
		_device="inc"
		_udev_v="skip"
		sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"0bb4\", ATTRS{idProduct}==\"0ff9\", MODE=\"0666\", OWNER=\"$user\" #Normal dinc' >> /etc/udev/rules.d/51-android.rules"
		sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"0bb4\", ATTRS{idProduct}==\"0c9e\", MODE=\"0666\", OWNER=\"$user\" #Debug & Recovery dinc' >> /etc/udev/rules.d/51-android.rules"
		sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"0bb4\", ATTRS{idProduct}==\"0c8d\", MODE=\"0666\", OWNER=\"$user\" #Debug & Recovery dinc (hardware 0002)' >> /etc/udev/rules.d/51-android.rules"
		sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"0bb4\", ATTRS{idProduct}==\"0fff\", MODE=\"0666\", OWNER=\"$user\" #Fastboot dinc' >> /etc/udev/rules.d/51-android.rules"
		sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"0bb4\", ATTRS{idProduct}==\"0c94\", MODE=\"0666\", OWNER=\"$user\" #Bootloader dinc' >> /etc/udev/rules.d/51-android.rules"
		;;
	    11) echo "Vendor=HTC, Device=Legend"
		_vendor="htc"
		_device="legend"
		_udev_v="0bb4"
		;;
	    12) echo "Vendor=HTC, Device=Magic"
		_vendor="htc"
		_device="dream_sapphire"
		_udev_v="0bb4"
                _incompatible="dream"
		;;
	    13) echo "Vendor=HTC, Device=Passion"
		_vendor="htc"
		_device="passion"
		_udev_v="skip"
		sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"18d1\", ATTRS{idProduct}==\"4e11\", MODE=\"0666\", OWNER=\"$user\" #Normal Nexus One' >> /etc/udev/rules.d/51-android.rules"
		sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"18d1\", ATTRS{idProduct}==\"4e12\", MODE=\"0666\", OWNER=\"$user\" #Debug & Recovery Nexus One' >> /etc/udev/rules.d/51-android.rules"
		sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"0bb4\", ATTRS{idProduct}==\"0fff\", MODE=\"0666\", OWNER=\"$user\" #Fastboot Nexus One' >> /etc/udev/rules.d/51-android.rules"
		;;
	    14) echo "Vendor=HTC, Device=Slide"
		_vendor="htc"
		_device="espresso"
		_udev_v="0bb4"
		_idev_p="0e03"
		;;
	    15) echo "Vendor=HTC, Device=Vision"
		_vendor="htc"
		_device="vision"
		_udev_v="0bb4"
		_idev_p="0c91"
		;;
	    16) echo "Vendor=HTC, Device=Wildfire"
		_vendor="htc"
		_device="buzz"
		_udev_v="0bb4"
		;;	
            17) echo "Vendor=HTC, Device=Leo"
		_vendor="htc"
		_device="leo"
		_udev_v="0bb4"
		;;
            18) echo "Vendor=HTC, Device=Incredible2"
		_vendor="htc"
		_device="vivow"
		_udev_v="skip"
		sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"0bb4\", ATTRS{idProduct}==\"0cad\", MODE=\"0666\", Owner=\"$user\" #Normal Inc2' >> /etc/udev/rules.d/51-android.rules"
		sudo sh -c "echo 'SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"0bb4\", ATTRS{idProduct}==\"0c94\", MODE=\"0666\", OWNER=\"$user\" #Bootloader Inc2' >> /etc/udev/rules.d/51-android.rules"
		sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"0bb4\", ATTRS{idProduct}==\"0ff0\", MODE=\"0666\", OWNER=\"$user\" Fastboot Inc2' >> /etc/udev/rules.d/51-android.rules"	
		;;         
	    19) echo "Vendor=HTC, Device=Tattoo"
		_vendor="htc"
		_device="click"
		_udev_v="0bb4"
		;;
        esac
	;;

## Prints Motorolla devices selection menu
    4|Motorola) Motodev_menu
	echo
	echo -n "Select Device(1-3): "
	read device
	while [[ $device -lt 1 || $device -gt 3 ]]; do
	    echo "Selection ERROR.."
	    echo -n "Select Device(1-3): "
	    read device
	done
	echo
	case $device in
	    1) echo "Vendor=Motorola, Device=Droid"
		_vendor="motorola"
		_device="sholes"
		_udev_v="22b8"
		;;
	    2) echo "Vendor=Motorola, Device=Cliq XT"
		_vendor="motorola"
		_device="zeppelin"
		_udev_v="skip"
		;;
	    3) echo "Vendor=Motorola, Device=Droid X"
		_vendor="motorola"
		_device="shadow"
		_udev_v="skip"
                sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"22b8\", MODE=\"0666\", OWNER=\"$user\" #Normal droid x' >> /etc/udev/rules.d/51-android.rules"
		;;
	esac
	;; 


    5|Samsung) Samsungdev_menu
	echo
	echo -n "Select Device(1-7): "
	read device
	while [[ $device -lt 1 || $device -gt 7 ]]; do
	    echo "Selection ERROR.."
	    echo -n "Select Device(1-7): "
	    read device
	done
	echo
	case $device in
	    1) echo "Vendor=Samsung, Device=Galaxy S"
		_vendor="samsung"
		_device="galaxysmtd"
		_udev_v="skip"
		;;
	    2) echo "Vendor=Samsung, Device=Nexus S"
		_vendor="samsung"
		_device="crespo"
		_udev_v="skip"
		sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"18d1\", ATTRS{idProduct}==\"4e21\", MODE=\"0666\", OWNER=\"$user\" #Normal nexus s' >> /etc/udev/rules.d/51-android.rules"
		sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"18d1\", ATTRS{idProduct}==\"4e22\", MODE=\"0666\", OWNER=\"$user\" #Debug & Recovery nexus s' >> /etc/udev/rules.d/51-android.rules"
		sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"18d1\", ATTRS{idProduct}==\"4e20\", MODE=\"0666\", OWNER=\"$user\" #Fastboot nexus s' >> /etc/udev/rules.d/51-android.rules"
		;;
	    3) echo "Vendor=Samsung, Device=Captivate"
		_vendor="samsung"
		_device="captivatemtd"
		_udev_v="skip"
		;;
	    4) echo "Vendor=Samsung, Device=Vibrant"
		_vendor="samsung"
		_device="vibrantmtd"
		_udev_v="skip"
		;;
	    5) echo "Vendor=Samsung, Device=Galaxy S II"
		_vendor="samsung"
		_device="galaxys2"
		_udev_v="skip"
                sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"04e8\", ATTRS{idProduct}==\"685e\", MODE=\"0666\", OWNER=\"$user\" #Normal Galaxy S II' >> /etc/udev/rules.d/51-android.rules"
		sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"04e8\", ATTRS{idProduct}==\"685e\", MODE=\"0666\", OWNER=\"$user\" #Debug & Recovery Galaxy S II' >> /etc/udev/rules.d/51-android.rules"
		sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"04e8\", ATTRS{idProduct}==\"685e\", MODE=\"0666\", OWNER=\"$user\" #Fastboot Galaxy S II' >> /etc/udev/rules.d/51-android.rules"
		;;
	    6) echo "Vendor=Samsung, Device=Fascinate"
		_vendor="samsung"
		_device="fascinatemtd"
		_udev_v="skip"
		sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"04e8\", ATTRS{idProduct}==\"685e\", MODE=\"0666\", OWNER=\"$user\" #Normal Fascinate' >> /etc/udev/rules.d/51-android.rules"
		sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"04e8\", ATTRS{idProduct}==\"685e\", MODE=\"0666\", OWNER=\"$user\" #Debug & Recovery Fascinate' >> /etc/udev/rules.d/51-android.rules"
		sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"04e8\", ATTRS{idProduct}==\"685e\", MODE=\"0666\", OWNER=\"$user\" #Fastboot Fascinate' >> /etc/udev/rules.d/51-android.rules"
		;;
	    7) echo "Vendor=Samsung, Device=Nexus S 4G"
		_vendor="samsung"
		_device="crespo4g"
		_udev_v="skip"
		sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"18d1\", ATTRS{idProduct}==\"4e21\", MODE=\"0666\", OWNER=\"$user\" #Normal nexus s' >> /etc/udev/rules.d/51-android.rules"
		sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"18d1\", ATTRS{idProduct}==\"4e22\", MODE=\"0666\", OWNER=\"$user\" #Debug & Recovery nexus s' >> /etc/udev/rules.d/51-android.rules"
		sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"18d1\", ATTRS{idProduct}==\"4e20\", MODE=\"0666\", OWNER=\"$user\" #Fastboot nexus s' >> /etc/udev/rules.d/51-android.rules"
		;;
		
	esac
	;;
    6|Viewsonic) echo "Vendor=Viewsonic, Device=G Tablet"
	_vendor="nvidia"
	_device="harmony"
	_udev_v="0955"
	;;
    7|ZTE) echo "Vendor=ZTE, Device=Blade"
	_vendor="zte"
	_device="blade"
	_udev_v="19D2"
	;;
    8|LG) LGdev_menu
	echo
	echo -n "Select Device(1-2): "
	read device
	while [[ $device -lt 1 || $device -gt 2 ]]; do
		echo "Selection ERROR.."
		echo -n "Select Device(1-2): "
		read device
	done
	echo
	case $device in
	    1) echo "Vendor=LG, Device=G2x"
		_vendor="lge"
		_device="p999"
		_udev_v="skip"
		;;
	    2) echo "Vendor=LG, Device=Optimus 2X"
		_vendor="lge"
		_device="p990"
		_udev_v="skip"
		;;
	esac
	;; 
    9|Barnes*Noble) echo "Vendor=Barnes & Noble, Device=Nook Color"
	_vendor="bn"
	_device="encore"
	_udev_v="skip"
	sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"2080\", ATTRS{idProduct}==\"0ff9\", MODE=\"0660\", OWNER=\"$user\" #Normal encore' >> /etc/udev/rules.d/51-android.rules"
	sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"2080\", ATTRS{idProduct}==\"0fff\", MODE=\"0660\", OWNER=\"$user\" #Fastboot encore' >> /etc/udev/rules.d/51-android.rules"
	sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"2080\", ATTRS{idProduct}==\"skip\", MODE=\"0660\", OWNER=\"$user\" #Debug & Recovery encore' >> /etc/udev/rules.d/51-android.rules"
	mkdir -p ~/.android && echo 0x2080 > ~/.android/adb_usb.ini
	;;
    
    10|Emulator) echo "For building Emulator images, use the build.sh script from your desktop"
	echo "Vendor=Generic, Device=Emulator"
	_vendor="generic"
	_device="generic"
	;;
    *)
	echo "Vendor ${vendor} is invalid!"
	vendor_menu
	exit
	;;
esac


echo
echo
##Installing udev drivers
if [ "$_udev_v" != "skip" ]; then {
	sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"$_udev_v\", ATTRS{idProduct}==\"0ff9\", MODE=\"0666\", OWNER=\"$user\" #Normal $_device' >> /etc/udev/rules.d/51-android.rules"
	sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"$_udev_v\", ATTRS{idProduct}==\"0fff\", MODE=\"0666\", OWNER=\"$user\" #Fastboot $_device' >> /etc/udev/rules.d/51-android.rules"
}
fi

if [ "$_idev_v" != "skip" ]; then {
	sudo sh -c "echo 'SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"$_udev_v\", ATTRS{idProduct}==\"$_idev_p\", MODE=\"0666\", OWNER=\"$user\" #Debug & Recovery $_device' >> /etc/udev/rules.d/51-android.rules"
}
fi

sudo chmod a+rx /etc/udev/rules.d/51-android.rules
sudo restart udev

ny=0
yn=0

##Loop until get answer y/yes
while [ "$yn" != "y" ]; do
    echo -e '\E[39;41m'"\033[1mPlease connect your device to your computer with debug mode enabled (Settings » Applications » Development » check 'USB Debugging'.)\033[0m"
    echo 'Notice: if you are using a virtual machine please select the phone from the usb devices of the VB machine'
    echo 
    sudo adb kill-server
    sudo adb start-server
    echo
    echo
    sudo adb devices
    echo "Is it connected? (y/n)"
    echo "You should see your device listed under the \"List of devices attached\" msg"
    echo
    echo "Pressing \"n\" will keep trying again and again. If you don't want the proprietary files to be downloaded from your phone cause you already have them (no, you can NOT build CM without them) press \"y\" and just ignore the errors"
    echo
    echo "If you have the phone connected and it's still not displayed, Please search for \"adb udev\" in XDA, CyanogenMod or other android webpages. If needed contact me @nicandris (at tweeter/xda/cyanogenmod)"
    read yn
done
sudo adb kill-server
sudo adb start-server
cd ~/android/system/device/$_vendor/$_device/
./extract-files.sh

echo
echo "do not unplug phone... might need to extract again"
echo
echo


##Loop until get answer y/yes
until [ "$ny" == "y" ]; do
echo
echo
echo "Was the above extraction successful (n/y)?"
read ny
##just to be sure ;)
sudo adb kill-server
sudo adb start-server
cd ~/android/system/device/$_vendor/$_device/
./extract-files.sh
done

##get rom manager. thanks koush
~/android/system/vendor/cyanogen/get-rommanager

cd ~/android/system/
repo sync
USE_CCACHE=1
if [ "$_incompatible" == "0" ]; then {
	. build/envsetup.sh && brunch $_device
}
fi

if [ "$_incompatible" == "dream" ]; then {
	cd ~/android/system/
	. build/envsetup.sh
	lunch cyanogen_dream_sapphire-eng
	mka bacon
}
fi


##The builds will be copied to the desktop folder Builds. delete these 3 lines if not wanted

if [[ -d ~/Desktop/Builds ]] ; then
    echo '~/Desktop/Builds' 'Dir Exists'
else
    mkdir -p ~/Desktop/Builds
fi

TODAY=$(date +%d_%m-%H.%M)
UPDATE=update-cm7-$_device-$TODAY.zip
UPDATESUM=update-cm7-$_device-$TODAY.md5sum

cp ~/android/system/out/target/product/$_device/update*.zip ~/Desktop/Builds/$UPDATE
cp ~/android/system/out/target/product/$_device/update*.md5sum ~/Desktop/Builds/$UPDATESUM

##Create the build.sh script

rm -f ~/Desktop/build.sh
if [ "$_incompatible" == "0" ]; then {
sh -c "echo 'clear' >> ~/Desktop/build.sh"
sh -c "echo 'echo' >> ~/Desktop/build.sh"
sh -c "echo 'echo' >> ~/Desktop/build.sh"
sh -c "echo 'options_menu() {' >> ~/Desktop/build.sh"
sh -c "echo '	echo     	' >> ~/Desktop/build.sh"
sh -c "echo '	echo ' >> ~/Desktop/build.sh"
sh -c "echo '	echo ' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	MENU:\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	1.Clean installation (make clean)\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	2.Remove "out" directory (make clobber)\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	3.Clean/Clobber\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	4.Clean/Clobber/Build\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	5.Check for Rom Manager Updates\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	6.Build\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	7.Add custom Mod Version Name\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	8.Repo Sync\"	' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	9.Push Latest Build to Phone\"	' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	10.Update SDK/ADB\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	11.Make emulator image\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	12.Remove builds from out dir\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	-\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	0.EXIT\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo ' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	If you wish to change device, please run the \"buildshcreator.sh\" script again\"' >> ~/Desktop/build.sh"
sh -c "echo 'echo' >> ~/Desktop/build.sh"
sh -c "echo 'echo -n \"Select Option(0-13): \"' >> ~/Desktop/build.sh"
sh -c "echo 'read option' >> ~/Desktop/build.sh"
sh -c "echo 'while [[ \$option -lt 0 || \$option -gt 13 ]]; do' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"Selection ERROR..\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo -n \"Select Option(0-13): \"' >> ~/Desktop/build.sh"
sh -c "echo '	read option' >> ~/Desktop/build.sh"
sh -c "echo 'done' >> ~/Desktop/build.sh"
sh -c "echo 'echo' >> ~/Desktop/build.sh"
sh -c "echo '' >> ~/Desktop/build.sh"
sh -c "echo 'case  \$option in' >> ~/Desktop/build.sh"
sh -c "echo ' 1) echo \"Cleaning build files...\"' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system' >> ~/Desktop/build.sh"
sh -c "echo '	make clean' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo '	;;' >> ~/Desktop/build.sh"
sh -c "echo ' 2) echo \"Cleaning output directory...\"' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system' >> ~/Desktop/build.sh"
sh -c "echo '	make clobber' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo '	;;' >> ~/Desktop/build.sh"
sh -c "echo ' 3) echo \"Cleaning build files and output directory...\"' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system' >> ~/Desktop/build.sh"
sh -c "echo '	make clean' >> ~/Desktop/build.sh"
sh -c "echo '	make clobber' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo '	;;' >> ~/Desktop/build.sh"
sh -c "echo ' 4) echo \"Cleaning build files and output directory...\"' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system' >> ~/Desktop/build.sh"
sh -c "echo '	make clean' >> ~/Desktop/build.sh"
sh -c "echo '	make clobber' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"Building...\"' >> ~/Desktop/build.sh"
sh -c "echo '	repo sync' >> ~/Desktop/build.sh"
sh -c "echo '	USE_CCACHE=1' >> ~/Desktop/build.sh"
sh -c "echo '	. build/envsetup.sh && brunch $_device' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system/out/target/product/$_device/system/' >> ~/Desktop/build.sh"
sh -c "echo '	Day=\`date +%d\`' >> ~/Desktop/build.sh"
sh -c "echo '	Date=\`date +%D\`' >> ~/Desktop/build.sh"
sh -c "echo '	Month=\`date +%m\`' >> ~/Desktop/build.sh"
sh -c "echo '	Year=\`date +%y\`' >> ~/Desktop/build.sh"
sh -c "echo '	Minute=\`date +%M\`' >> ~/Desktop/build.sh"
sh -c "echo '	Hour=\`date +%H\`' >> ~/Desktop/build.sh"
sh -c "echo '	Second=\`date +%S\`	' >> ~/Desktop/build.sh"
sh -c "echo '	mv build.prop build.text' >> ~/Desktop/build.sh"
sh -c "echo '	sed \"s/ro.modversion=[^ ]*/ro.modversion=cm-\$Month\/\$Day\/\$Year-\$Hour\:\$Minute\:\$Second/\" build.text > build.prop' >> ~/Desktop/build.sh"
sh -c "echo '	rm build.text' >> ~/Desktop/build.sh"
sh -c "echo '	cp build.prop ~/android/system/out/target/product/$_device/' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system/out/target/product/$_device/' >> ~/Desktop/build.sh"
sh -c "echo '	zip -qf update*.zip' >> ~/Desktop/build.sh"
sh -c "echo '	cp ~/android/system/out/target/product/$_device/update*.zip ~/Desktop/Builds/update-cm-$_device-\$(date +%d_%m-%H.%M).zip' >> ~/Desktop/build.sh"
sh -c "echo '	cp ~/android/system/out/target/product/$_device/update*.md5sum ~/Desktop/Builds/update-cm-$_device-\$(date +%d_%m-%H.%M).md5sum' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo '	;;' >> ~/Desktop/build.sh"
sh -c "echo '' >> ~/Desktop/build.sh"
sh -c "echo ' 5) echo \"Checking for Rom Manager Updates...\"' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system/vendor/cyanogen' >> ~/Desktop/build.sh"
sh -c "echo '	./get-rommanager' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo '	;;' >> ~/Desktop/build.sh"
sh -c "echo ' 6) echo \"Building Rom...\"' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system' >> ~/Desktop/build.sh"
sh -c "echo '	repo sync' >> ~/Desktop/build.sh"
sh -c "echo '	USE_CCACHE=1' >> ~/Desktop/build.sh"
sh -c "echo '	. build/envsetup.sh && brunch $_device' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system/out/target/product/$_device/system/' >> ~/Desktop/build.sh"
sh -c "echo '	Day=\`date +%d\`' >> ~/Desktop/build.sh"
sh -c "echo '	Date=\`date +%D\`' >> ~/Desktop/build.sh"
sh -c "echo '	Month=\`date +%m\`' >> ~/Desktop/build.sh"
sh -c "echo '	Year=\`date +%y\`' >> ~/Desktop/build.sh"
sh -c "echo '	Minute=\`date +%M\`' >> ~/Desktop/build.sh"
sh -c "echo '	Hour=\`date +%H\`' >> ~/Desktop/build.sh"
sh -c "echo '	Second=\`date +%S\`	' >> ~/Desktop/build.sh"
sh -c "echo '	mv build.prop build.text' >> ~/Desktop/build.sh"
sh -c "echo '	sed \"s/ro.modversion=[^ ]*/ro.modversion=cm-\$Month\/\$Day\/\$Year-\$Hour\:\$Minute\:\$Second/\" build.text > build.prop' >> ~/Desktop/build.sh"
sh -c "echo '	rm build.text' >> ~/Desktop/build.sh"
sh -c "echo '	cp build.prop ~/android/system/out/target/product/$_device/' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system/out/target/product/$_device/' >> ~/Desktop/build.sh"
sh -c "echo '	zip -qf update*.zip' >> ~/Desktop/build.sh"
sh -c "echo '	cp ~/android/system/out/target/product/$_device/update*.zip ~/Desktop/Builds/update-cm-$_device-\$(date +%d_%m-%H.%M).zip' >> ~/Desktop/build.sh"
sh -c "echo '	cp ~/android/system/out/target/product/$_device/update*.md5sum ~/Desktop/Builds/update-cm-$_device-\$(date +%d_%m-%H.%M).md5sum' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo '	;;' >> ~/Desktop/build.sh"
sh -c "echo '' >> ~/Desktop/build.sh"
sh -c "echo ' 7)   	cd ~/android/system/out/target/product/$_device/system/' >> ~/Desktop/build.sh"
sh -c "echo '	Day=\`date +%d\`' >> ~/Desktop/build.sh"
sh -c "echo '	Date=\`date +%D\`' >> ~/Desktop/build.sh"
sh -c "echo '	Month=\`date +%m\`' >> ~/Desktop/build.sh"
sh -c "echo '	Year=\`date +%y\`' >> ~/Desktop/build.sh"
sh -c "echo '	Minute=\`date +%M\`' >> ~/Desktop/build.sh"
sh -c "echo '	Hour=\`date +%H\`' >> ~/Desktop/build.sh"
sh -c "echo '	Second=\`date +%S\`' >> ~/Desktop/build.sh"	
sh -c "echo '	mv build.prop build.text' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"Add name for Custom Mod Version\"' >> ~/Desktop/build.sh"
sh -c "echo '	read modname' >> ~/Desktop/build.sh"
sh -c "echo '	sed \"s/ro.modversion=[^ ]*/ro.modversion=\$modname-\$Month\/\$Day\/\$Year-\$Hour\:\$Minute\:\$Second/\" build.text > build.prop' >> ~/Desktop/build.sh"
sh -c "echo '	rm build.text' >> ~/Desktop/build.sh"
sh -c "echo '	cp build.prop ~/android/system/out/target/product/$_device/' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system/out/target/product/$_device/' >> ~/Desktop/build.sh"
sh -c "echo '	zip -qf update*.zip' >> ~/Desktop/build.sh"
sh -c "echo '	cp ~/android/system/out/target/product/$_device/update*.zip ~/Desktop/Builds/update-cm-$_device-\$(date +%d_%m-%H.%M).zip' >> ~/Desktop/build.sh"
sh -c "echo '	cp ~/android/system/out/target/product/$_device/update*.md5sum ~/Desktop/Builds/update-cm-$_device-\$(date +%d_%m-%H.%M).md5sum' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo ' 	;;' >> ~/Desktop/build.sh"
sh -c "echo ' 8) echo \"Repo Syncing...\"' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system' >> ~/Desktop/build.sh"
sh -c "echo '	repo sync' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo '	;;' >> ~/Desktop/build.sh"
sh -c "echo ' 9) echo \"Pushing Latest Build To Phone... (from folder Builds)\"' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/Desktop/Builds' >> ~/Desktop/build.sh"
sh -c "echo '	echo \`ls *.zip -tr | tail -1\`' >> ~/Desktop/build.sh"
sh -c "echo '	sudo adb push \`ls *.zip -tr | tail -1\` /sdcard/' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo '	;;' >> ~/Desktop/build.sh"
sh -c "echo ' 10) echo \"Updating SDK/ADB...\"' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android-sdk*' >> ~/Desktop/build.sh"
sh -c "echo '	cd tools' >> ~/Desktop/build.sh"
sh -c "echo '	./android update sdk -u' >> ~/Desktop/build.sh"
sh -c "echo '	./android update adb' >> ~/Desktop/build.sh"
sh -c "echo '	sudo adb kill-server' >> ~/Desktop/build.sh"
sh -c "echo '	sudo adb start-server' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo '	;;' >> ~/Desktop/build.sh"
sh -c "echo ' 11) echo \"Building Emulator image...\"' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system' >> ~/Desktop/build.sh"
sh -c "echo '	. build/envsetup.sh ' >> ~/Desktop/build.sh"
sh -c "echo '	lunch 1    ' >> ~/Desktop/build.sh"
sh -c "echo '	make       ' >> ~/Desktop/build.sh"
sh -c "echo '	emulator' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo '	;;' >> ~/Desktop/build.sh"
sh -c "echo ' 12) echo \"Removing builds from out dir...\"' >> ~/Desktop/build.sh"
sh -c "echo '	rm ~/android/system/out/target/product/$_device/update*.zip' >> ~/Desktop/build.sh"
sh -c "echo '	rm ~/android/system/out/target/product/$_device/update*.md5sum' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo '	;;' >> ~/Desktop/build.sh"
sh -c "echo ' 0) exit' >> ~/Desktop/build.sh"
sh -c "echo '' >> ~/Desktop/build.sh"
sh -c "echo 'esac' >> ~/Desktop/build.sh"
sh -c "echo '}' >> ~/Desktop/build.sh"
sh -c "echo '' >> ~/Desktop/build.sh"
sh -c "echo 'options_menu' >> ~/Desktop/build.sh"
chmod 755 ~/Desktop/build.sh
chmod 755 ~/Desktop/build.sh
}
fi

if [ "$_incompatible" == "dream" ]; then {
sh -c "echo 'clear' >> ~/Desktop/build.sh"
sh -c "echo 'echo' >> ~/Desktop/build.sh"
sh -c "echo 'echo' >> ~/Desktop/build.sh"
sh -c "echo 'options_menu() {' >> ~/Desktop/build.sh"
sh -c "echo '	echo     	' >> ~/Desktop/build.sh"
sh -c "echo '	echo ' >> ~/Desktop/build.sh"
sh -c "echo '	echo ' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	MENU:\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	1.Clean installation (make clean)\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	2.Remove "out" directory (make clobber)\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	3.Clean/Clobber\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	4.Clean/Clobber/Build\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	5.Check for Rom Manager Updates\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	6.Build\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	7.Add custom Mod Version Name\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	8.Repo Sync\"	' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	9.Push Latest Build to Phone\"	' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	10.Update SDK/ADB\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	11.Make emulator image\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	12.Remove builds from out dir\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	-\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	0.EXIT\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo ' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"	If you wish to change device, please run the \"buildshcreator.sh\" script again\"' >> ~/Desktop/build.sh"
sh -c "echo '' >> ~/Desktop/build.sh"
sh -c "echo 'echo' >> ~/Desktop/build.sh"
sh -c "echo 'echo -n \"Select Option(1-13): \"' >> ~/Desktop/build.sh"
sh -c "echo 'read option' >> ~/Desktop/build.sh"
sh -c "echo 'while [[ \$option -lt 1 || \$option -gt 13 ]]; do' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"Selection ERROR..\"' >> ~/Desktop/build.sh"
sh -c "echo '	echo -n \"Select Option(1-13): \"' >> ~/Desktop/build.sh"
sh -c "echo '	read option' >> ~/Desktop/build.sh"
sh -c "echo 'done' >> ~/Desktop/build.sh"
sh -c "echo 'echo' >> ~/Desktop/build.sh"
sh -c "echo '' >> ~/Desktop/build.sh"
sh -c "echo 'case  \$option in' >> ~/Desktop/build.sh"
sh -c "echo ' 1) echo \"Cleaning build files...\"' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system' >> ~/Desktop/build.sh"
sh -c "echo '	make clean' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo '	;;' >> ~/Desktop/build.sh"
sh -c "echo ' 2) echo \"Cleaning output directory...\"' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system' >> ~/Desktop/build.sh"
sh -c "echo '	make clobber' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo '	;;' >> ~/Desktop/build.sh"
sh -c "echo ' 3) echo \"Cleaning build files and output directory...\"' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system' >> ~/Desktop/build.sh"
sh -c "echo '	make clean' >> ~/Desktop/build.sh"
sh -c "echo '	make clobber' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo '	;;' >> ~/Desktop/build.sh"
sh -c "echo ' 4) echo \"Cleaning build files and output directory...\"' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system' >> ~/Desktop/build.sh"
sh -c "echo '	make clean' >> ~/Desktop/build.sh"
sh -c "echo '	make clobber' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"Building...\"' >> ~/Desktop/build.sh"
sh -c "echo '	repo sync' >> ~/Desktop/build.sh"
sh -c "echo '	USE_CCACHE=1' >> ~/Desktop/build.sh"
sh -c "echo '	. build/envsetup.sh' >> ~/Desktop/build.sh"
sh -c "echo 'lunch cyanogen_dream_sapphire-eng >> ~/Desktop/build.sh"
sh -c "echo 'mka bacon >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system/out/target/product/$_device/system/' >> ~/Desktop/build.sh"
sh -c "echo '	Day=\`date +%d\`' >> ~/Desktop/build.sh"
sh -c "echo '	Date=\`date +%D\`' >> ~/Desktop/build.sh"
sh -c "echo '	Month=\`date +%m\`' >> ~/Desktop/build.sh"
sh -c "echo '	Year=\`date +%y\`' >> ~/Desktop/build.sh"
sh -c "echo '	Minute=\`date +%M\`' >> ~/Desktop/build.sh"
sh -c "echo '	Hour=\`date +%H\`' >> ~/Desktop/build.sh"
sh -c "echo '	Second=\`date +%S\`	' >> ~/Desktop/build.sh"
sh -c "echo '	mv build.prop build.text' >> ~/Desktop/build.sh"
sh -c "echo '	sed \"s/ro.modversion=[^ ]*/ro.modversion=cm-\$Month\/\$Day\/\$Year-\$Hour\:\$Minute\:\$Second/\" build.text > build.prop' >> ~/Desktop/build.sh"
sh -c "echo '	rm build.text' >> ~/Desktop/build.sh"
sh -c "echo '	cp build.prop ~/android/system/out/target/product/$_device/' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system/out/target/product/$_device/' >> ~/Desktop/build.sh"
sh -c "echo '	zip -qf update*.zip' >> ~/Desktop/build.sh"
sh -c "echo '	cp ~/android/system/out/target/product/$_device/update*.zip ~/Desktop/Builds/update-cm-$_device-\$(date +%d_%m-%H.%M).zip' >> ~/Desktop/build.sh"
sh -c "echo '	cp ~/android/system/out/target/product/$_device/update*.md5sum ~/Desktop/Builds/update-cm-$_device-\$(date +%d_%m-%H.%M).md5sum' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo '	;;' >> ~/Desktop/build.sh"
sh -c "echo '' >> ~/Desktop/build.sh"
sh -c "echo ' 5) echo \"Checking for Rom Manager Updates...\"' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system/vendor/cyanogen' >> ~/Desktop/build.sh"
sh -c "echo '	./get-rommanager' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo '	;;' >> ~/Desktop/build.sh"
sh -c "echo ' 6) echo \"Building Rom...\"' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system' >> ~/Desktop/build.sh"
sh -c "echo '	repo sync' >> ~/Desktop/build.sh"
sh -c "echo '	USE_CCACHE=1' >> ~/Desktop/build.sh"
sh -c "echo '	. build/envsetup.sh' >> ~/Desktop/build.sh"
sh -c "echo '   lunch cyanogen_dream_sapphire-eng >> ~/Desktop/build.sh"
sh -c "echo '   mka bacon >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system/out/target/product/$_device/system/' >> ~/Desktop/build.sh"
sh -c "echo '	Day=\`date +%d\`' >> ~/Desktop/build.sh"
sh -c "echo '	Date=\`date +%D\`' >> ~/Desktop/build.sh"
sh -c "echo '	Month=\`date +%m\`' >> ~/Desktop/build.sh"
sh -c "echo '	Year=\`date +%y\`' >> ~/Desktop/build.sh"
sh -c "echo '	Minute=\`date +%M\`' >> ~/Desktop/build.sh"
sh -c "echo '	Hour=\`date +%H\`' >> ~/Desktop/build.sh"
sh -c "echo '	Second=\`date +%S\`	' >> ~/Desktop/build.sh"
sh -c "echo '	mv build.prop build.text' >> ~/Desktop/build.sh"
sh -c "echo '	sed \"s/ro.modversion=[^ ]*/ro.modversion=cm-\$Month\/\$Day\/\$Year-\$Hour\:\$Minute\:\$Second/\" build.text > build.prop' >> ~/Desktop/build.sh"
sh -c "echo '	rm build.text' >> ~/Desktop/build.sh"
sh -c "echo '	cp build.prop ~/android/system/out/target/product/$_device/' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system/out/target/product/$_device/' >> ~/Desktop/build.sh"
sh -c "echo '	zip -qf update*.zip' >> ~/Desktop/build.sh"
sh -c "echo '	cp ~/android/system/out/target/product/$_device/update*.zip ~/Desktop/Builds/update-cm-$_device-\$(date +%d_%m-%H.%M).zip' >> ~/Desktop/build.sh"
sh -c "echo '	cp ~/android/system/out/target/product/$_device/update*.md5sum ~/Desktop/Builds/update-cm-$_device-\$(date +%d_%m-%H.%M).md5sum' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo '	;;' >> ~/Desktop/build.sh"
sh -c "echo '' >> ~/Desktop/build.sh"
sh -c "echo ' 7)   	cd ~/android/system/out/target/product/$_device/system/' >> ~/Desktop/build.sh"
sh -c "echo '	Day=\`date +%d\`' >> ~/Desktop/build.sh"
sh -c "echo '	Date=\`date +%D\`' >> ~/Desktop/build.sh"
sh -c "echo '	Month=\`date +%m\`' >> ~/Desktop/build.sh"
sh -c "echo '	Year=\`date +%y\`' >> ~/Desktop/build.sh"
sh -c "echo '	Minute=\`date +%M\`' >> ~/Desktop/build.sh"
sh -c "echo '	Hour=\`date +%H\`' >> ~/Desktop/build.sh"
sh -c "echo '	Second=\`date +%S\`' >> ~/Desktop/build.sh"	
sh -c "echo '	mv build.prop build.text' >> ~/Desktop/build.sh"
sh -c "echo '	echo \"Add name for Custom Mod Version\"' >> ~/Desktop/build.sh"
sh -c "echo '	read modname' >> ~/Desktop/build.sh"
sh -c "echo '	sed \"s/ro.modversion=[^ ]*/ro.modversion=\$modname-\$Month\/\$Day\/\$Year-\$Hour\:\$Minute\:\$Second/\" build.text > build.prop' >> ~/Desktop/build.sh"
sh -c "echo '	rm build.text' >> ~/Desktop/build.sh"
sh -c "echo '	cp build.prop ~/android/system/out/target/product/$_device/' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system/out/target/product/$_device/' >> ~/Desktop/build.sh"
sh -c "echo '	zip -qf update*.zip' >> ~/Desktop/build.sh"
sh -c "echo '	cp ~/android/system/out/target/product/$_device/update*.zip ~/Desktop/Builds/update-cm-$_device-\$(date +%d_%m-%H.%M).zip' >> ~/Desktop/build.sh"
sh -c "echo '	cp ~/android/system/out/target/product/$_device/update*.md5sum ~/Desktop/Builds/update-cm-$_device-\$(date +%d_%m-%H.%M).md5sum' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo ' 	;;' >> ~/Desktop/build.sh"
sh -c "echo ' 8) echo \"Repo Syncing...\"' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system' >> ~/Desktop/build.sh"
sh -c "echo '	repo sync' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo '	;;' >> ~/Desktop/build.sh"
sh -c "echo ' 9) echo \"Pushing Latest Build To Phone... (from folder Builds)\"' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/Desktop/Builds' >> ~/Desktop/build.sh"
sh -c "echo '	echo \`ls *.zip -tr | tail -1\`' >> ~/Desktop/build.sh"
sh -c "echo '	sudo adb push \`ls *.zip -tr | tail -1\` /sdcard/' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo '	;;' >> ~/Desktop/build.sh"
sh -c "echo ' 10) echo \"Updating SDK/ADB...\"' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android-sdk*' >> ~/Desktop/build.sh"
sh -c "echo '	cd tools' >> ~/Desktop/build.sh"
sh -c "echo '	./android update sdk -u' >> ~/Desktop/build.sh"
sh -c "echo '	./android update adb' >> ~/Desktop/build.sh"
sh -c "echo '	sudo adb kill-server' >> ~/Desktop/build.sh"
sh -c "echo '	sudo adb start-server' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo '	;;' >> ~/Desktop/build.sh"
sh -c "echo ' 11) echo \"Building Emulator image...\"' >> ~/Desktop/build.sh"
sh -c "echo '	cd ~/android/system' >> ~/Desktop/build.sh"
sh -c "echo '	. build/envsetup.sh ' >> ~/Desktop/build.sh"
sh -c "echo '	lunch 1    ' >> ~/Desktop/build.sh"
sh -c "echo '	make       ' >> ~/Desktop/build.sh"
sh -c "echo '	emulator' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo '	;;' >> ~/Desktop/build.sh"
sh -c "echo ' 12) echo \"Removing builds from out dir...\"' >> ~/Desktop/build.sh"
sh -c "echo '	rm ~/android/system/out/target/product/$_device/update*.zip' >> ~/Desktop/build.sh"
sh -c "echo '	rm ~/android/system/out/target/product/$_device/update*.md5sum' >> ~/Desktop/build.sh"
sh -c "echo '	options_menu' >> ~/Desktop/build.sh"
sh -c "echo '	;;' >> ~/Desktop/build.sh"
sh -c "echo ' 0) exit' >> ~/Desktop/build.sh"
sh -c "echo '' >> ~/Desktop/build.sh"
sh -c "echo 'esac' >> ~/Desktop/build.sh"
sh -c "echo '}' >> ~/Desktop/build.sh"
sh -c "echo '' >> ~/Desktop/build.sh"
sh -c "echo 'options_menu' >> ~/Desktop/build.sh"
chmod 775 ~/Desktop/build.sh
}
fi

echo
echo "Time to check your build in your Builds folder on your Desktop."
echo
