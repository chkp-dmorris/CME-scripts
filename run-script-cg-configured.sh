#!/bin/bash

# =============================================================================
# Check Point Gateway Configuration Script - Configured Version
# =============================================================================

# BANNER MESSAGE CONFIGURATION (customize your banner messages)
BANNER_ENABLED="on"
BANNER_LINE1="Test line 1"
BANNER_LINE2="Test line 2"
BANNER_LINE3="Test line 3"
MOTD_ENABLED="off"

# EXPERT PASSWORD AND SESSION SETTINGS
EXPERT_PASSWORD_HASH='$6$EKyD28XSeApxVKAc$jdbH9i/tS.UvEbcU3qxVMPMdgwXAMxMzrhKUScSVmMDy30VO2sBBDJ0OMEkgMxrR3eFD7YnT9p0ZF2jcHH5ln/'
INACTIVITY_TIMEOUT="720"

# PROXY SETTINGS (configure proxy details and enable if needed)
PROXY_ENABLED="false"
PROXY_ADDRESS="YOUR_PROXY_SERVER_IP"
PROXY_PORT="YOUR_PROXY_PORT"

# RBA ROLES (configure role names and enable if needed)
RBA_ENABLED="false"
RBA_ROLE_TACP0="YOUR_LEVEL0_ROLE_NAME"
RBA_ROLE_TACP15="YOUR_ADMIN_ROLE_NAME"
RBA_TACP0_FEATURES="YOUR_TACP0_FEATURES"

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
LOCAL_USER_ROLE="YOUR_USER_ROLE"

# SSH KEY CONFIGURATION (configure SSH user and keys, enable if needed)
SSH_KEYS_ENABLED="false"
SSH_USERNAME="YOUR_SSH_USERNAME"
SSH_USER_UID="YOUR_SSH_USER_UID"
SSH_USER_GID="YOUR_SSH_USER_GID"
SSH_USER_HOMEDIR="/home/YOUR_SSH_USERNAME"
SSH_USER_SHELL="/etc/cli.sh"
SSH_USER_REALNAME="YOUR_SSH_USER_REALNAME"
SSH_USER_PASSWORD_HASH="YOUR_SSH_USER_PASSWORD_HASH"
SSH_USER_ROLE="YOUR_SSH_USER_ROLE"
SSH_PUBLIC_KEY="YOUR_SSH_PUBLIC_KEY_HERE"

# SYSLOG SERVER SETTINGS (configure server details and enable if needed)
SYSLOG_ENABLED="true"
SYSLOG_SERVER_IP="1.2.3.4"
SYSLOG_LEVEL="all"

# SNMP SETTINGS (configure SNMP details and enable if needed)
SNMP_ENABLED="true"
SNMP_AGENT_STATE="on"
SNMP_CONTACT="dmorris@checkpoint.com"
SNMP_TRAP_RECEIVER_IP="1.2.3.5"
SNMP_VERSION="v3"
SNMP_COMMUNITY="public"

# NTP AND TIMEZONE SETTINGS (configure time settings and enable if needed)
NTP_ENABLED="true"
NTP_PRIMARY_SERVER="1.2.3.5"
NTP_SECONDARY_SERVER="1.2.3.6"
NTP_VERSION="4"
TIMEZONE="America/New_York"

# DNS SETTINGS (configure DNS details and enable if needed)
DNS_ENABLED="true"
DNS_PRIMARY="1.2.3.4"
DNS_SECONDARY="1.2.3.5"
DNS_SUFFIX="checkpoint.com"
DOMAIN_NAME="checkpoint.com"

# =============================================================================
# SCRIPT EXECUTION BEGINS HERE
# =============================================================================

# Setup logging
LOGFILE="/var/log/cme_custom_gateway_scripts.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "=========================================="
echo "Check Point Gateway Configuration Script"
echo "Started: $(date)"
echo "=========================================="

set -e
lock=""
lock="$(confLock -o -iadmin)"

function run {
        local cmd="$1"
        echo "Executing: $cmd"
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

# Configure SSH keys if enabled (using CLISH commands)
if [ "$SSH_KEYS_ENABLED" = "true" ]; then
    echo "Configuring SSH user and keys..."
    # Create/configure the SSH user with all necessary parameters
    run "add user $SSH_USERNAME uid $SSH_USER_UID homedir $SSH_USER_HOMEDIR"
    run "set user $SSH_USERNAME gid $SSH_USER_GID shell $SSH_USER_SHELL"
    run "set user $SSH_USERNAME realname \"$SSH_USER_REALNAME\""
    run "set user $SSH_USERNAME password-hash $SSH_USER_PASSWORD_HASH"
    run "set user $SSH_USERNAME ssh-public-key \"$SSH_PUBLIC_KEY\""
    run "add rba user $SSH_USERNAME roles $SSH_USER_ROLE"
    echo "SSH user and key configured for: $SSH_USERNAME"
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
    run "set snmp contact \"$SNMP_CONTACT\""
    
    # Configure SNMP trap receiver based on version
    if [ "$SNMP_VERSION" = "v3" ]; then
        # SNMP v3 uses USM authentication, no community string
        run "add snmp traps receiver $SNMP_TRAP_RECEIVER_IP version v3"
    elif [ "$SNMP_VERSION" = "v2" ] || [ "$SNMP_VERSION" = "v2c" ]; then
        # SNMP v2/v2c requires community string
        run "add snmp traps receiver $SNMP_TRAP_RECEIVER_IP community $SNMP_COMMUNITY version v2"
    elif [ "$SNMP_VERSION" = "v1" ]; then
        # SNMP v1 requires community string
        run "add snmp traps receiver $SNMP_TRAP_RECEIVER_IP community $SNMP_COMMUNITY version v1"
    fi
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
echo "=========================================="
echo "Configuration script completed successfully."
echo "Completed: $(date)"
echo "Log file: $LOGFILE"
echo "=========================================="
exit