# Lazarus-VPN


# "vpn" directory
EasyRSA
This Repository contains EasyRsa directory, which is used to initialize pki to crate CA and issue/revoke/renew certificates.

Configs
configs/base
Config directory contains base config parameters for client configuration based on OS type i.e. Windows, Linux or Mac.

config/clients
This directory also contains any client config generated (.ovpn files)

OpenVPN-Server
This directory contain configuration file for OpenVPN server.

How to setup CA and Generate Server Certificate & Keys
------------------------------------------------------
1. Clone the repository 
2. Make sure vars file has relevant settings, if not you can change it and save.
3. Goto EasyRSA directory and initialize the pki 
       ./easyrsa init-pki
       This will create a new directory under EasyRSA directory named "pki" This newly created directory will hold all certificates and keys.
4. 6. Generate CA certificate adn key using below command
       ./easyrsa build-ca nopass         
5. Generate server certificate using below command
       ./easyrsa build-server-full server nopass       
6. Generate Diffie–Hellman key exchange using below command
       ./easyrsa gen-dh       
       
Install OpenVPN Server
----------------------
   * Ubuntu 16.04/18.04
   --------------------
              sudo apt-get update
              sudo apt-get install openvpn
              cd OpenVPN-Server
              cp server.conf /etc/openvpn/
              cd ../EasyRSA-v3.0.6
              cp pki/issued/server.crt /etc/openvpn/
              cp pki/private/server.key /etc/openvpn/
              cp pki/dh.pem /etc/openvpn/
              cd /etc/openvpn
              openvpn --genkey --secret ta.key       

       
   * Start OpenVPN Server
              sudo systemctl start openvpn@server
     Above commandwill start openvpn server on port 1194/UDP
       

Generate Client Certificate & Configuration file
------------------------------------------------
1. Goto Scripts directory

generate-client-config.sh script is responsible for generating client certifiate and keys along with inline
readymade ovpn configuration file. 

It take 3 arguments as listed below
./generate-client-config.sh <client_first_name> <operating_system> <passphrase>

2. Generate certificate and configuartion file as below
    ./generate-client-config.sh fake_user windows fakepassword
    
3. Newly created configuration file will be available under <ROOT_REPO_DIR>/configs/clients directory

       

