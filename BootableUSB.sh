####################################################
# This is a scrpit to make bootable USB from an ISO.

#! /bin/bash

# Chose a disk you'd like to make bootable 
lsblk | egrep "sdc|media"
read -p "Chose a disk you'd like to make bootable (eg. /dev/sdc): " disk 

# Chose an iso image you'd like to burn
find ~ -type f -name *.iso -print
read -p "Chose an iso image you'd like to burn (type whole path): " image

# Final Execution of making bootable USB
sudo dd if=$image of=$disk bs=16M status=progress oflag=sync
sudo partprobe $disk 2>/dev/null

# Final message
echo "Your USB is ready, changes will be visible after reinserting the disk into the computer"
