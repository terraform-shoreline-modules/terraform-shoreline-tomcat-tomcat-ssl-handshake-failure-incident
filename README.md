
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Tomcat SSL Handshake Failure Incident
---

This incident type usually occurs when there is a failure in the SSL Handshake process between a client and server running on a Tomcat web server. This can happen for various reasons such as incorrect SSL certificate configuration, cipher suite mismatches, or network connectivity issues. When this type of incident is not resolved quickly, it can lead to downtime or service disruptions for users trying to access the affected service.

### Parameters
```shell

export PATH_TO_SSL_CERTIFICATE="PLACEHOLDER"

export PORT_NUMBER="PLACEHOLDER"

export HOSTNAME="PLACEHOLDER"

export CIPHER_SUITE="PLACEHOLDER"

export PATH_TO_CERTIFICATE="PLACEHOLDER"

export SERVER_CIPHER_SUITE="PLACEHOLDER"

export CLIENT_CIPHER_SUITE="PLACEHOLDER"
```

## Debug

### Check if Tomcat service is running
```shell
systemctl status tomcat.service
```

### Check Tomcat server.xml file for SSL configuration
```shell
grep -i "ssl" /etc/tomcat/conf/server.xml
```

### Check if SSL certificate is valid and not expired
```shell
openssl x509 -enddate -noout -in ${PATH_TO_SSL_CERTIFICATE}
```

### Check if SSL certificate is configured correctly
```shell
openssl s_client -connect ${HOSTNAME}:${PORT_NUMBER} -tls1_2
```

### Check if cipher suites are configured correctly
```shell
openssl s_client -connect ${HOSTNAME}:${PORT_NUMBER} -tls1_2 -cipher ${CIPHER_SUITE}
```

### Check network connectivity between client and server
```shell
ping ${HOSTNAME}
```

### Check firewall rules to ensure they are not blocking SSL traffic
```shell
iptables -L
```

## Repair

### Check the SSL certificate configuration and make sure that it is valid and properly installed on the server.
```shell


#!/bin/bash



# Set the path to the SSL certificate

CERT_PATH=${PATH_TO_CERTIFICATE}



# Verify that the certificate is valid and properly installed

openssl x509 -in $CERT_PATH -noout -check



# If the certificate is not valid, print an error message and exit

if [ $? -ne 0 ]; then

    echo "Error: The SSL certificate is not valid or is not properly installed."

    exit 1

fi



# If the certificate is valid, print a success message

echo "Success: The SSL certificate is valid and properly installed."


```

### Verify that the cipher suites used by the client and server are compatible and properly configured. If necessary, update the cipher suite configuration on either the client or server to match the other.
```shell


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


```