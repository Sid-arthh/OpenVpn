#!/bin/bash
if [ $# -ne 1 ]; then
    echo "Usage: $0 <output_file>"
    exit 1
fi
output_file="$1"

sudo rm -rf custom_folders
git clone https://github.com/OpenVPN/easy-rsa.git
cd easy-rsa/easyrsa3
./easyrsa init-pki

./easyrsa build-ca nopass
./easyrsa build-server-full server nopass

./easyrsa build-client-full client1.domain.tld nopass

cd ..
cd ..
mkdir custom_folders
cp "$output_file" custom_folders
cp easy-rsa/easyrsa3/pki/ca.crt custom_folders
cp easy-rsa/easyrsa3/pki/issued/server.crt custom_folders
cp easy-rsa/easyrsa3/pki/private/server.key custom_folders
cp easy-rsa/easyrsa3/pki/issued/client1.domain.tld.crt custom_folders
cp easy-rsa/easyrsa3/pki/private/client1.domain.tld.key custom_folders
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
sudo rm -rf custom_folders
sudo rm -rf easy-rsa


# Clean up temporary files and folders


echo "OpenVPN setup completed successfully!"
