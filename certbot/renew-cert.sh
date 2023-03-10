#!/bin/bash

# set -eo pipefail 

POSITIONAL=()

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    --domain)
        DOMAIN=$2
        shift 2
        ;;
    --kid)
        KID=$2
        shift 2
        ;;
    --hmac-key)
        HMAC_KEY=$2
        shift 2
        ;;
    *)
        POSITIONAL+=("$1")
        shift
        ;;
    esac
done

# This works with certs signed through sectigo. Sectigo KID and HMAC_KEY are required.
certbot certonly --standalone --non-interactive --agree-tos \
    --email some@email.com \
    --csr path/to/csr.csr \
    --server http://acme.sectigo.com/v2/OV \
    --eab-kid $KID \
    --eab-hmac-key $HMAC_KEY \
    --domain $DOMAIN \
    --cert-name $DOMAIN

echo "Cert contents \n"
cat 0000_cert.pem
echo "\nChain 0 contents \n"
cat 0000_chain.pem
echo "\nChain 1 contents \n"
cat 0001_chain.pem

