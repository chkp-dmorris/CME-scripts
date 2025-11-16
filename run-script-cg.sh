#!/bin/bash
set -e
lock=""
lock="$(confLock -o -iadmin)"
function run {
        local cmd="$1"
        clish -l "$lock" -s -c "$cmd"
}

# set banner message for compliance (if required)

run 'set message banner off'
run 'set message banner on'
run 'set message banner on line msgvalue "RESTRICTED ACCESS"'
run 'set message banner on line msgvalue "This System is private and confidential"'
run 'set message banner on line msgvalue "This system is for the use of authorized users only"'
run 'set message motd off'

# set expert password hash and session timeout 

run 'set expert-password-hash $1$BBIBBD]S$6RpUI8d/eY37HH9VSly8F.'
run 'set inactivity-timeout 100'

# set proxy (if required)

# run 'set proxy address a.b.c.d port zz'

# add RBA user, RADIUS, and TACACS+ roles (if required) (adminRole and monitorRole already defined.)

#run 'add rba role TACP-0 domain-type System readwrite-features tacacs_enable,selfpasswd'
#run 'add rba role TACP-15 domain-type System all-features'

# add RADIUS / TACACS server(s)
#run 'add aaa tacacs-servers priority 1 server a.b.c.d key mysecretkey timeout 5'
#run 'set aaa tacacs-servers user-uid 0' 
# run 'set aaa tacacs-servers state on' 

# add local users (if required)

#run 'add user securityteam uid 0 homedir /home/securityteam'
#run 'set user securityteam gid 0 shell /etc/cli.sh'
#run 'set user securityteam realname "Security Team"'
#run 'set user securityteam password-hash $1$ocoA1HXt$i9lqlqouBiaEqNH0d1u1'
#run 'add rba user securityteam roles adminRole'

# OpenSSH keys

# If version is R80.40 or higher, OpenSSH keys are managed with CLISH commands

# If version R80.30 or lower, OpenSSH keys are managed with shell commands

#cd /home/admin
#mkdir -p .ssh 
#chmod u=rwx,g=,o=  .ssh
#touch .ssh/authorized_keys
#touch .ssh/authorized_keys2
#chmod u=rw,g=,o=  .ssh/authorized_keys
#chmod u=rw,g=,o=  .ssh/authorized_keys2

#cat >> .ssh/authorized_keys <<EOF
#ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAgEA6rBZuY+YC16TzHDD+zWo7Gbcrw561gZ6EN+M1Z4hNiKTkQm9cpsVKK9lsb8BEHoWU2E6zoyEniA2cK6A3XQAOb+S1Jj90o8uEWuQrNoPz4J8cFwPjdr1PM7D+bahrp3m1355fTTK2upVV6bKUs4157Bvgd9bl89a+p2E7Xcu0I46CCq8gn9Ra7OETTwCmLvaQ5rUEgyrGTQAGcWDX1sFjobR91KokWeyAq0fZ7cKwztbhfXuaFSalDlJxdcZuKVVw3pFsGKGgD40nRysZPKb2sqTxZflH1ZYJls3O44yGqCcp2tMU4TxrCi5oJXbevpJ5fldsGy1AxoAWtkLvit29K3hSuwD3muZAd1lckbowj1YBN5xuw4NrmnKs3klIeIvOqIfIUH6GNTBDr+ceMrzd7gWZaBAzPkQMQLnc4v7N2YpMzPTSgQpA8/qaPHaZ0lQUOsAfnWTdhA1DQDSn+p6KFUYHDp2v/XJ0CYRYBOUCNsU/Do2b1eGpnL6EX6y43ENbeGFFhv59gBieJDr6kn9+hmSNWWHNlIoCmHIfCo85AJflT0bMDwKUlUi4RDRWMdXfdq0LqSsWqkhiJabtQM9SspamMe600jX0VLCgEDOpT4YApOeUsGyXMQFIUa9aDqqNw7u+kwDjPaT5yxmGXIYhByUVX+CraqScdlOG8A0BuU= admin@testsms
#
#EOF
#cat >> .ssh/authorized_keys2 <<EOF2
#ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAgEA6rBZuY+YC16TzHDD+zWo7Gbcrw561gZ6EN+M1Z4hNiKTkQm9cpsVKK9lsb8BEHoWU2E6zoyEniA2cK6A3XQAOb+S1Jj90o8uEWuQrNoPz4J8cFwPjdr1PM7D+bahrp3m1355fTTK2upVV6bKUs4157Bvgd9bl89a+p2E7Xcu0I46CCq8gn9Ra7OETTwCmLvaQ5rUEgyrGTQAGcWDX1sFjobR91KokWeyAq0fZ7cKwztbhfXuaFSalDlJxdcZuKVVw3pFsGKGgD40nRysZPKb2sqTxZflH1ZYJls3O44yGqCcp2tMU4TxrCi5oJXbevpJ5fldsGy1AxoAWtkLvit29K3hSuwD3muZAd1lckbowj1YBN5xuw4NrmnKs3klIeIvOqIfIUH6GNTBDr+ceMrzd7gWZaBAzPkQMQLnc4v7N2YpMzPTSgQpA8/qaPHaZ0lQUOsAfnWTdhA1DQDSn+p6KFUYHDp2v/XJ0CYRYBOUCNsU/Do2b1eGpnL6EX6y43ENbeGFFhv59gBieJDr6kn9+hmSNWWHNlIoCmHIfCo85AJflT0bMDwKUlUi4RDRWMdXfdq0LqSsWqkhiJabtQM9SspamMe600jX0VLCgEDOpT4YApOeUsGyXMQFIUa9aDqqNw7u+kwDjPaT5yxmGXIYhByUVX+CraqScdlOG8A0BuU= admin@testsms
#
#EOF2

# here-document with any ssh keys to append

# syslog server settings

#run 'add syslog log-remote-address a.b.c.d  level info'

# SNMP v2 and v3 settings

#run 'set snmp agent on'
#run 'set snmp agent any'
#run 'set snmp contact "Administrator"'
#run 'set snmp traps receiver a.b.c.d version v3'
#run 'set snmp traps receiver a.b.c.d community verysecret version v2'

# run 'set snmp usm.....'


# time date timezone and ntp settings

#run 'set ntp active on'
#run 'set ntp server primary europe.pool.ntp.org version 4'
#run 'set ntp server secondary 0.pool.ntp.org version 4'
#run 'set timezone Etc / GMT'

# DNS settings

#run 'set dns primary a.b.c.d'
#run 'set dns secondary a.b.c.d'
#run 'set dns suffix companyname.local'
#run 'set domainname companyname.com'

# backup

# Filesystem or other commands:

# any 'cp_log_export' commands (if management) or other bash commands / scripts.

# etc..!

# script finishes
exit

