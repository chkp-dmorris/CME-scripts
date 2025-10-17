#!/bin/bash

# =============================================================================
# Check Point Gateway Configuration Script - Configured Version
# =============================================================================

# BANNER MESSAGE CONFIGURATION (customize your banner messages)
BANNER_ENABLED="on"
BANNER_LINE1="YOUR_BANNER_LINE_1"
BANNER_LINE2="YOUR_BANNER_LINE_2"
BANNER_LINE3="YOUR_BANNER_LINE_3"
MOTD_ENABLED="off"

# EXPERT PASSWORD AND SESSION SETTINGS
EXPERT_PASSWORD_HASH='YOUR_EXPERT_PASSWORD_HASH'
INACTIVITY_TIMEOUT="YOUR_SESSION_TIMEOUT_MINUTES"

# PROXY SETTINGS (configure proxy details and enable if needed)
PROXY_ENABLED="false"
PROXY_ADDRESS="YOUR_PROXY_SERVER_IP"
PROXY_PORT="YOUR_PROXY_PORT"

# RBA ROLES (configure role names and enable if needed)
RBA_ENABLED="false"
RBA_ROLE_TACP0="YOUR_LEVEL0_ROLE_NAME"
RBA_ROLE_TACP15="YOUR_ADMIN_ROLE_NAME"
RBA_TACP0_FEATURES="tacacs_enable,selfpasswd"

# TACACS+ SERVER SETTINGS (configure values and enable if needed)
TACACS_ENABLED="false"
TACACS_SERVER_IP="YOUR_TACACS_SERVER_IP"
TACACS_SECRET_KEY="YOUR_SECRET_KEY"
TACACS_TIMEOUT="5"
TACACS_USER_UID="0"

# LOCAL USER SETTINGS (configure user details and enable if needed)
LOCAL_USER_ENABLED="false"
LOCAL_USERNAME="YOUR_USERNAME"
LOCAL_USER_UID="0"
LOCAL_USER_GID="0"
LOCAL_USER_HOMEDIR="/home/YOUR_USERNAME"
LOCAL_USER_SHELL="/etc/cli.sh"
LOCAL_USER_REALNAME="YOUR_REAL_NAME"
LOCAL_USER_PASSWORD_HASH='YOUR_PASSWORD_HASH'
LOCAL_USER_ROLE="adminRole"

# SSH KEY CONFIGURATION (configure your SSH public key and enable if needed)
SSH_KEYS_ENABLED="false"
SSH_PUBLIC_KEY="YOUR_SSH_PUBLIC_KEY_HERE"

# SYSLOG SERVER SETTINGS (configure server details and enable if needed)
SYSLOG_ENABLED="false"
SYSLOG_SERVER_IP="YOUR_SYSLOG_SERVER_IP"
SYSLOG_LEVEL="info"

# SNMP SETTINGS (configure SNMP details and enable if needed)
SNMP_ENABLED="false"
SNMP_AGENT_STATE="on"
SNMP_AGENT_INTERFACE="any"
SNMP_CONTACT="YOUR_SNMP_CONTACT"
SNMP_TRAP_RECEIVER_IP="YOUR_SNMP_RECEIVER_IP"
SNMP_TRAP_VERSION_V3="v3"
SNMP_TRAP_VERSION_V2="v2"
SNMP_COMMUNITY="YOUR_SNMP_COMMUNITY"

# NTP AND TIMEZONE SETTINGS (configure time settings and enable if needed)
NTP_ENABLED="false"
NTP_PRIMARY_SERVER="YOUR_PRIMARY_NTP_SERVER"
NTP_SECONDARY_SERVER="YOUR_SECONDARY_NTP_SERVER"
NTP_VERSION="4"
TIMEZONE="YOUR_TIMEZONE"

# DNS SETTINGS (configure DNS details and enable if needed)
DNS_ENABLED="false"
DNS_PRIMARY="YOUR_PRIMARY_DNS_SERVER"
DNS_SECONDARY="YOUR_SECONDARY_DNS_SERVER"
DNS_SUFFIX="YOUR_DNS_SUFFIX"
DOMAIN_NAME="YOUR_DOMAIN_NAME"

# =============================================================================
# SCRIPT EXECUTION BEGINS HERE
# =============================================================================

set -e
lock=""
lock="$(confLock -o -iadmin)"

function run {
        local cmd="$1"
        clish -l "$lock" -s -c "$cmd"
}

# Set banner message for compliance
echo "Configuring banner messages..."
run "set message banner $BANNER_ENABLED"
if [ "$BANNER_ENABLED" = "on" ]; then
    run "set message banner on line msgvalue \"$BANNER_LINE1\""
    run "set message banner on line msgvalue \"$BANNER_LINE2\""
    run "set message banner on line msgvalue \"$BANNER_LINE3\""
