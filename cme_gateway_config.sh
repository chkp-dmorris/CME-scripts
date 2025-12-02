#!/bin/bash

# =============================================================================
# Check Point Gateway Configuration Script - Configured Version
# =============================================================================

# Exit codes for CME
SUCCESS=0
FAILURE=1

# REBOOT CONFIGURATION (set to "true" if gateway needs reboot after changes)
REBOOT_REQUIRED="false"

# BANNER MESSAGE CONFIGURATION (customize your banner messages)
BANNER_ENABLED="false"
BANNER_LINE1="YOUR_BANNER_LINE_1"
#BANNER_LINE2="YOUR_BANNER_LINE_2"
#BANNER_LINE3="YOUR_BANNER_LINE_3"
MOTD_ENABLED="off"

# EXPERT PASSWORD AND SESSION SETTINGS (Uncomment and set values to enable)
# EXPERT_PASSWORD_HASH='YOUR_EXPERT_PASSWORD_HASH_HERE'
# INACTIVITY_TIMEOUT="720"

# PROXY SETTINGS (configure proxy details and enable if needed)
PROXY_ENABLED="false"
PROXY_ADDRESS="YOUR_PROXY_ADDRESS"
PROXY_PORT="8080"

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
SYSLOG_ENABLED="false"
SYSLOG_SERVER_IP="YOUR_SYSLOG_SERVER_IP"
SYSLOG_LEVEL="all"

# SNMP SETTINGS (configure SNMP details and enable if needed)
SNMP_ENABLED="false"
SNMP_AGENT_STATE="on"
SNMP_CONTACT="YOUR_EMAIL@COMPANY.COM"
SNMP_TRAP_RECEIVER_IP="YOUR_SNMP_SERVER_IP"
SNMP_VERSION="v3"
SNMP_COMMUNITY="public"

# NTP AND TIMEZONE SETTINGS (configure time settings and enable if needed)
NTP_ENABLED="false"
NTP_PRIMARY_SERVER="YOUR_PRIMARY_NTP_SERVER"
#NTP_SECONDARY_SERVER="YOUR_SECONDARY_NTP_SERVER"
NTP_VERSION="4"
TIMEZONE="YOUR_TIMEZONE"

# DNS SETTINGS (configure DNS details and enable if needed)
DNS_ENABLED="false"
DNS_PRIMARY="YOUR_PRIMARY_DNS"
#DNS_SECONDARY="YOUR_SECONDARY_DNS"
#DNS_SUFFIX="YOUR_DOMAIN.COM"
#DOMAIN_NAME="YOUR_DOMAIN.COM"

# CUSTOM CLISH COMMANDS (add your own CLISH commands here)
CUSTOM_CLISH_ENABLED="false"
# Add your custom CLISH commands in the array below (one command per line)
# Example: CUSTOM_CLISH_COMMANDS=( "set static-route 0.0.0.0/0 nexthop gateway address 192.168.1.254 on")
CUSTOM_CLISH_COMMANDS=(
    # set static-route 23.23.23.0/24 nexthop gateway address 172.17.1.1 on
    # YOUR_CUSTOM_COMMAND_2
    # YOUR_CUSTOM_COMMAND_3
)

# CUSTOM BASH COMMANDS (add your own bash/shell commands here - NOT CLISH!)
# WARNING: These are BASH commands that run OUTSIDE of clish!
# Do NOT put clish commands here - use CUSTOM_CLISH_COMMANDS above for clish commands
# Examples of bash commands: file operations, system commands, scripts, etc.
# Example: CUSTOM_BASH_COMMANDS=("echo 'Custom message' >> /var/log/custom.log" "chmod 755 /var/opt/CPshrd-R81/tmp_dir/my_script.sh" "/opt/custom/post_install.sh")
CUSTOM_BASH_ENABLED="false"
CUSTOM_BASH_COMMANDS=(
    "# echo 'Gateway configured successfully with cme script' >> /var/log/deployment.log"
    "# mkdir -p /var/log/custom"
    "# echo 'this works' >> /var/log/custom/test.log"
)

