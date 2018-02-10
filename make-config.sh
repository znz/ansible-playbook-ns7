#!/bin/bash
set -euo pipefail
DIR="$(dirname "$0")"
PKI_DIR="${DIR}/easy-rsa/easyrsa3/pki"
BASE_CONFIG="${DIR}/base.conf"
OUTPUT_DIR="${DIR}/client-config-files"
umask 077
install -m700 -d "$OUTPUT_DIR"
cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${PKI_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${PKI_DIR}/issued/${1}.crt \
    <(echo -e '</cert>\n<key>') \
    ${PKI_DIR}/private/${1}.key \
    <(echo -e '</key>\n<tls-auth>') \
    ${DIR}/ta.key \
    <(echo -e '</tls-auth>') \
    | sed $'s/$/\r/g' > ${OUTPUT_DIR}/${1}.ovpn
