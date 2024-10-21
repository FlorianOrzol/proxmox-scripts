#!/bin/bash
#
# 
#  _____        _
# |~>   |     ('v') 
# /:::::\    /{w w}\ 
#--------------------------------
# Copyright Florian Orzol
#
# description: this script creates a bootable USB stick with Proxmox VE
# date: 2024-10-18
# version: 1.0 
#
#    <')
# \_;( )
# >>>> START SCRIPT <<<< #

# Check if the script is run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

proxmoxIso="$1"

# check if the proxmox ISO file is provided
if [ -z "$proxmoxIso" ]; then
  echo "Please provide the path to the Proxmox VE ISO file"
  exit
fi

# choose the USB device
echo "Please choose the USB device you want to use:"
lsblk
echo "-> lsblk"
read -p "Enter the device name (e.g. sdb): " device
device="/dev/$device"

# ask for confirmation
echo "The following device will be used: $device"
echo "All data on the device will be deleted."
echo "Make sure you have selected the correct device."
read -p "Do you really want to install Proxmox VE to $device? (y/n) " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo
  echo "User aborted. Run the script again to install Proxmox VE to a different device."
  exit
fi

# check if the device exists
if [ ! -b $device ]; then
  echo "Device $device does not exist"
  exit
fi

# check if the device is mounted
if mount | grep $device; then
  echo "Device $device is mounted. It will be unmounted."
echo "-> umount $device"
  umount $device
fi


# delete all partitions
echo "Deleting all partitions on $device"
echo "-> parted -s $device mklabel msdos"
parted -s $device mklabel msdos



# install proxmoxISO to USB device
echo "Installing Proxmox VE to $device"
echo "-> dd if=$proxmoxIso of=$device bs=4M status=progress oflag=sync"
dd if=$proxmoxIso of=$device bs=4M status=progress oflag=sync
