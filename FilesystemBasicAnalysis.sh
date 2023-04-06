#!/bin/bash

# Check if user has root privileges
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Check if required arguments are provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <image_file>" >&2
    exit 1
fi

# Set image file variable
image_file=$1

# Print the MBR information using gdisk
echo "MBR Information:"
gdisk -l "$image_file"

# Use mmls to find the partition information
echo "Partition Information:"
mmls "$image_file"

# Extract the partition offsets from the mmls output
partition_offset=($(mmls "$image_file" | awk '{print $3,$4}'))

# Set the partition start and end sectors
partition_start_sector=${partition_offset[0]}
partition_end_sector=${partition_offset[1]}

# Calculate the partition size in bytes
partition_size=$(($partition_end_sector - $partition_start_sector + 1))

# Use icat to extract the partition to a new file
echo "Extracting partition to partition.img..."
icat "$image_file" 2 "$partition_size" > partition.img

# Use fls to list the files in the partition
echo "Filesystem Information:"
fls -r -m / partition.img

# Use blkcat to extract a file from the partition image
echo "Extracting a file from the partition..."
file_name=$(fls / partition.img | awk '/file_name/{print $6;exit}')
blkcat -r -s / /"$file_name" partition.img > "$file_name"

echo "Done."