# =============================================================================
# SCRIPT EXECUTION BEGINS HERE
# =============================================================================


# Setup logging
LOGFILE="/var/log/cme_gateway_scripts.elg"
exec > >(tee -a "$LOGFILE") 2>&1

# Track current section for better error reporting
CURRENT_SECTION="Initialization"

# Structured command result codes (for CME log parsing)
CMD_SUCCESS=0
CMD_FAILURE=1
CMD_TOTAL=0
CMD_FAILED=0

# -----------------------------------------------------------------------------
# Logging Helpers
# -----------------------------------------------------------------------------
function TS() { date '+%Y-%m-%d %H:%M:%S'; }
function log_line() { # level section message
    local level="$1"; shift
    local section="$1"; shift
    local msg="$*"
    echo "[$(TS)] [$level] [$section] $msg"
}
function log_info() { log_line INFO "$CURRENT_SECTION" "$*"; }
function log_success() { log_line SUCCESS "$CURRENT_SECTION" "$*"; }
function log_error() { log_line ERROR "$CURRENT_SECTION" "$*"; }
start_section() { local s="$1"; CURRENT_SECTION="$s"; echo "===== SECTION START: $s ====="; log_info "Starting section"; }

echo "===== SCRIPT_START $(TS) ====="

# Error handler function
function handle_error {
    local line_number=$1
    local command="$2"
    local section="$3"
    echo "=========================================="
    log_error "Script execution failed"
    echo "Section: $section"
    echo "Line number: $line_number"
    echo "Failed command: $command"
    echo "Time: $(TS)"
    echo "Check log file: $LOGFILE"
    echo "=========================================="
    exit $FAILURE
}

# Error trap to catch failures
trap 'handle_error $LINENO "$BASH_COMMAND" "$CURRENT_SECTION"' ERR
set -e

echo "=========================================="
echo "Check Point Gateway Configuration Script"
echo "Started: $(TS)"
echo "=========================================="

lock=""
lock="$(confLock -o -iadmin)"

function run {
    local cmd="$1"
    log_info "Executing: $cmd"
    CMD_TOTAL=$((CMD_TOTAL+1))
    if clish -l "$lock" -s -c "$cmd"; then
        log_success "Completed: $cmd"
        echo "CME_CMD|$CURRENT_SECTION|$cmd|$CMD_SUCCESS|$(TS)"
    else
        log_error "Failed: $cmd"
        CMD_FAILED=$((CMD_FAILED+1))
        echo "CME_CMD|$CURRENT_SECTION|$cmd|$CMD_FAILURE|$(TS)"
        return 1
    fi
}

# Set banner message for compliance
start_section "Banner Configuration"
if [ "$BANNER_ENABLED" = "true" ]; then
    log_info "Configuring banner messages"
    run "set message banner on"
    # Use the original syntax that was working in your log
    run "set message banner on line msgvalue \"$BANNER_LINE1\""
    # Only set additional banner lines if they are defined
    if [ -n "$BANNER_LINE2" ]; then
        run "set message banner on line msgvalue \"$BANNER_LINE2\""
    fi
    if [ -n "$BANNER_LINE3" ]; then
        run "set message banner on line msgvalue \"$BANNER_LINE3\""
    fi
    run "set message motd $MOTD_ENABLED"
    log_success "Banner configuration completed"
else
    log_info "Banner configuration skipped (disabled)"
fi

# Set expert password hash and session timeout
start_section "Expert Password Configuration"
log_info "Configuring expert password and session timeout"
if [ -n "$EXPERT_PASSWORD_HASH" ]; then
    run "set expert-password-hash $EXPERT_PASSWORD_HASH"
else
    log_info "Skipping expert password configuration (not defined)"
fi
if [ -n "$INACTIVITY_TIMEOUT" ]; then
    run "set inactivity-timeout $INACTIVITY_TIMEOUT"
else
    log_info "Skipping inactivity timeout configuration (not defined)"
fi

# Set proxy if enabled
start_section "Proxy Configuration"
if [ "$PROXY_ENABLED" = "true" ]; then
    log_info "Configuring proxy settings"
    run "set proxy address $PROXY_ADDRESS port $PROXY_PORT"
    log_success "Proxy configuration completed"
