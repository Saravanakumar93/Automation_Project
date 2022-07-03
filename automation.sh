#!/bin/bash

# Declaring Variables

myname=saravanakumar
s3_bucketname=upgrad-saravanakumar
timestamp=$(date '+%d%m%Y-%H%M%S')
GREEN=$'\e[0;32m'
NC=$'\e[0m'
Blue=$'\e[0;34m'
Yellow=$'\e[0;33m'

echo "${Blue}Updating the Packages${NC}"
echo
apt update -y
echo ""
echo "${Blue}Ensure that the apache2 server is installed. If not, install apache2${NC}"
echo ""
REQUIRED_PKG="apache2"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo "${Yellow}Checking for $REQUIRED_PKG: ${GREEN}$PKG_OK${NC}"
if [ "" = "$PKG_OK" ]; then
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
  sudo apt --yes install $REQUIRED_PKG
fi
echo ""
#service apache2 status
#sudo service apache2 start

echo "${Blue}Enure that the apache2 server is running. If not, start the server${NC}"
echo
servstat=$(systemctl status apache2)

if [[ $servstat == *"running"* ]]; then
   echo "${GREEN}apache2 is running${NC}"
 else
   echo "${GREEN}apache2 is not running${NC}"
   echo "${GREEN}apache2 is Starting${NC}"
   systemctl start apache2
fi
echo ""
echo "${Blue}Ensure that the apache2 service is enabled as a service. If not, enable the service${NC}"
echo
sysstat=$(systemctl is-enabled apache2)

if [[ $sysstat == *"enabled"* ]]; then
   echo "${GREEN}apache2 service is enabled${NC}"
 else
   echo "${GREEN}apache2 service is disabled${NC}"
   echo "${GREEN}Enabling apache2 service${NC}"
   systemctl enable apache2
fi
echo
echo "${Blue}Archive the *.logs from /var/log/apache2/ to /tmp ${NC}"
echo
tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log
echo
echo "${Blue}Copying the logs from /tmp to the S3 bucket${NC}"

aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar s3://${s3_bucketname}/${myname}-httpd-logs-${timestamp}.tar
