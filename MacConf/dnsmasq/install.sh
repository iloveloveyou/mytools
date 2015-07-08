#!/bin/sh
sudo ln -s /opt/tools/zjl/MacConf/hosts /etc/hosts

#dns泛解析
function dsnmasq_install()
{
	brew install dnsmasq
	brew link dnsmasq
	mv /usr/local/opt/dnsmasq/dnsmasq.conf.example	/usr/local/opt/dnsmasq/dnsmasq.conf
	sudo cp -fv /usr/local/opt/dnsmasq/*.plist /Library/LaunchDaemons
	sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
	
	#刷新缓存并重新启动dnsmasq服务
	sudo launchctl stop homebrew.mxcl.dnsmasq
	sudo launchctl start homebrew.mxcl.dnsmasq
	sudo killall -HUP mDNSResponder
}
