
LOGFILE="/var/log/cme_gateway_scripts.elg"
exec >> "$LOGFILE" 2>&1
echo "Gateway Bash Script Running..."

#!/bin/bash
# gateway_bash.sh - Simple script for Check Point Gateways

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

