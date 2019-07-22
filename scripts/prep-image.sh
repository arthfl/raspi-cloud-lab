#!/usr/bin/env bash
set -eu

ARGS=$(getopt -o 'h' --longoptions 'help,archive:,hostname:,group:,user:' -- "$@")
if [[ $? -ne 0 ]]; then
    echo "NOPE"
    exit 1
fi

eval set -- "$ARGS"
unset ARGS
while true; do
    case "$1" in
        '-h'|'--help')
            printf "Usage: %s --archive something.zip --hostname foo --group bar --user bar\n" "$0"
            exit 1
            ;;
        '--archive')
            archive="$2"
            shift 2
            continue
            ;;
        '--hostname')
            hostname="$2"
            shift 2
            continue
            ;;
        '--group')
            group="$2"
            shift 2
            continue
            ;;
        '--user')
            user="$2"
            shift 2
            continue
            ;;
        '--')
            shift
            break
            ;;
    esac
    shift
done

echo "Unzipping image $archive..."
unzip "$archive"
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

echo -n "Adding group $group..."
sudo groupadd -P "$temp_dir" "$group"
echo "done"

echo -n "Adding user $user..."
sudo useradd -P "$temp_dir" -g "$group" -G adm -s /bin/bash "$user"
echo "done"

echo -n "Setting hostname $hostname..."
echo "$hostname" | sudo tee "${temp_dir}/etc/hostname" > /dev/null
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
