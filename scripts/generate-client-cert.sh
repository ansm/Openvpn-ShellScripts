#!/bin/bash

#Script to generate easyRSA client certificate and key encrypted with password
#Authon: Anish Mishra


package=`basename "$0"`
SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`
ROOT_APP_PATH=`dirname $SCRIPTPATH`
EASYRSA_DIR=$ROOT_APP_PATH/EasyRSA-v3.0.6
DEBUG=false

function print_usage() {
			echo "*****************************************************************************"
			echo "*Script to generate client certificate and Private key for OpenVPN Service  *"
			echo "*****************************************************************************"
			echo " "
			echo "$package  [arguments]"
                        echo " "
                        echo "OPTIONS:"
                        echo "-h                                        show brief help"
                        echo "-u ClientName/UserName                    specify an unique client name (*required)"
                        echo "-p Password                               specify a password for encrypting private key (*required)"
                        echo "-d 	                                  enable debug mode"		
                        echo " "

		}

#Check if all required arguments supplied
while getopts 'u:p:hd' option; do
  case "${option}" in
    h) print_usage
       exit 0 ;;
    u) CLIENT_NAME="${OPTARG}"
      [ -f ${EASYRSA_DIR}/pki/issued/${CLIENT_NAME}.crt ] && { printf '{"todo": "Create VPN Certificate","result": "fail","message": "Client Certificate already exists","path": "null"}\n'; exit 2; } ;;
    p) PASSWORD="${OPTARG}" ;;
    d) DEBUG=true ;;
    *) print_usage
       exit 1 ;;
  esac
done

[ -z $CLIENT_NAME  ] && { printf '{"todo": "Create VPN Certificate","result": "fail","message": "Client Name not provided","path": "null"}\n'; exit 2;}
[ -z $PASSWORD  ] && { printf '{"todo": "Create VPN Certificate","result": "fail","message": "Password not provided","path": "null"}\n'; exit 2;}

cd ${EASYRSA_DIR}
if $DEBUG; then
       	echo -e "$PASSWORD\n$PASSWORD" | ./easyrsa build-client-full $CLIENT_NAME
else
	echo -e "$PASSWORD\n$PASSWORD" | ./easyrsa build-client-full $CLIENT_NAME > /dev/null 2>&1
fi

if [ $? -ne 0 ]; then
	printf '{"todo": "Create VPN Certificate","result": "fail","message": "Client Certificate not generated","path": "null"}\n'
	exit 2
else
	FILE=$EASYRSA_DIR/pki/issued/$CLIENT_NAME.crt
	if (test -f $FILE ); then
		printf '{"todo": "Create VPN Certificate","result": "success","message": "Client Certificate generated successfully","path": "%s"}\n' "$FILE"
	        exit 0
	fi
fi
