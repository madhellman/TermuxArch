#!/data/data/com.termux/files/usr/bin/bash -e
# Copyright 2017-2018 by SDRausty. All rights reserved.
# Website for this project at https://sdrausty.github.io/TermuxArch
# See https://sdrausty.github.io/TermuxArch/CONTRIBUTORS Thank You 
################################################################################

adjustmd5file ()
{
	if [ $(uname -m) = x86_64 ] || [ $(uname -m) = i686 ];then
		wget -q -N --show-progress http://$mirror${path}md5sums.txt
		filename=$(ls *tar.gz)
		sed '2q;d' md5sums.txt > $filename.md5
		rm md5sums.txt
	else
		wget -q -N --show-progress http://$mirror$path$file.md5
	fi
}

callsystem ()
{
	mkdir -p $HOME/arch
	cd $HOME/arch
	detectsystem
}

copybin2path ()
{
	printf " 🕚 \033[36;1m<\033[0m 🕛 "
	while true; do
	read -p "Copy \`$bin\` to your \`\$PATH\`? [y|n]  " answer
	if [[ $answer = [Yy]* ]];then
		cp $HOME/arch/$bin $PREFIX/bin
		printf "\n 🕦 \033[36;1m<\033[0m 🕛 Copied \033[32;1m$bin\033[0m to \033[1;34m$PREFIX/bin\033[0m.\n\n"
		break
	elif [[ $answer = [Nn]* ]];then
		printf "\n"
		break
	elif [[ $answer = [Qq]* ]];then
		printf "\n"
		break
	else
		printf "\n 🕚 \033[36;1m<\033[0m 🕛 You answered \033[33;1m$answer\033[0m.\n"
		printf "\n 🕚 \033[36;1m<\033[0m 🕛 Answer Yes or No (y|n).\n\n"
	fi
	done
}

detectsystem ()
{
	printdetectedsystem
	if [ $(getprop ro.product.cpu.abi) = armeabi ];then
		armv5l
	elif [ $(getprop ro.product.cpu.abi) = armeabi-v7a ];then
		detectsystem2 
	elif [ $(getprop ro.product.cpu.abi) = arm64-v8a ];then
		aarch64
	elif [ $(getprop ro.product.cpu.abi) = x86 ];then
		i686 
	elif [ $(getprop ro.product.cpu.abi) = x86_64 ];then
		x86_64
	else
		printmismatch 
	fi
}

detectsystem2 ()
{
	if [[ $(getprop ro.product.device) == *_cheets ]];then
		armv7lChrome 
	else
		armv7lAndroid  
	fi
}

detectsystem2p ()
{
	if [[ $(getprop ro.product.device) == *_cheets ]];then
	printf "Chromebook.  "
	else
	printf "$(uname -o) Operating System.  "
	fi
}

getimage ()
{
	# Get latest image for x86_64 wants refinement.  __Continue does not work.__ 
	if [ $(getprop ro.product.cpu.abi) = x86_64 ];then
		wget -A tar.gz -m -nd -np http://$mirror$path
	else
		wget -q -c --show-progress http://$mirror$path$file
	fi
}

makebin ()
{
	makestartbin 
	printconfigq 
	touchupsys 
}

makesetupbin ()
{
	cat > root/bin/setupbin.sh <<- EOM
	#!/data/data/com.termux/files/usr/bin/bash -e
	unset LD_PRELOAD
	exec proot --link2symlink -0 -r $HOME/arch/ -b /dev/ -b /sys/ -b /proc/ -b /storage/ -b $HOME -w $HOME /bin/env -i HOME=/root TERM="$TERM" PS1='[termux@arch \W]\$ ' LANG=$LANG PATH=/bin:/usr/bin:/sbin:/usr/sbin $HOME/arch/root/bin/finishsetup.sh
	EOM
	chmod 700 root/bin/setupbin.sh
}

makestartbin ()
{
	cat > $bin <<- EOM
	#!/data/data/com.termux/files/usr/bin/bash -e
	unset LD_PRELOAD
	exec proot --link2symlink -0 -r $HOME/arch/ -b /dev/ -b /sys/ -b /proc/ -b /storage/ -b $HOME -w $HOME /bin/env -i HOME=/root TERM="$TERM" PS1='[termux@arch \W]\$ ' LANG=$LANG PATH=/bin:/usr/bin:/sbin:/usr/sbin /bin/bash --login
	EOM
	chmod 700 $bin
}

makesystem ()
{
	printdownloading 
	termux-wake-lock 
	getimage
	adjustmd5file 
	printmd5check
	if md5sum -c $file.md5 ; then
		printmd5success
		preproot 
	else
		rm -rf $HOME/arch
		printmd5error
	fi
	rm *.tar.gz *.tar.gz.md5
	makebin 
}

preproot ()
{
	if [ $(uname -m) = x86_64 ] || [ $(uname -m) = i686 ];then
		proot --link2symlink bsdtar -xpf $file --strip-components 1 2>/dev/null||:
	else
		proot --link2symlink bsdtar -xpf $file 2>/dev/null||:
	fi
}

