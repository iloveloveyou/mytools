#!/bin/bash
cd ~/Library/Cache/Firefox/
 
# clean the cache
#rm -rf  Profiles/*/Cache/* &&
 
# will save your modifications back to the DISK
#/usr/bin/rsync -av --delete ./Profiles/ ./Profiles_/ &amp;&amp;
 
# sometimes during unmount it will say disk is in use.
# make sure you close firefox before.
umount /Volumes/RAMDisk &&
#rm -rf Profiles &&
#mv Profiles_ Profiles