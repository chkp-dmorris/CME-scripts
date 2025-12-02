#!/bin/bash
# gateway_bash.sh - Simple script for Check Point Gateways

# Exit codes for CME
SUCCESS=0
FAILURE=1

# REBOOT CONFIGURATION (set to "true" if gateway needs reboot after changes)
REBOOT_REQUIRED="false"

LOGFILE="/var/log/cme_gateway_scripts.elg"
exec >> "$LOGFILE" 2>&1

# Error trap to catch failures
trap 'echo "ERROR: Script failed at line $LINENO - Command: $BASH_COMMAND"; exit $FAILURE' ERR
set -e

echo "Gateway Bash Script Running..."

source /etc/profile.d/CP.sh

echo "Gateway Bash Script Running..."

# ===============================
# SECTION: CLISH COMMANDS (Check Point)
# ===============================
# Place your clish commands below using clish -c, e.g.:
# clish -c "set static-route 10.10.10.0/24 nexthop gateway address 172.17.1.1 on"
#
# IMPORTANT: To save configuration changes, add this line after your clish commands:
#clish -c "save config"

# ===============================
# SECTION: BASH COMMANDS (Linux/Unix)
# ===============================
# Place your regular bash commands below, e.g.:
# echo "Hello from bash!" > /var/admin/bash_hello.txt
# uname -a >> /var/admin/system_info.txt
# fw stat >> /var/admin/fw_stat.txt

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
