#!/bin/bash

# Original Live by cybojenix <anthonydking@gmail.com>
# New Live/Menu by Caio Oliveira aka Caio99BR <caiooliveirafarias0@gmail.com>
# Colors by Aidas Lukošius aka aidasaidas75 <aidaslukosius75@yahoo.com>
# Toolchains by Suhail aka skyinfo <sh.skyinfo@gmail.com>
# Rashed for the base of zip making
# And the internet for filling in else where

# Thanks to RolanDroid for the introduction
# Credit also to DespairFactor for some parameters
# https://github.com/DespairFactor/angler/blob/6.0.1/despair-build.sh

# Prepare output customization commands - Start

customcoloroutput() {
if [ "$coloroutput" == "ON" ]; then
	# Stock Color
	txtrst=$(tput sgr0)
	# Bold Colors
	txtbld=$(tput bold) # Bold
	bldred=${txtbld}$(tput setaf 1) # red
	bldgrn=${txtbld}$(tput setaf 2) # green
	bldyel=${txtbld}$(tput setaf 3) # yellow
	bldblu=${txtbld}$(tput setaf 4) # blue
	bldmag=${txtbld}$(tput setaf 5) # magenta
	bldcya=${txtbld}$(tput setaf 6) # cyan
	bldwhi=${txtbld}$(tput setaf 7) # white
	coloroutputzip="--color=auto"
fi
if [ "$coloroutput" == "OFF" ]; then
	unset txtbld bldred bldgrn bldyel bldblu bldmag bldcya bldwhi
	coloroutputzip="--color=never"
fi
}

setcustomcoloroutput() {
if [ "$coloroutput" == "ON" ]; then
	coloroutput="OFF"
else
	coloroutput="ON"
fi
}

setcustombuildoutput() {
if [ "$buildoutput" == "ON" ]; then
	buildoutput="OFF"
else
	buildoutput="ON"
fi
}

# Stuff
KERNEL="zImage-dtb"
KERNEL_DIR="/home/kayant/Kernels/android_kernel_motorola_msm8226"
RESOURCE_DIR="$KERNEL_DIR/.."
Optimus_ANYKERNEL_DIR="$RESOURCE_DIR/Optimus-AnyKernel2"
Hurtsky_ANYKERNEL_DIR="$RESOURCE_DIR/Hurtsky-AnyKernel2"
TOOLCHAIN_DIR="$RESOURCE_DIR/Toolchains"
Hurtsky_REPACK_DIR="$Hurtsky_ANYKERNEL_DIR"
Optimus_REPACK_DIR="$Optimus_ANYKERNEL_DIR"
ZIP_MOVE="$RESOURCE_DIR/Releases"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm/boot"

# Prepare output customization commands - End

# Clean - Start

