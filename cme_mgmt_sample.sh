#!/bin/bash
###############################################################
# NOTE:
# This script is intended for use with Check Point CME automation.
# CME passes the gateway name as the first argument ($1) to this script.
# You do NOT need to manually set the gateway name when run by CME.
###############################################################
GATEWAY_NAME="${1:-MyGateway}"

# =============================================================================
# Check Point Gateway mgmt_cli Script - Configured Version
# =============================================================================

# === USER CONFIGURATION SECTION ===
# For full mgmt_cli command reference, see:
# https://sc1.checkpoint.com/documents/latest/APIs/
# Edit the variables and command arrays below to customize the script for your needs.
#
# EXAMPLES:
#   - To set gateway color:      MGMT_CLI_COMMAND=(set simple-gateway name "$GATEWAY_NAME" color blue)
#   - To show gateway object:    MGMT_CLI_COMMAND=(show simple-gateway name "$GATEWAY_NAME")
#   - To delete gateway object:  MGMT_CLI_COMMAND=(delete simple-gateway name "$GATEWAY_NAME")
#   - To set comments:           MGMT_CLI_COMMAND=(set simple-gateway name "$GATEWAY_NAME" comments "Set by script")
#
# Set the gateway name and command here, or pass them as arguments.
# -----------------------------------------------------------------------------
# CUSTOMIZE YOUR COMMAND BELOW
# Place your custom mgmt_cli command in the MGMT_CLI_COMMAND array.
# Example:
# MGMT_CLI_COMMAND=(set simple-gateway name "$GATEWAY_NAME" color blue)
# -----------------------------------------------------------------------------

# Example command to set gateway color to blue
MGMT_CLI_COMMAND=(set simple-gateway name "$GATEWAY_NAME" color blue)

# =============================================================================
# SCRIPT EXECUTION BEGINS HERE
# =============================================================================

# Setup logging
LOGFILE="/var/log/cme_mgmt_config.elg"
exec > >(tee -a "$LOGFILE") 2>&1

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

run_mgmt_cli() {
  log "Running mgmt_cli: ${MGMT_CLI_COMMAND[*]} --format json -r true"
  mgmt_cli "${MGMT_CLI_COMMAND[@]}" --format json -r true
  RETVAL=$?
  if [ $RETVAL -eq 0 ]; then
    log "mgmt_cli command succeeded."
  else
    log "ERROR: mgmt_cli command failed."
  fi
  return $RETVAL
}

log "=========================================="
log "Check Point Gateway mgmt_cli Script"
log "Started: $(date)"
log "=========================================="

if [ -z "$GATEWAY_NAME" ] || [ -z "${MGMT_CLI_COMMAND[*]}" ]; then
  log "ERROR: Usage: $0 <gateway_name> <mgmt_cli_args...>"
  log "Example: $0 MyGateway set simple-gateway name MyGateway color blue"
  exit 1
fi

run_mgmt_cli
RETVAL=$?

if [ $RETVAL -eq 0 ]; then
  log "Publishing changes..."
  mgmt_cli publish --format json -r true | tee -a "$LOGFILE"
fi

log "Script completed."
log "=========================================="
exit $RETVAL
