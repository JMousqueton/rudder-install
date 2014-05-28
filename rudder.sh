#!/bin/bash
########################################################################################################
# Deploy Rudder Agent on RHEL/CENTOS v5 and v6
# by Julien Mousqueton / Twitter : @JMousqueton
#
# ChangeLog : 
#   06/05/2014 : v0 
#      	Init Version  
#   07/05/2014 : v0.1
#       Add check for availability of RHEL Repo 
#       Add check for configuration file
#   08/05/2014 : v0.2
#       Add check if already installed 
#	12/05/2014 : v0.3
#		Add modify hosts file (thanks WL)
#	26/05/2014 : v1.0
#		Change $BASHPID to $$ for more compatibility 
#		Add redirect cf-agent output to /dev/null
#		Modify hosts file just before runing agent (better)
#		Add --nogpg to yum install (thanks JR)
#		Change pre message chars to '---' for information and '@@@' for error
#		Add check for process avec starting service 
#		Change date in ChangeLog section to be french compliance :) 
#		Force error message to be send to std & error output (thanks JR)
#	27/05/2014 : v1.1
#		Compliante with shellcheck.net
########################################################################################################
#
# Configuration 
#
# Rudder Version 
RUDDERVERSION=2.10
# Ruddder Server
RUDDERSERVER=rudder
#
########################################################################################################
# DO NOT EDIT BELLOW THIS LINE 
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
    echo "@@@ Rudder-agent v$(rpm -aq rudder-agent | cut -c 14-19) already installed" 1>&2
    exit 1;
fi
#
OSVERSION=$(rpm -q --queryformat '%{RELEASE}' "$(rpm -qa '(redhat|sl|centos|oraclelinux)-release(|-server|-workstation|-client|-computenode)')" |cut -c -1)
#
echo "--- Creating Repo's file for Rudder version $RUDDERVERSION on RHEL $OSVERSION"
#
echo "[Rudder_$RUDDERVERSION]
name=Rudder $RUDDERVERSION Repository
baseurl=http://www.rudder-project.org/rpm-$RUDDERVERSION/RHEL_$OSVERSION/
gpgcheck=1
gpgkey=http://www.rudder-project.org/rpm-$RUDDERVERSION/RHEL_$OSVERSION/repodata/repomd.xml.key
" > /etc/yum.repos.d/rudder.repo
#
if (("$OSVERSION" == "6")); then
	echo --- Installating dependences for Rudder Agent v$RUDDERVERSION
	yum install tokyocabinet -y 
	if ! rpm -qa | grep -qw tokyocabinet; then
  	  echo "@@@ Failed to connect to OS repository" 1>&2
    	exit 1;
	fi
fi
#
echo --- Installing Rudder Agent v$RUDDERVERSION
#
yum --nogpg install rudder-agent -y
#
if ! rpm -qa | grep -qw rudder-agent; then
    echo "@@@ Rudder-agent v$RUDDERVERSION not installed" 1>&2
    exit 1;
fi
#
echo --- Configuring Rudder Roor Server : $RUDDERSERVER
#
echo $RUDDERSERVER > /var/rudder/cfengine-community/policy_server.dat
#
if [ ! -f /var/rudder/cfengine-community/policy_server.dat ]
then
    echo "@@@ Configuring Rudder Agent failed" 1>&2
    exit 1;
fi
#
# Modify hosts file for installation purpose
#
mv /etc/hosts /etc/hosts.$$
echo "127.0.0.1 localhost" > /etc/hosts
#
echo --- Starting rudder-agent v$RUDDERVERSION
#
/etc/init.d/rudder-agent start > /dev/null 
#
# Verify rudder-agent is starting 
PROCESS_RUDDER=$(pgrep -f "cfengine-community" | wc -l)
if [ "$PROCESS_RUDDER" -eq "2" ];
        then
				echo --- Force rudder-agent to contact $RUDDERSERVER
				# 
				/var/rudder/cfengine-community/bin/cf-agent -KI > /dev/null
				#
        else
			echo "@@@ Error rudder-agent is not running" 1>&2 
        fi
#
# Restore original /etc/hosts file
#
rm -f /etc/hosts
mv /etc/hosts.$$ /etc/hosts
if [ ! -f /etc/hosts ]
then
    echo "@@@ Error while restoring original hosts file" 1>&2
    exit 1;
fi
#
# end of script
#