cleanzip() {
echo "You want Clean Zip folders?"
echo "y) Yes"
echo "n) No"
echo "r) Remove zImage from directorys"
read -p "Choice: " -n 1 -s zipclean
case "$zipclean" in
	y) echo "Cleaning Releases Directory..."; rm -rf $ZIP_MOVE/*.zip;;
	n) echo "Kernel zips were not cleaned";;
	r) echo "Zimages were deleted"; rm -rf $Hurtsky_REPACK_DIR/$KERNEL; rm -rf $Optimus_REPACK_DIR/$KERNEL;
esac
cleanzipcheck="Done"
unset zippackagecheck
}

cleankernel() {
ccache -C
export ARCH=arm; export SUBARCH=arm
cd $KERNEL_DIR; git reset --hard &> /dev/null
git clean -f -d &> /dev/null; make clean &> /dev/null;
make mrproper &> /dev/null | echo "Cleaning...";
cleankernelcheck="Done"
unset buildprocesscheck BUILDTIME
}
# Clean - End

# Main Process - Start

maindevice() {
echo "-${bldcya}Kernels${txtrst}-"
echo "o) Optimus Kernel"
echo "h) Hurtsky Kernel"
unset errorchoice
read -p "Choice: " -n 1 -s kerchoice
case "$kerchoice" in
	o) defconfig="peregrine_defconfig";;
	h) defconfig="hurtsky_peg_defconfig";;
	*) echo "$kerchoice - This option is not valid"; sleep .5; errorchoice="ON";;
esac
if ! [ "$errorchoice" == "ON" ]; then
	echo "$kerchoice"; make $defconfig &> /dev/null | echo "Setting..."
	maindevicecheck="ON"
	unset cleankernelcheck
fi
}

manualtoolchain() {
cd $KERNEL_DIR
echo "What toolchain do you want?"
echo "a) Arch TC"
echo "u) UBER TC"
read -p "Choice: " -n 1 -s toolchainloc
case "$toolchainloc" in
	a) export CROSS_COMPILE=$TOOLCHAIN_DIR/Archtoolchain/bin/arm-linux-androideabi-;;
	u) export CROSS_COMPILE=$TOOLCHAIN_DIR/UBERTC/out/arm-eabi-5.3-cortex-a7/bin/arm-eabi-;;
	*) echo "$toolchainloc - This option is not valid"; sleep .5;;
esac
}

branchcheckout(){
cd $KERNEL_DIR
echo "What git branch do you want to build?"
echo "o) Optimus 6.0"
echo "h) Hurtsky Hybrid"
read -p "Choice: " -n 1 -s gitbranch
case "$gitbranch" in
	o) git checkout optimus-M; customkernel=Optimus-Kernel;;
	h) git checkout HurtSkyHybrid; customkernel=Hurtsky-Kernel;;
	*) echo "$gitbranch - This option is not valid"; sleep .5;;
esac
}

# Main Process - End

# Build Process - Start

buildprocess() {
START=$(date +"%s")
NR_CPUS=$(grep -c ^processor /proc/cpuinfo)
if [ "$NR_CPUS" -le "2" ]; then
	NR_CPUS="4"
fi
echo "${bldblu}Building $customkernel with $NR_CPUS jobs at once${txtrst}"
if [ "$buildoutput" == "ON" ]; then
	make $defconfig
	make -j${NR_CPUS}
else
	make $defconfig
	make -j${NR_CPUS} &>/dev/null | loop
fi
END=$(date +"%s")
BUILDTIME=$(($END - $START))
if [ -f $ZIMAGE_DIR/$KERNEL ]; then
	buildprocesscheck="Done"
	unset cleankernelcheck
else
	buildprocesscheck="Something goes wrong"
fi
}

loop() {
LEND=$(date +"%s")
LBUILDTIME=$(($LEND - $START))
echo -ne "\r\033[K"
echo -ne "${bldgrn}Build Time: $(($LBUILDTIME / 60)) minutes and $(($LBUILDTIME % 60)) seconds.${txtrst}"
sleep 1
if ! [ -f $ZIMAGE_DIR/$KERNEL ]; then
	loop
fi
}

# Build Process - End

# Zip Process - Start

zippackage() {
echo "$zipfile to be built"
echo "What zip do you want pack?"
echo "o) Optimus"
echo "h) Hurtsky"
read -p "Choice: " -n 1 -s ziploc
case "$ziploc" in
	o) cp $ZIMAGE_DIR/$KERNEL $Optimus_REPACK_DIR; cd $Optimus_REPACK_DIR
 		zip -r9 $zipfile * .zip &> /dev/null; \
		mv $zipfile $ZIP_MOVE &> /dev/null; cd $KERNEL_DIR &> /dev/null;;
	h) cp $ZIMAGE_DIR/$KERNEL $Hurtsky_REPACK_DIR; cd $Hurtsky_REPACK_DIR
 		zip -r9 $zipfile * .zip &> /dev/null; \
		mv $zipfile $ZIP_MOVE &> /dev/null; cd $KERNEL_DIR &> /dev/null;;
	*) echo "$ziploc - This option is not valid"; sleep .5;;
esac
zippackagecheck="Done"
unset cleanzipcheck
}
# Zip Process - End

# ADB - Start

adbonline() {
adb kill-server &> /dev/null; adb connect 192.168.0.5:5555 &> /dev/null
}

adbcopy() {
adbonline &> /dev/null
echo "Script says: You want to copy to Internal or External Card?"
echo "i) For Internal"
echo "e) For External"
read -p "Choice: " -n 1 -s adbcoping
case "$adbcoping" in
	i) echo "Coping to Internal Card..."; adb push $ZIP_MOVE/$zipfile /storage/sdcard0/ &> /dev/null; adbcopycheck="Done";;
	e) echo "Coping to External Card..."; adb push $ZIP_MOVE/$zipfile /storage/4AFD-14FB/Kernels/$zipfile &> /dev/null; adbcopycheck="Done";;
	*) echo "$adbcoping - This option is not valid"; sleep .5;;
esac
}

# ADB - End

# Misc - Start

buildtimemisc() {
if ! [ "$BUILDTIME" == "" ]; then
	echo "${bldgrn}Build Time: $(($BUILDTIME / 60)) minutes and $(($BUILDTIME % 60)) seconds.${txtrst}"
fi
}

zippackagemisc() {
echo "${bldyel}Zip Saved to Releases/$zipfile${txtrst}"
}

getversion(){
echo "Optimus versions start with R. e.g R51 "
echo "Hurtsky versions start with Hs. e.g Hs6 "
read -p "Please enter the kernel version: " versionconf
echo "$versionconf"
if [ "$gitbranch" == "o" ]; then
zipfile="Optimus-M-Peregrine-$versionconf.zip"
elif [ "$gitbranch" == "h" ]; then
zipfile="Hurtsky$versionconf-Peregrine.zip"
fi
}

rescript(){
exec /home/kayant/Github/scripts/build-kernel.sh
}

# Misc - End

# Menu - Start

buildsh() {
kernelversion=`cat Makefile | grep VERSION | cut -c 11- | head -1`
kernelpatchlevel=`cat Makefile | grep PATCHLEVEL | cut -c 14- | head -1`
kernelsublevel=`cat Makefile | grep SUBLEVEL | cut -c 12- | head -1`
kernelname=`cat Makefile | grep NAME | cut -c 8- | head -1`
clear
echo "Simple Linux Kernel Build Script ($(date +%d"/"%m"/"%Y))"
echo "$customkernel $kernelversion.$kernelpatchlevel.$kernelsublevel - $kernelname"
echo
echo "-${bldred}Clean:${txtrst}-"
echo "1) Last Zip Package (${bldred}$cleanzipcheck${txtrst})"
echo "-${bldgrn}Main Process:${txtrst}-"
echo "2) Device Choice (${bldgrn}$kerchoice${txtrst})"
echo "3) Toolchain Choice (${bldgrn}$toolchainloc${txtrst})"
echo "4) Git Branch (${bldgrn}$gitbranch${txtrst})"
echo "5) Kernel Version (${bldgrn}$versionconf${txtrst})"
echo "-${bldyel}Build Process:${txtrst}-"
echo "6) Clean Kernel (${bldgrn}$cleankernelcheck${txtrst})"
if [ "$maindevicecheck" == "" ]; then
	echo "Use "3" first."
else
	if [ "$CROSS_COMPILE" == "" ]; then
		echo "Use "4" first."
	else
		echo "7) Build $customkernel (${bldyel}$buildprocesscheck${txtrst})"
	fi
fi
if ! [ "$maindevicecheck" == "" ]; then
	if [ -f $ZIMAGE_DIR/$KERNEL ]; then
		echo "8) Build Zip Package (${bldyel}$zippackagecheck${txtrst})"
	fi
fi
echo "-${bldmag}Status:${txtrst}-"
buildtimemisc
if [ -f $ZIP_MOVE/$zipfile ]; then
	zippackagemisc
fi
echo "-${bldcya}Menu:${txtrst}-"
echo "9) Copy to device - Via Adb"
echo "b) Restart script"
if [ "$coloroutput" == "ON" ]; then
echo "c) Color (${bldcya}$coloroutput${txtrst})"
else
echo "c) Color ($coloroutput)"
fi
if [ "$buildoutput" == "ON" ]; then
echo "o) View Build Output (${bldcya}$buildoutput${txtrst})"
else
echo "o) View Build Output ($buildoutput)"
fi
echo "q) Quit"
read -n 1 -p "${txtbld}Choice: ${txtrst}" -s x
case $x in
	1) echo "$x - Cleaning Zips"; cleanzip; buildsh;;
	2) echo "$x - Kernel choice"; maindevice; buildsh;;
	3) echo "$x - Toolchain choice"; manualtoolchain; buildsh;;
	4) echo "$x - Checking out branches"; branchcheckout; buildsh;;
	5) echo "$x - Get the zip version"; getversion; buildsh;;
	6) echo "$x - Cleaning $customkernel"; cleankernel; buildsh;;
	7) echo "$x - Building $customkernel"; buildprocess; zippackage; buildsh;;
	8) if [ -f $ZIMAGE_DIR/$KERNEL ]; then
		echo "$x - Ziping $customkernel"; zippackage; buildsh
	else
		echo "$x - This option is not valid"; sleep .5; buildsh
	fi;;
	9) echo "$x - Coping $customkernel to Sdcard"; adbcopy; buildsh;;
	b) echo "$x - Restart the script"; rescript;;
	c) setcustomcoloroutput; customcoloroutput; buildsh;;
	o) setcustombuildoutput; buildsh;;
	q) echo "Ok, Bye!"; unset zippackagecheck;;
	*) echo "$x - This option is not valid"; sleep .5; buildsh;;
esac
}
# Menu - End

# The core of script is here!
export ARCH=arm; export SUBARCH=arm
	if [ -f $ZIP_MOVE/*.zip ]; then
		unset cleanzipcheck
	else
		cleanzipcheck="Done"
	fi

	if [ "$coloroutput" == "" ]; then
		coloroutput="ON"
	fi

	if [ "$buildoutput" == "" ]; then
		buildoutput="ON"
	fi

	customcoloroutput

	if [[ "$1" = "--help" || "$1" = "-h" ]]; then
		echo "Simple Linux Kernel Build Script"
		echo "Use: . build.sh [OPTION]"
		echo
		echo "  -l, --live           use this for fast building without menu"
		echo "  -C, --clean          use this for fast cleaning (Zip/Kernel)"
		echo
		echo "This is an open source script, feel free to use, edit and share it."
		echo "By default this have a menu to interactive with kernel building."
		echo "And for complete usage download:"
		echo "https://github.com/TeamVee/android_prebuilt_toolchains"
		echo "to same folder of kernel for fast toolchain select."
	elif [[ "$1" = "--live" || "$1" = "-l" ]]; then
		echo "--Choose a Device--"
		maindevice
		echo "--Choose a Toolchain--"
		maintoolchain; buildprocess; buildtimemisc; zippackage; zippackagemisc
	elif [[ "$1" = "--clean" || "$1" = "-C" ]]; then
		cleanzip; cleankernel
	else
		buildsh
	fi
