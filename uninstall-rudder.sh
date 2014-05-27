#!/bin/bash
########################################################################################################
# Uninstall Rudder Agent on RHEL/CENTOS v5 and v6
# by Julien Mousqueton / Twitter : @JMousqueton
#
# ChangeLog : 
#   26/05/2014 : v0 
#      	Init Version  
########################################################################################################
#
# Make sure only root can run our script
#
if [ "$(id -u)" != "0" ]; then
   echo "@@@ This script must be run as root" 1>&2
   exit 1;
fi
#
# check if rudder-agent is already installed 
#
if rpm -qa | grep -w rudder-agent; then
    echo --- Rudder-agent v`rpm -aq rudder-agent | cut -c 14-19` will be removed
else 
	echo "@@@ Rudder-Agent not installed " 1>&2
	exit 1;
fi
#
yum --nogpg remove rudder-agent -y
#
if rpm -qa | grep -qw rudder-agent; then
    echo "@@@ Rudder-agent still installed" 1>&2
    exit 1;
fi
#
echo --- Remove Configuration 
#
rm -Rf /var/rudder
if [ -f /var/rudder/ ]
then
    echo "@@@ Removing Rudder Agent failed" 1>&2
fi
#
rm -Rf /opt/rudder
if [ -f /opt/rudder/ ]
then
    echo "@@@ Removing Rudder Agent failed" 1>&2
fi
#
# end of script
#
