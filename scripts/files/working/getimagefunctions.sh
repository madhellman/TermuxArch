#!/bin/bash -e
# Copyright 2017-2018 by SDRausty. All rights reserved.  🌎 🌍 🌏 🌐 🗺
# Hosting https://sdrausty.github.io/TermuxArch courtesy https://pages.github.com
# https://sdrausty.github.io/TermuxArch/CONTRIBUTORS Thank you for your help.  
# https://sdrausty.github.io/TermuxArch/README has information about this project. 
################################################################################

adjustmd5file ()
{
	if [ $(getprop ro.product.cpu.abi) = x86_64 ] || [ $(getprop ro.product.cpu.abi) = x86 ];then
		if [[ $dm = wget ]];then 
			wget -N --show-progress http://$mirror${path}md5sums.txt
		else
			curl -q --fail --retry 4 -O -L http://$mirror${path}md5sums.txt
		fi
		filename=$(ls *tar.gz)
		sed '2q;d' md5sums.txt > $filename.md5
		rm md5sums.txt
	else
		if [[ $dm = wget ]];then 
			wget -N --show-progress http://$mirror$path$file.md5 
		else
			curl -q --fail --retry 4 -O -L http://$mirror$path$file.md5
		fi
	fi
}

ftchstnd ()
{
		curl -v http://os.archlinuxarm.org/ 2>gmirror
		echo 420
		cat gmirror
		echo 460
		grep Location gmirror | awk {'print $3}' 2>nmirror
		echo 510
#		grep Location gmirror | awk {'print $3}' >nmirror
#		nmirror="$(<(grep Location gmirror | awk {'print $3}') )" 
		nmirror=$(grep Location gmirror | awk {'print $3}') 
#		nmirror="$(<nmirror)" 
		echo 520
		echo $gmirror
		cat gmirror
		echo 560
		echo $nmirror
		cat nmirror
		exit
	#	curl -L --fail --retry 4 -O http://$nmirror$path$file.md5 -O http://$mirror$path$file
		curl -L --fail --retry 4 -O http://$nmirror$path$file.md5 -O http://$mirror$path$file
}

getimage ()
{
	if [ $(getprop ro.product.cpu.abi) = x86_64 ];then
		if [[ $dm = wget ]];then 
			wget -A tar.gz -m -nd -np http://$mirror$path
		else
			printf "\nDefaulting to \`wget\` for x86_64 system image download.  \n"
			wget -A tar.gz -m -nd -np http://$mirror$path
		fi
	else
		if [[ $dm = wget ]];then 
			wget -c --show-progress http://$mirror$path$file 
		else
			curl -q -C - --fail --retry 4 -O -L http://$mirror$path$file
		fi
	fi
}

preproot ()
{
	if [ $(du ~/arch/*z | awk {'print $1}') -gt 112233 ];then
		if [ $(getprop ro.product.cpu.abi) = x86_64 ] || [ $(getprop ro.product.cpu.abi) = x86 ];then
			proot --link2symlink -0 bsdtar -xpf $file --strip-components 1 
		else
			proot --link2symlink -0 bsdtar -xpf $file 
		fi
	else
		printf "\n\nDownload Exception!  Exiting!\n\n"
		exit
	fi
}
