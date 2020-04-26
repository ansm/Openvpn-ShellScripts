#!/bin/bash

#Script for createing OpenVPN Client Certificates and Configuration files
#Author : Anish Mishra

# First argument: Client identifier
# Second argument: Client OS identifier
# Thid argument: Client private key passphrase

package=`basename "$0"`
SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`
ROOT_APP_PATH=`dirname $SCRIPTPATH`
OPENVPN_DIR=/etc/openvpn  #change this if required according to openvpn installtion config directory
EASYRSA_DIR=$ROOT_APP_PATH/EasyRSA-v3.0.6
OUTPUT_DIR=$ROOT_APP_PATH/configs/clients
BASE_CONFIG_DIR=$ROOT_APP_PATH/configs/base

function print_usage() {
                        echo "*****************************************************************************"
                        echo "Script to generate client certificate/key and ovpn config for OpenVPN service"
                        echo "*****************************************************************************"
                        echo " "
                        echo "$package  [arguments]"
                        echo " "
                        echo "OPTIONS:"
                        echo "-h                                        show brief help"
                        echo "-u ClientName/UserName                    specify an unique client name (*required)"
                        echo "-o OS                               specify a OS name for which config need to be generated (*required)"
                        echo " "
		}


#Check if all required arguments supplied
while getopts 'u:o:h' flag; do
  case "${flag}" in
    h) print_usage
       exit 0 ;;
    u) CLIENT_NAME="${OPTARG}"
       [ ! -f ${EASYRSA_DIR}/pki/issued/${CLIENT_NAME}.crt ] && { printf '{"todo": "Create Client VPN Configuration","result": "fail","message": "Client Certificate does not exists","path": "null"}\n' ; exit 2; } ;;
    o) OS="${OPTARG}" 
       if [ ${OPTARG,,} != "windows" ] && [ ${OPTARG,,} != "linux" ] && [ ${OPTARG,,} != "mac" ]; then
	       printf '{"todo": "Create Client VPN Configuration","result": "fail","message": "Invalid OS provided","path": "null"}\n'
	       exit 2
       fi;;
    *) print_usage
       exit 1 ;;
  esac
done

[ -z $CLIENT_NAME  ] && {  printf '{"todo": "Create Client VPN Configuration","result": "fail","message": "Client name not provided","path": "null"}\n'; exit 2;}
[ -z $OS  ] && { printf '{"todo": "Create Client VPN Configuration","result": "fail","message": "OS not provided","path": "null"}\n' ; exit 2;}

BASE_CONFIG=${BASE_CONFIG_DIR}/"${OS,,}"-base.conf
#echo $BASE_CONFIG
FILE=${OUTPUT_DIR}/${CLIENT_NAME}-${OS}.ovpn
#[ -n ${BASE_CONFIG} ] && BASE_CONFIG=${BASE_CONFIG_DIR}/linux-base.conf
cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${EASYRSA_DIR}/pki/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${EASYRSA_DIR}/pki/issued/${CLIENT_NAME}.crt \
    <(echo -e '</cert>\n<key>') \
    ${EASYRSA_DIR}/pki/private/${CLIENT_NAME}.key \
    <(echo -e '</key>\n<tls-auth>') \
    ${OPENVPN_DIR}/ta.key \
    <(echo -e '</tls-auth>') \
    > $FILE

if (test -f $FILE ); then
	printf '{"todo": "Create Client VPN Configuration","result": "success","message": "Client VPN Configuration generated successfully","path": "%s"}\n' "$FILE"
fi
