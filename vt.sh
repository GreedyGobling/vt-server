#!/bin/bash

# Prompt user for URL
read -p "Enter the URL to download a .tar.gz file: " url

if [ -z "$url" ]; then
    echo "No URL entered. Exiting."
    exit 1
fi

# Save current working directory
run_dir=$(pwd)
user_name=$(whoami)

# Get filename from URL
filename=$(basename "$url")

# Download the file
echo "Downloading $filename..."
wget "$url"

if [ $? -ne 0 ]; then
    echo "Download failed. Exiting."
    exit 1
fi

# Extract the file
echo "Extracting $filename..."
tar -xzf "$filename"

if [ $? -ne 0 ]; then
    echo "Extraction failed. Exiting."
    exit 1
fi

# Find server.sh in the extracted folder
echo "Searching for server.sh..."
server_path=$(find . -type f -name "server.sh" | head -n 1)

if [ -z "$server_path" ]; then
    echo "server.sh not found. Exiting."
    exit 1
fi

# Modify server.sh with new variables
echo "Modifying $server_path..."

escaped_run_dir=$(printf '%s\n' "$run_dir" | sed 's:/:\\/:g')
escaped_data_dir="${escaped_run_dir}\/data"

sed -i "s/^USERNAME=.*/USERNAME='${user_name}'/" "$server_path"
sed -i "s/^VSPATH=.*/VSPATH='${escaped_run_dir}'/" "$server_path"
sed -i "s/^DATAPATH=.*/DATAPATH='${escaped_data_dir}'/" "$server_path"

# Create data directory if not exists
mkdir -p "$run_dir/data"

echo "✅ All done. server.sh updated and ready to go."
