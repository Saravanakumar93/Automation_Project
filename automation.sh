#!/bin/bash

# Declaring Variables

myname="saravanakumar"
s3_bucketname="upgrad-saravanakumar"
timestamp=$(date '+%d%m%Y-%H%M%S')
GREEN=$'\e[0;32m'
NC=$'\e[0m'
Blue=$'\e[0;34m'
Yellow=$'\e[0;33m'
echo
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
   apt --yes install $REQUIRED_PKG
fi
echo ""
echo "${Blue}Enure that the apache2 server is running. If not, start the server${NC}"
echo
servstat=$(systemctl status apache2)

if [[ $servstat == *"running"* ]]; then
   echo "${GREEN}*apache2 is running*${NC}"
 else
   echo "${GREEN}*apache2 is not running*${NC}"
   echo "${GREEN}*apache2 is Starting*${NC}"
   systemctl start apache2
fi
echo ""
echo "${Blue}Ensure that the apache2 service is enabled as a service. If not, enable the service${NC}"
echo
sysstat=$(systemctl is-enabled apache2)

if [[ $sysstat == *"enabled"* ]]; then
   echo "${GREEN}*apache2 service is enabled*${NC}"
 else
   echo "${GREEN}*apache2 service is disabled*${NC}"
   echo "${GREEN}*Enabling apache2 service*${NC}"
   systemctl enable apache2
fi
echo
echo "${Blue}Archive the *.logs from /var/log/apache2/ to /tmp ${NC}"
echo
tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log
echo
echo "${Blue}Copying the logs from /tmp to the S3 bucket${NC}"

aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar s3://${s3_bucketname}/${myname}-httpd-logs-${timestamp}.tar
echo
echo "${Blue}Check for inventory.html file in /var/www/html/ ${NC}"
echo
file="/var/www/html"
name="${myname}-httpd-logs-${timestamp}.tar"
if test -e ${file}/inventory.html; then
      echo "${GREEN}*Inventory file already exists*${NC}"
else
	echo "${GREEN}*Inventory file created*${NC}"
      echo  -e "Log Type\t\tDate Created\t\tType\t\tSize" > ${file}/inventory.html
fi
echo
echo "${Blue}Inserting Logs to inventory.html file in /var/www/html/ ${NC}"
echo
ls -lh /tmp/$name > /tmp/fileSize.txt

size=$(awk '{print $5}' /tmp/fileSize.txt)

echo "${GREEN}*Logs inserted successfully*${NC}"
echo -e "httpd-logs\t\t${timestamp}\t\tTAR\t\t${size}" >> ${file}/inventory.html
echo

echo "${Blue}Creating Cron-job if not exist ${NC}"
echo
if test -e /etc/cron.d/automation; then
      echo "${GREEN}*Cron-Job Scheduled successfully*${NC}"
else
      echo "${GREEN}*Creating Cron-Job*${NC}"
      echo "0 0 * * * root /root/Automation_Project/automation.sh" > /etc/cron.d/automation
fi
echo
#------------------Script Completed-------------------------------------------------------------------------------------------
