#!/usr/bin/env bash
set -eu

zipped_image="$1"
group_name="flart"
user_name="flart"

echo "Unzipping image $zipped_image..."
unzip "$zipped_image"
echo "done"

echo -n "Getting name of image file... "
image_file="$(ls *-lite.img)"
echo "done: $image_file"


echo -n "Creating temporary loopback device..."
loopback_device="$(sudo losetup --show -f -P $image_file)"
echo "done: $loopback_device"

echo -n "Creating temporary mountpoint..."
temp_dir="$(mktemp --directory)"
echo "done: $temp_dir"

echo -n "Mounting image partition 1... "
sudo mount -t vfat "${loopback_device}p1" "$temp_dir"
echo "done"

echo -n "Enabling SSH access in image..."
sudo touch "${temp_dir}/ssh"
echo "done"

echo -n "Unmounting image partition 1... "
sudo umount "$temp_dir"
echo "done"

echo -n "Mounting image partition 2... "
sudo mount "${loopback_device}p2" "$temp_dir"
echo "done"

echo -n "Adding group $group_name..."
sudo groupadd -P "$temp_dir" "$group_name"
echo "done"

echo -n "Adding user $user_name..."
sudo useradd -P "$temp_dir" -g "$group_name" -G adm -s /bin/bash "$user_name"
echo "done"

echo -n "Unmounting image partition 2... "
sudo umount "$temp_dir"
echo "done"

echo -n "Removing temporary mountpoint..."
sudo rmdir "$temp_dir"
echo "done"

echo -n "Detaching temporary loopback device..."
sudo losetup -d "$loopback_device"
echo "done"

echo "$image_file has now SSH enabled on first boot"
