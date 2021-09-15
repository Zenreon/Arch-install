# Arch-install
A bash script designed to install Arch Linux with heavy assumptions. The goal is to get you to an installed root TTY.

# Usage
Copy archinstall.sh to a live system and execute through bash.

# Assumptions
- Internet is accessible
- 3 Partitions:
  - One BTRFS root partition (left over size from other partitions)
  - One EFI Boot partition (600MB)
  - One Swap partition (600MB)
- Bootloader of choice is GRUB
- Only 1 user on installation
- America/Chicago as timezone (CDT/CST)

# Packages installed to /mnt
base linux linux-firmware emacs vim networkmanager grub efibootmgr nano sudo 
Optional: amd-ucode
