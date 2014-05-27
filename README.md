rudder-install
==============

Script d'installation d'agent rudder pour RHEL et Centos 5 et 6

ChangeLog
---------

06/05/2014 : v0
    Init Version
07/05/2014 : v0.1
    Add check for availability of RHEL Repo
    Add check for configuration file
08/05/2014 : v0.2
    Add check if already installed
12/05/2014 : v0.3
    Add modify hosts file (thanks WL)
26/05/2014 : v1.0
    Change $BASHPID to $$ for more compatibility
    Add redirect cf-agent output to /dev/null
    Modify hosts file just before runing agent (better)
    Add --nogpg to yum install (thanks JR)
    Change pre message chars to '---' for information and '@@@' for error
    Add check for process avec starting service
    Change date in ChangeLog section to be french compliance :)
    Force error message to be send to std & error output (thanks JR)
27/05/2014 : v1.1
    Compliante with shellcheck.net
