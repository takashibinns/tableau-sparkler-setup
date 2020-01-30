
#!/bin/bash

#######################################################################
# To call, use the following syntax
# sudo setup.sh "/path/to/config"   										  #
#######################################################################

# Read variable definitions from the config file
CONFIG_PATH=$1;     # Path to the config file
source $CONFIG_PATH

#######################################################################
# 	Step 1: Install Tomcat 											  #
#######################################################################

#	Install the java jdk
yum install -y java-1.7.0-openjdk-devel

#	Create the local user & group to run as (both named tomcat)
groupadd tomcat
useradd -M -s /bin/nologin -g tomcat -d /opt/tomcat tomcat

#	Download/unpack the tomcat files
wget -O /opt/tomcat.tar.gz $TOMCAT_DOWNLOAD
tar xvf /opt/tomcat.tar.gz -C /opt/tomcat --strip-components=1

#	Update permissions
chgrp -R tomcat /opt/tomcat
chown -R tomcat /opt/tomcat/webapps /opt/tomcat/webapps /opt/tomcat/work /opt/tomcat/temp /opt/tomcat/logs
chmod -R g+r /opt/tomcat/conf
chmod g+x /opt/tomcat/conf

#	Use the systemd definition to have tomcat run as a service
echo "# Systemd unit file for tomcat
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=forking
Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/bin/kill -15 $MAINPID

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/tomcat.service

#	Restart systemd, to pick up on this new unit
systemctl daemon-reload
