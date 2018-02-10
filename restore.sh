#!/bin/sh
set -euo pipefail
DIR="$(dirname "$0")"
cd "$DIR"
ln -snfv ../../easy-rsa/easyrsa3/pki/inventory provision/inventory/production
ln -snfv ../../easy-rsa/easyrsa3/pki/ansible-vars.yml provision/vars/production.yml
ln -snfv easy-rsa/easyrsa3/pki/base.conf base.conf
