#!/bin/bash

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 
    exit 1
fi

# Check if an argument is provided
if [[ -z $1 ]]; then
    echo "Please provide a file system image as an argument"
    exit 1
fi

# Set the file system image file
image=$1

# Create a directory to store the output files
output_dir=$(date +%Y-%m-%d_%H-%M-%S)_inodes_output
mkdir $output_dir

# Use fsstat to get the total number of inodes in the file system
total_inodes=$(fsstat $image | grep "Number of inodes:" | awk '{print $4}')

# Loop through each inode number and use icat to extract its contents
for ((i=0; i<$total_inodes; i++)); do
    inode_num=$((i+1))
    icat -f ext $image $inode_num 2>/dev/null > $output_dir/inode_$inode_num 2>/dev/null
done

echo "Inode parsing complete. Output files stored in $output_dir"