else
    log_info "Proxy configuration skipped (disabled)"
fi

# Add RBA roles if enabled
start_section "RBA Configuration"
if [ "$RBA_ENABLED" = "true" ]; then
    log_info "Configuring RBA roles"
    run "add rba role $RBA_ROLE_TACP0 domain-type System readwrite-features $RBA_TACP0_FEATURES"
    run "add rba role $RBA_ROLE_TACP15 domain-type System all-features"
    log_success "RBA roles configuration completed"
else
    log_info "RBA configuration skipped (disabled)"
fi

# Add TACACS+ server if enabled
start_section "TACACS Configuration"
if [ "$TACACS_ENABLED" = "true" ]; then
    log_info "Configuring TACACS+ server"
    run "add aaa tacacs-servers priority 1 server $TACACS_SERVER_IP key $TACACS_SECRET_KEY timeout $TACACS_TIMEOUT"
    run "set aaa tacacs-servers user-uid $TACACS_USER_UID"
    run "set aaa tacacs-servers state on"
    log_success "TACACS configuration completed"
else
    log_info "TACACS configuration skipped (disabled)"
fi

# Add local user if enabled
start_section "Local User Configuration"
if [ "$LOCAL_USER_ENABLED" = "true" ]; then
    log_info "Configuring local user"
    run "add user $LOCAL_USERNAME uid $LOCAL_USER_UID homedir $LOCAL_USER_HOMEDIR"
    run "set user $LOCAL_USERNAME gid $LOCAL_USER_GID shell $LOCAL_USER_SHELL"
    run "set user $LOCAL_USERNAME realname \"$LOCAL_USER_REALNAME\""
    run "set user $LOCAL_USERNAME password-hash $LOCAL_USER_PASSWORD_HASH"
    run "add rba user $LOCAL_USERNAME roles $LOCAL_USER_ROLE"
    log_success "Local user configuration completed"
else
    log_info "Local user configuration skipped (disabled)"
fi

# Configure SSH keys if enabled (using CLISH commands)
start_section "SSH Key Configuration"
if [ "$SSH_KEYS_ENABLED" = "true" ]; then
    log_info "Configuring SSH user and keys"
    # Create/configure the SSH user with all necessary parameters
    run "add user $SSH_USERNAME uid $SSH_USER_UID homedir $SSH_USER_HOMEDIR"
    run "set user $SSH_USERNAME gid $SSH_USER_GID shell $SSH_USER_SHELL"
    run "set user $SSH_USERNAME realname \"$SSH_USER_REALNAME\""
    run "set user $SSH_USERNAME password-hash $SSH_USER_PASSWORD_HASH"
    run "set user $SSH_USERNAME ssh-public-key \"$SSH_PUBLIC_KEY\""
    run "add rba user $SSH_USERNAME roles $SSH_USER_ROLE"
    log_success "SSH key configuration completed"
else
    log_info "SSH key configuration skipped (disabled)"
fi

# Configure syslog if enabled
start_section "Syslog Configuration"
if [ "$SYSLOG_ENABLED" = "true" ]; then
    log_info "Configuring syslog server"
    run "add syslog log-remote-address $SYSLOG_SERVER_IP level $SYSLOG_LEVEL"
    log_success "Syslog configuration completed"
else
    log_info "Syslog configuration skipped (disabled)"
fi

# Configure SNMP if enabled
start_section "SNMP Configuration"
if [ "$SNMP_ENABLED" = "true" ]; then
    log_info "Configuring SNMP"
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
    log_success "SNMP configuration completed"
else
    log_info "SNMP configuration skipped (disabled)"
fi

# Configure NTP and timezone if enabled
start_section "NTP and Timezone Configuration"
if [ "$NTP_ENABLED" = "true" ]; then
    log_info "Configuring NTP and timezone"
    run "set ntp active on"
    run "set ntp server primary $NTP_PRIMARY_SERVER version $NTP_VERSION"
    # Only set secondary NTP server if variable is defined and not empty
    if [ -n "$NTP_SECONDARY_SERVER" ]; then
        run "set ntp server secondary $NTP_SECONDARY_SERVER version $NTP_VERSION"
    fi
    run "set timezone $TIMEZONE"
    log_success "NTP & timezone configuration completed"
