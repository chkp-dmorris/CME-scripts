# Script Comparison: Simple vs. Advanced

**cme_gateway_simple.sh**
- Minimal, easy-to-edit script
- For basic gateway setup and simple CLISH/bash commands
- No advanced logic or feature toggles
- Best for quick, custom, or one-off configurations

**cme_gateways_advance.sh**
- Full-featured, highly configurable script
- Supports advanced gateway automation (banners, users, NTP, DNS, SNMP, etc.)
- Uses variables and feature toggles for modular configuration
- Best for production, repeatable, or complex deployments
## CME Integration Details (from Admin Guide)

### What is CME?
Check Point Cloud Management Extension (CME) is a tool for automating the deployment and configuration of Check Point Security Gateways in cloud environments (AWS, Azure, GCP, etc.).

### How CME Uses Custom Scripts
- CME can run a custom shell script on each gateway after deployment and initial policy installation.
- The script is specified in the CME template using the `-cg` parameter.
- The script can be placed anywhere on the management server, but must be accessible and executable by the CME process.
- The script runs as root on the gateway.

### Example CME Template Parameters
```
-otp 'MyOneTimePassword123' \
-ver R81.20 \
-po StandardPolicy \
-cg '$FWDIR/conf/cme_gateways_advance.sh'
```


### Script Placement and Permissions
- Place your script in a directory readable by the admin user (e.g., `/home/admin/cme-scripts/`).
- Ensure the script has Unix line endings (run `dos2unix` if edited on Windows):
   ```bash
   dos2unix cme_gateway_simple.sh
   dos2unix cme_gateways_advance.sh
   ```
- Set permissions:
   ```bash
   chmod 755 cme_gateway_simple.sh
   chmod 755 cme_gateways_advance.sh
   ```

### When Does CME Run the Script?
- After the gateway is deployed and the initial policy is installed.
- The script runs only once per deployment.

### Troubleshooting CME Script Execution
- Check `/var/log/cme_gateway_scripts.elg` on the gateway for script output and errors.
- Ensure the script is executable and has the correct shebang (`#!/bin/bash`).
- If the script fails, check for syntax errors or missing permissions.
- For more details, see the official CME Admin Guide: [Check Point CME Documentation](https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CME/Content/Topics-CME/CME_Structure_and_Configurations.htm)

### Troubleshooting on Smart Center

- For deeper troubleshooting of CME operations on the management server (Smart Center), check the log file:
   ```
   /var/log/CPcme/cme.elg
   ```
- You can monitor this log in real time while scaling out gateways with:
   ```bash
   tail -f /var/log/CPcme/cme.elg
   ```
- This log provides detailed information about CME actions, errors, and script execution status on the management server.
## How to Run


### Manual Execution

> **Note:** These scripts are designed to be executed automatically by CME on the gateway after deployment and initial policy installation. Manual execution on the SmartCenter (management server) is not supported or recommended. If you need to test or run the script manually, do so only on a test gateway, not on the management server.

### With CME (Cloud Management Extension)

1. Upload the script to your management server (e.g., `/home/admin/cme-scripts/`).
2. Configure your CME template to use the script with the `-cg` parameter:
   ```bash
   -cg '$FWDIR/conf/cme_gateways_advance.sh'
   ```
3. CME will automatically execute the script on the gateway after deployment and initial policy installation. You do not need to run the script manually.

# CME Gateway Scripts

This repository contains two scripts for automating Check Point Security Gateway configuration:

- `cme_gateway_simple.sh`: Minimal, easy-to-edit script for basic gateway setup (CLISH and bash commands)
- `cme_gateways_advance.sh`: Advanced, feature-rich script for full gateway automation

## Usage


1. Place the desired script on your Check Point Management Server or Gateway.
2. Edit the script to add your configuration commands.
3. Ensure Unix line endings (especially if edited on Windows):
   ```bash
   dos2unix cme_gateway_simple.sh
   dos2unix cme_gateways_advance.sh
   ```
4. Make the script executable:
   ```bash
   chmod +x cme_gateway_simple.sh
   chmod +x cme_gateways_advance.sh
   ```
5. Run manually or configure CME to use the script with the `-cg` parameter:
   ```bash
   -cg '$FWDIR/conf/cme_gateways_advance.sh'
   ```

## Logging

All output is logged to `/var/log/cme_gateway_scripts.elg` on the gateway.

## Example Folder Structure

```
/home/admin/cme-scripts/
├── cme_gateway_simple.sh
├── cme_gateways_advance.sh
└── versions/
    ├── cme_gateways_advance-v1.0.sh
    └── cme_gateways_advance-v1.1.sh
```

## Example: Add a Static Route (Simple Script)

In `cme_gateway_simple.sh`:

```bash
# CLISH section
clish -c "set static-route 10.10.10.0/24 nexthop gateway address 192.168.1.1 on"
clish -c "save config"

# Bash section
echo "Custom bash command here"
```

---

For advanced configuration, see comments and sections in `cme_gateways_advance.sh`.