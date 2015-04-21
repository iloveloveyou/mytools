#!/bin/bash
# Run this script to enable the Ramdisk for Firefox profiles
VolumeName="zjl"
 
# Size in MB, make sure is not too low or not too high
SizeInMB=50
 
NumSectors=$((2*1024*SizeInMB))
 
DeviceName=`hdid -nomount ram://$NumSectors`
 
echo $DeviceName
 
diskutil eraseVolume HFS+ shm $DeviceName
ln -s /Volumes/shm/ /dev/shm
 
# move the current profiles folder
#mv Profiles Profiles_ &&
 
# make a symlink to the ramdisk
#ln -s /Volumes/RAMDisk ./Profiles &&
 
# then copy it to the ramdisk
#/bin/cp -r Profiles_/* Profiles

