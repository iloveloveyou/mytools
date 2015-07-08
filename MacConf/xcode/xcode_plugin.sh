#!/bin/sh
#list current
#xcode-select -p
#use command line tools as 
#xcode-select -switch /Library/Developer/CommandLineTools
#xcode-select -switch /Applications/Xcode.app/Contents/Developer/


# Package manager for Xcode http://alcatraz.io
# https://github.com/supermarin/Alcatraz

function install(){
	curl -fsSL https://raw.github.com/supermarin/Alcatraz/master/Scripts/install.sh | sh
}
function uninsall(){
	rm -rf ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins/Alcatraz.xcplugin
	#To remove all packages installed via Alcatraz
	#rm -rf ~/Library/Application\ Support/Alcatraz/
}