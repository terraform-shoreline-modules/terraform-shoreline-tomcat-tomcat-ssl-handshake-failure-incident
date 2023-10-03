

#!/bin/bash



# Set variables for client and server cipher suites

client_cipher_suite=${CLIENT_CIPHER_SUITE}

server_cipher_suite=${SERVER_CIPHER_SUITE}



# Check the current cipher suite configuration on the server

current_server_cipher_suite=$(grep -i sslprotocol /etc/tomcat/server.xml)



# If the current server cipher suite is not the same as the desired one, update the server configuration

if [[ $current_server_cipher_suite != *$server_cipher_suite* ]]; then

    sed -i 's|.*sslProtocol=.*|   sslProtocol="$server_cipher_suite"|g' /etc/tomcat/server.xml

    systemctl restart tomcat

fi



# Check the current cipher suite configuration on the client

current_client_cipher_suite=$(grep -i sslprotocol /etc/httpd/conf.d/ssl.conf)



# If the current client cipher suite is not the same as the desired one, update the client configuration

if [[ $current_client_cipher_suite != *$client_cipher_suite* ]]; then

    sed -i 's|.*SSLCipherSuite .*|   SSLCipherSuite $client_cipher_suite|g' /etc/httpd/conf.d/ssl.conf

    systemctl restart httpd

fi