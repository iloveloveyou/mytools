#!/bin/bash
#在Linux和Mac OS X系统上运行.NET
#http://www.infoq.com/cn/news/2015/05/NET-Linux-Mac?utm_campaign=infoq_content&utm_source=infoq&utm_medium=feed&utm_term=global
brew tap aspnet/dnx
brew update
brew install dnvm
dnx . kestrel