fi
run "set message motd $MOTD_ENABLED"

# Set expert password hash and session timeout
echo "Configuring expert password and session timeout..."
run "set expert-password-hash $EXPERT_PASSWORD_HASH"
run "set inactivity-timeout $INACTIVITY_TIMEOUT"

# Set proxy if enabled
if [ "$PROXY_ENABLED" = "true" ]; then
    echo "Configuring proxy settings..."
    run "set proxy address $PROXY_ADDRESS port $PROXY_PORT"
fi

# Add RBA roles if enabled
if [ "$RBA_ENABLED" = "true" ]; then
    echo "Configuring RBA roles..."
    run "add rba role $RBA_ROLE_TACP0 domain-type System readwrite-features $RBA_TACP0_FEATURES"
    run "add rba role $RBA_ROLE_TACP15 domain-type System all-features"
fi

# Add TACACS+ server if enabled
if [ "$TACACS_ENABLED" = "true" ]; then
    echo "Configuring TACACS+ server..."
    run "add aaa tacacs-servers priority 1 server $TACACS_SERVER_IP key $TACACS_SECRET_KEY timeout $TACACS_TIMEOUT"
    run "set aaa tacacs-servers user-uid $TACACS_USER_UID"
    run "set aaa tacacs-servers state on"
fi

# Add local user if enabled
if [ "$LOCAL_USER_ENABLED" = "true" ]; then
    echo "Configuring local user..."
    run "add user $LOCAL_USERNAME uid $LOCAL_USER_UID homedir $LOCAL_USER_HOMEDIR"
    run "set user $LOCAL_USERNAME gid $LOCAL_USER_GID shell $LOCAL_USER_SHELL"
    run "set user $LOCAL_USERNAME realname \"$LOCAL_USER_REALNAME\""
    run "set user $LOCAL_USERNAME password-hash $LOCAL_USER_PASSWORD_HASH"
    run "add rba user $LOCAL_USERNAME roles $LOCAL_USER_ROLE"
fi

# Configure SSH keys if enabled (for R80.30 or lower)
if [ "$SSH_KEYS_ENABLED" = "true" ]; then
    echo "Configuring SSH keys..."
    cd /home/admin
    mkdir -p .ssh 
    chmod u=rwx,g=,o= .ssh
    touch .ssh/authorized_keys
    touch .ssh/authorized_keys2
    chmod u=rw,g=,o= .ssh/authorized_keys
    chmod u=rw,g=,o= .ssh/authorized_keys2

    cat >> .ssh/authorized_keys <<EOF
$SSH_PUBLIC_KEY
EOF

    cat >> .ssh/authorized_keys2 <<EOF
$SSH_PUBLIC_KEY
EOF
fi

# Configure syslog if enabled
if [ "$SYSLOG_ENABLED" = "true" ]; then
    echo "Configuring syslog server..."
    run "add syslog log-remote-address $SYSLOG_SERVER_IP level $SYSLOG_LEVEL"
fi

# Configure SNMP if enabled
if [ "$SNMP_ENABLED" = "true" ]; then
    echo "Configuring SNMP..."
    run "set snmp agent $SNMP_AGENT_STATE"
    run "set snmp agent $SNMP_AGENT_INTERFACE"
    run "set snmp contact \"$SNMP_CONTACT\""
    run "set snmp traps receiver $SNMP_TRAP_RECEIVER_IP version $SNMP_TRAP_VERSION_V3"
    run "set snmp traps receiver $SNMP_TRAP_RECEIVER_IP community $SNMP_COMMUNITY version $SNMP_TRAP_VERSION_V2"
fi

# Configure NTP and timezone if enabled
if [ "$NTP_ENABLED" = "true" ]; then
    echo "Configuring NTP and timezone..."
    run "set ntp active on"
    run "set ntp server primary $NTP_PRIMARY_SERVER version $NTP_VERSION"
    run "set ntp server secondary $NTP_SECONDARY_SERVER version $NTP_VERSION"
    run "set timezone $TIMEZONE"
fi

# Configure DNS if enabled
if [ "$DNS_ENABLED" = "true" ]; then
    echo "Configuring DNS settings..."
    run "set dns primary $DNS_PRIMARY"
    run "set dns secondary $DNS_SECONDARY"
    run "set dns suffix $DNS_SUFFIX"
    run "set domainname $DOMAIN_NAME"
fi

# Filesystem or other commands section
echo "Additional filesystem or custom commands can be added here..."

# Script finishes
echo "Configuration script completed successfully."
exit