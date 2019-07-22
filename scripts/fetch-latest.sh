#!/usr/bin/env bash

destination="$1"
latest_raspbian="https://downloads.raspberrypi.org/raspbian_lite_latest"

if [[ -z "$destination" ]]; then
    echo "No destination given, setting to './raspbian.img'"
    destination="./raspbian.zip"
fi

echo "Fetching latest Raspbian image..."
curl -L -o "$destination" "$latest_raspbian"
