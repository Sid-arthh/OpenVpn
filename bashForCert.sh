#!/bin/bash

# Check if a file is provided as a command-line argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <output_file>"
    exit 1
fi

output_file="$1"

sudo rm -rf custom_folders
# Clone the repository
git clone https://github.com/OpenVPN/easy-rsa.git
cd easy-rsa/easyrsa3

# Initialize EasyRSA
./easyrsa init-pki

# Build the CA
./easyrsa build-ca nopass

# Build the server key and certificate
./easyrsa build-server-full server nopass

# Build the client key and certificate
./easyrsa build-client-full client1.domain.tld nopass

# Create a custom folder and copy the required files
cd ..
cd ..
mkdir custom_folders
cp "$output_file" custom_folders
cp easy-rsa/easyrsa3/pki/ca.crt custom_folders
cp easy-rsa/easyrsa3/pki/issued/server.crt custom_folders
cp easy-rsa/easyrsa3/pki/private/server.key custom_folders
cp easy-rsa/easyrsa3/pki/issued/client1.domain.tld.crt custom_folders
cp easy-rsa/easyrsa3/pki/private/client1.domain.tld.key custom_folders

# Read the content of client1.domain.tld.crt and client1.domain.tld.key
crt_content=$(cat custom_folders/client1.domain.tld.crt)
key_content=$(cat custom_folders/client1.domain.tld.key)
cd custom_folders
# Insert the content after </ca> in the output file
{
    cat "$output_file" | sed -n -e '/<\/ca>/q;p'
    echo "</ca>"
    echo "<cert>"
    echo "$crt_content"
    echo "</cert>"
    echo "<key>"
    echo "$key_content"
    echo "</key>"
    sed -e '1,/<\/ca>/d' "$output_file"
} > temp_output_file

mv temp_output_file  ../client_conf.ovpn
cd ..
cd ..
sudo rm -rf easy-rsa
sudo rm -rf custom_folders

# Clean up temporary files and folders


echo "OpenVPN setup completed successfully!"
