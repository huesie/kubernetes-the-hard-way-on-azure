#!/bin/bash

# prereqs
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/001-prereqs.sh

printf "\ncfssl\n-----\n" ; cfssl version
printf "\nkubectl\n-------\n" ; kubectl version --short --client ; kubectl version --client
echo ; prompt_abort "About to install cfssl in "

echo -e "\nInstalling cfssl.."
pushd /tmp
wget -q --show-progress --https-only --timestamping \
  https://github.com/cloudflare/cfssl/releases/download/v1.4.1/cfssl_1.4.1_linux_amd64 \
  https://github.com/cloudflare/cfssl/releases/download/v1.4.1/cfssljson_1.4.1_linux_amd64
chmod +x cfssl_1.4.1_linux_amd64 cfssljson_1.4.1_linux_amd64
sudo mv cfssl_1.4.1_linux_amd64 /usr/local/bin/cfssl
sudo mv cfssljson_1.4.1_linux_amd64 /usr/local/bin/cfssljson
popd

printf "\ncfssl\n-----\n" ; cfssl version
printf "\nkubectl\n-------\n" ; kubectl version --short --client ; kubectl version --client

