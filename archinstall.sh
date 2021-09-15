#!bin/bash
# this is a custom script used to establish an arch install assuming 1 drive name given by the user. 
# It partitions the drive, configures pacman, establishes UEFI grub and installs preferred packages.
# this is a dumbass script and clearly a waste of time. Just go fucking install manjaro or do it yourself. Also, I'm an idiot. 
echo -e "\e[1;36mPlease enter the drive you wish to partition. Example: /dev/sda (running fdisk -l)\e[0m"
fdisk -l
read vardrive
echo -e "\e[1;36mPlease enter the total capacity of your storage in GB\e[0m"
read vardrivespace
echo -e "\e[1;36mDrive $vardrive selected. Are you sure? [y/n]\e[0m"
read answer
if [ "$answer" != "${answer#[Nn]}" ] ;then
    echo -e "\e[1;36mExiting\e[0m"
    exit
else
    echo -e "\e[1;36mContinuing...\e[0m"    
fi
timedatectl set-ntp true
timedatectl set-timezone America/Chicago
timedatectl status
echo -e "\e[1;36mTimezone set to America/Chicago\e[0m"
sleep 5s
fdisk $vardrive <<EEOF
g
n
2

+600M
t
1
n
3

+600M
t
3
swap
n
1


w
EEOF
mkfs.btrfs $vardrive"1"
mkfs.fat -F32 $vardrive"2"
mkswap $vardrive"3"
mkdir /boot/efi
mount $vardrive"1" /mnt
mount $vardrive"2" /boot/efi
swapon $vardrive"3"
echo -e "\e[1;36mCreated partition 1 as root, partition 2 as EFI boot, partition 3 as swap.\e[0m"
# ^^ insert partitioning script here, rest of script assumes 3 partitions; P1 for root, P2 for EFI boot, P3 for swap.
echo -e "\e[1;36mRunning reflector. This may take some time.\e[0m"
reflector --ipv4 --latest 20 --sort rate --save /etc/pacman.d/mirrorlist
echo -e "\e[1;36mSuccessfully ran reflector; sorted 20 fastest mirrors by download speed.\e[0m"
echo -e "\e[1;36mPreparing pacstrap, installing base packages.\e[0m"
echo -e "\e[1;36mWould you like to install AMD CPU microcode? [y/n]\e[0m"
read microcodeanswer
if [ "$microcodeanswer" != "${microcodeanswer#[Nn]}" ] ;then
    echo -e "\e[1;36mPackages to be installed: base linux linux-firmware emacs vim networkmanager grub efibootmgr nano sudo \e[0m"
    pacstrap /mnt base linux linux-firmware emacs vim networkmanager grub efibootmgr nano sudo
else 
    echo -e "\e[1;36mPackages to be installed: base linux linux-firmware emacs vim networkmanager amd-ucode grub efibootmgr nano sudo\e[0m"
    pacstrap /mnt base linux linux-firmware emacs vim networkmanager amd-ucode grub efibootmgr nano sudo 
fi 
genfstab -U /mnt >> /mnt/etc/fstab
# grub configuration via chroot
ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
echo -e "\e[1;36mPlease enter a hostname\e[0m"
read varhostname
echo $varhostname >> /etc/hostname
echo -e "\e[1;36mPlease enter a root password\e[0m"
arch-chroot /mnt <<EOF
passwd
mkdir /boot/efi
mount $vardrive"2" /boot/efi
grub-install --target=x86_64-efi /boot/efi
grub-mkconfig -o /boot/grub/grub.cfg
EOF
echo -e "\e[1;36mInstallation successful. Reboot, and login as root.\e[0m"