rmarch ()
{
	while true; do
	printf "\n\033[1;31m"
	read -p "Run purge to uninstall Arch Linux? [y|n]  " uanswer
	if [[ $uanswer = [Ee]* ]] || [[ $uanswer = [Nn]* ]] || [[ $uanswer = [Qq]* ]];then
		break
	elif [[ $uanswer = [Yy]* ]];then
	printf "\nUninstalling Arch Linux...  \033[1;32m\n"
	if [ -e $PREFIX/bin/$bin ] ;then
	       	rm $PREFIX/bin/$bin 
	else 
		printf "Uninstalling Arch Linux, nothing to do for $PREFIX/bin/$bin.\n"
       	fi
	if [ -d $HOME/arch ] ;then
		cd $HOME/arch
		rm -rf * 2>/dev/null||:
		find -type d -exec chmod 700 {} \; 2>/dev/null||:
		cd ..
		rm -rf $HOME/arch
	else 
		printf "Uninstalling Arch Linux, nothing to do for $HOME/arch.\n"
	fi
	printf "Uninstalling Arch Linux done.  \n"
	printtail
	else
		printf "\nYou answered \033[33;1m$uanswer\033[1;31m.\n\nAnswer \033[32mYes\033[1;31m or No. [\033[32my\033[1;31m|n]\n"
	fi
	done
}

setlocalegen()
{
	if [ -e etc/locale.gen ]; then
		sed -i '/\#en_US.UTF-8 UTF-8/{s/#//g;s/@/-at-/g;}' etc/locale.gen 
	else
		cat >  etc/locale.gen <<- EOM
		en_US.UTF-8 UTF-8 
		EOM
	fi
}

spaceinfo ()
{
space=`df /storage/emulated/0 | awk '{print $4}' | sed '2q;d'`
if [[ $space = *G ]] || [[ $space = *T ]];then
	spaceMessage=""
else
	spaceMessage="Warning!  Start thinking about cleaning out some stuff.  The user space on this device has just $space."
fi
}

sysinfo ()
{
	printf "\n\033[1;32m"
	printf "Begin setupTermuxArch debug information.\n" > setupTermuxArchDebug.log
	printf "\nDisk report $spaceMessage on `date`\n" >> setupTermuxArchDebug.log 
	for n in 0 1 2 3 4 5 
	do 
		echo "BASH_VERSINFO[$n] = ${BASH_VERSINFO[$n]}"  >> setupTermuxArchDebug.log
	done
	printf "\ncat /proc/cpuinfo results:\n\n" >> setupTermuxArchDebug.log
	cat /proc/cpuinfo >> setupTermuxArchDebug.log
	printf "\ndpkg --print-architecture result:\n\n" >> setupTermuxArchDebug.log
	dpkg --print-architecture >> setupTermuxArchDebug.log
	printf "\ngetprop ro.product.cpu.abi result:\n\n" >> setupTermuxArchDebug.log
	getprop ro.product.cpu.abi >> setupTermuxArchDebug.log
	printf "\ngetprop ro.product.device result:\n\n" >> setupTermuxArchDebug.log
	getprop ro.product.device >> setupTermuxArchDebug.log
	printf "\nDownload directory information results.\n\n" >> setupTermuxArchDebug.log
	ls -al ~/storage/downloads  2>>setupTermuxArchDebug.log >> setupTermuxArchDebug.log ||:
	ls -al ~/downloads 2>>setupTermuxArchDebug.log  >> setupTermuxArchDebug.log ||:
	if [ -d /sdcard/Download ]; then echo "/sdcard/Download exists"; else echo "/sdcard/Download not found"; fi >> setupTermuxArchDebug.log 
	if [ -d /storage/emulated/0/Download ]; then echo "/storage/emulated/0/Download exists"; else echo "/storage/emulated/0/Download not found"; fi >> setupTermuxArchDebug.log
	printf "\nuname -mo results:\n\n" >> setupTermuxArchDebug.log
	uname -mo >> setupTermuxArchDebug.log
	printf "\nEnd setupTermuxArch debug information.\n\nPost this information along with information regarding your issue at https://github.com/sdrausty/TermuxArch/issues.  This debugging information is found in $(pwd)/$(ls setupTermuxArchDebug.log).  If you think screenshots will help in resolving this matter better, include them in your post please.  " >> setupTermuxArchDebug.log
	cat setupTermuxArchDebug.log
}

touchupsys ()
{
	mkdir -p root/bin
	addbash_profile 
	addbashrc 
	adddfa
	addga
	addgcl
	addgcm
	addgp
	addgpl
	addmotd
	addprofile 
	addresolvconf 
	addt 
	addyt 
	addv 
	setlocalegen
	printf "\n\033[32;1m"
	while true; do
	read -p "Do you want to use \`nano\` or \`vi\` to edit your Arch Linux configuration files [n|v]?  "  nv
	if [[ $nv = [Nn]* ]];then
		ed=nano
		apt-get -qq install nano --yes 
		break
	elif [[ $nv = [Vv]* ]];then
		ed=vi
		break
	else
		printf "\nYou answered \033[36;1m$nv\033[32;1m.\n"
		printf "\nAnswer nano or vi (n|v).  \n\n"
	fi
		printf "\nYou answered \033[36;1m$nv\033[32;1m.\n"
	done	
	printf "\n"
	while true; do
	read -p "Would you like to run \`locale-gen\` to generate the en_US.UTF-8 locale or do you want to edit /etc/locale.gen specifying your preferred language before running \`locale-gen\`?  Answer run or edit [r|e].  " ye
	if [[ $ye = [Rr]* ]];then
		break
	elif [[ $ye = [Ee]* ]];then
		$ed $HOME/arch/etc/locale.gen
		break
	else
		printf "\nYou answered \033[36;1m$ye\033[32;1m.\n"
		printf "\nAnswer run or edit (Rr|Ee).  \n\n"
	fi
	done
	$ed $HOME/arch/etc/pacman.d/mirrorlist
	makefinishsetup
	makesetupbin 
}