else
    log_info "NTP & timezone configuration skipped (disabled)"
fi

# Configure DNS if enabled
start_section "DNS Configuration"
if [ "$DNS_ENABLED" = "true" ]; then
    log_info "Configuring DNS settings"
    run "set dns primary $DNS_PRIMARY"
    # Only set secondary DNS if variable is defined and not empty
    if [ -n "$DNS_SECONDARY" ]; then
        run "set dns secondary $DNS_SECONDARY"
    fi
    # Only set DNS suffix if variable is defined and not empty
    if [ -n "$DNS_SUFFIX" ]; then
        run "set dns suffix $DNS_SUFFIX"
    fi
    # Only set domain name if variable is defined and not empty
    if [ -n "$DOMAIN_NAME" ]; then
        run "set domainname $DOMAIN_NAME"
    fi
    log_success "DNS configuration completed"
else
    log_info "DNS configuration skipped (disabled)"
fi

# Filesystem or other commands section
log_info "Additional filesystem or custom commands can be added here (placeholder)"

# Execute custom CLISH commands if enabled
start_section "Custom CLISH Commands"
if [ "$CUSTOM_CLISH_ENABLED" = "true" ]; then
    log_info "Executing custom CLISH commands"
    for cmd in "${CUSTOM_CLISH_COMMANDS[@]}"; do
        # Skip commented lines (starting with #) or empty lines
        if [[ ! "$cmd" =~ ^[[:space:]]*# ]] && [[ -n "$cmd" ]]; then
            echo "Running custom CLISH: $cmd"
            run "$cmd"
        fi
    done
    log_success "Custom CLISH commands completed"
else
    log_info "Custom CLISH commands skipped (disabled)"
fi

# Save configuration to make it persistent across reboots (after all commands)
start_section "Saving Configuration"
log_info "Saving configuration"
run "save config"

# Execute custom bash commands if enabled (runs outside of clish)
start_section "Custom Bash Commands"
if [ "$CUSTOM_BASH_ENABLED" = "true" ]; then
    echo "=========================================="
    echo "EXECUTING CUSTOM BASH COMMANDS (NON-CLISH)"
    echo "=========================================="
    echo "WARNING: These commands run in bash shell, NOT in clish!"
    echo "Do NOT include clish commands here - use CUSTOM_CLISH_COMMANDS instead."
    
    for cmd in "${CUSTOM_BASH_COMMANDS[@]}"; do
        # Skip commented lines (starting with #) or empty lines
        if [[ ! "$cmd" =~ ^[[:space:]]*# ]] && [[ -n "$cmd" ]]; then
            echo "Executing bash command: $cmd"
            # Execute directly in bash (not clish) with error handling
            if eval "$cmd"; then
                log_success "Bash OK: $cmd"
            else
                log_error "Bash FAILED: $cmd"
            fi
        fi
    done
    log_success "Custom bash commands completed"
    echo "=========================================="
fi

# Script finishes
echo "=========================================="
log_success "Configuration script completed"
echo "Completed: $(TS)"
echo "Log file: $LOGFILE"
echo "=========================================="
echo "CME_CMD_SUMMARY|total=$CMD_TOTAL|failed=$CMD_FAILED|success=$((CMD_TOTAL-CMD_FAILED))|$(TS)"
echo "===== SCRIPT_END $(TS) ====="

# Exit with success code (CME requires exit 0 even if reboot needed)
# Reboot gateway if configured
if [ "$REBOOT_REQUIRED" = "true" ]; then
    echo "=========================================="
    echo "REBOOT_REQUIRED is set to true"
    echo "Initiating gateway reboot in 1 minute..."
    echo "=========================================="
    shutdown -r +1 "CME configuration completed. Rebooting gateway as configured."
fi
exit $SUCCESS