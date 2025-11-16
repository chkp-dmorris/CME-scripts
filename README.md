# Check Point Gateway Configuration Script

A comprehensive bash script for automating Check Point Security Gateway configuration through CLISH (Check Point Command Line Interface) and custom bash commands.

## 🚀 Overview

This script automates the configuration of Check Point Security Gateways by:
- Setting security compliance configurations (banners, passwords, timeouts)
- Configuring network services (DNS, NTP, SNMP, Syslog)
- Managing user authentication (TACACS+, local users, SSH keys)
- Executing custom CLISH and bash commands
- Providing detailed logging and error handling

## ☁️ Check Point CME (Cloud Management Extension) Integration

This script is designed for use with **Check Point CME (Cloud Management Extension)** as a **Custom Gateway Script**. CME allows you to deploy and manage Check Point Security Gateways in cloud environments with automated configuration.

### CME Custom Gateway Script Usage

The script is executed automatically by CME after Security Gateway deployment and policy installation using the `-cg` (Custom Gateway Script) parameter.

#### CME Configuration Template Parameters

When deploying gateways through CME, use the following parameter to execute this script:

```bash
-cg '$FWDIR/conf/run-script-cg-configured.sh'
```

#### Supported CME Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| `-otp` | ONE_TIME_PASSWORD | Random string (min 8 alphanumeric characters) |
| `-ver` | GATEWAY_VERSION | Security Gateway version |
| `-po` | POLICY_NAME | Existing security policy to install |
| `-rp` | POLICY_NAME | Optional restrictive policy (first policy) |
| `-cg` | CUSTOM_GATEWAY_SCRIPT | **Path to this script for post-deployment configuration** |

#### CME Script Requirements

✅ **Location**: Script can be anywhere on Management Server (see suggested structure below)  
✅ **Permissions**: Script directory must have appropriate read permissions  
✅ **Execution**: Runs automatically after policy installation  
✅ **Parameters**: Can include additional parameters separated by spaces  

#### Suggested Folder Structure

For better organization and management, consider this folder structure on your Management Server:

```
/home/admin/
├── cme-scripts/
│   ├── gateway-configs/
│   │   ├── run-script-cg-configured.sh       # Main configuration script
│   │   └── versions/
│   │       ├── run-script-cg-configured-v1.0.sh
│   │       └── run-script-cg-configured-v1.1.sh
```

### CME Workflow Integration

1. **Gateway Deployment**: CME deploys Security Gateway in cloud
2. **Policy Installation**: Initial security policy is installed
3. **Custom Script Execution**: This script runs automatically
4. **Configuration Applied**: All defined configurations are applied
5. **Logging**: Detailed logs available in `/var/log/cme_custom_gateway_scripts.log`

### CME Benefits

- **Automated Deployment**: No manual configuration needed
- **Consistent Configuration**: Same settings applied to all gateways
- **Scalable**: Deploy multiple gateways with identical configurations
- **Cloud-Native**: Designed for cloud infrastructure automation
- **Policy Integration**: Works seamlessly with CME policy deployment

For detailed CME documentation, see: [Check Point CME Documentation](https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CME/Content/Topics-CME/CME_Structure_and_Configurations.htm)

## 📋 Prerequisites

- Check Point Security Gateway (R80.x or later)
- Expert mode access on the gateway
- Bash shell environment
- CLISH (Check Point Command Line Interface)
- Root or administrative privileges

## 🔧 Configuration

### Quick Start

1. **Place the script** on your Check Point Management Server
2. **Edit configuration variables** at the top of the script
3. **Enable desired features** by setting them to `"true"`
4. **Convert line endings** if edited on Windows: `dos2unix run-script-cg-configured.sh`
5. **Set secure permissions**: `chmod 644 run-script-cg-configured.sh` (read-only for group/others)
6. **Configure CME template** with the `-cg` parameter pointing to your script

### Configuration Sections

#### Banner Messages
```bash
BANNER_ENABLED="false"              # Enable/disable login banners
BANNER_LINE1="YOUR_BANNER_LINE_1"   # First line of banner
BANNER_LINE2="YOUR_BANNER_LINE_2"   # Second line of banner  
BANNER_LINE3="YOUR_BANNER_LINE_3"   # Third line of banner
```

#### Expert Password & Session
```bash
EXPERT_PASSWORD_HASH='YOUR_EXPERT_PASSWORD_HASH_HERE'  # Password hash
INACTIVITY_TIMEOUT="720"                               # Session timeout (minutes)
```

#### Network Services
```bash
# DNS Settings
DNS_ENABLED="false"
DNS_PRIMARY="YOUR_PRIMARY_DNS"
DNS_SECONDARY="YOUR_SECONDARY_DNS"

# NTP Settings  
NTP_ENABLED="false"
NTP_PRIMARY_SERVER="YOUR_PRIMARY_NTP_SERVER"
NTP_SECONDARY_SERVER="YOUR_SECONDARY_NTP_SERVER"

# SNMP Settings
SNMP_ENABLED="false"
SNMP_CONTACT="YOUR_EMAIL@COMPANY.COM"
SNMP_TRAP_RECEIVER_IP="YOUR_SNMP_SERVER_IP"

# Syslog Settings
SYSLOG_ENABLED="false"
SYSLOG_SERVER_IP="YOUR_SYSLOG_SERVER_IP"
```

#### Authentication
```bash
# TACACS+ Server
TACACS_ENABLED="false"
TACACS_SERVER_IP="YOUR_TACACS_SERVER_IP"
TACACS_SECRET_KEY="YOUR_SECRET_KEY"

# Local Users
LOCAL_USER_ENABLED="false"
LOCAL_USERNAME="YOUR_USERNAME"

# SSH Keys
SSH_KEYS_ENABLED="false"
SSH_USERNAME="YOUR_SSH_USERNAME"
SSH_PUBLIC_KEY="YOUR_SSH_PUBLIC_KEY_HERE"
```

#### Custom Commands
```bash
# Custom CLISH Commands
CUSTOM_CLISH_ENABLED="true"
CUSTOM_CLISH_COMMANDS=(
    "add static-route 192.168.100.0/24 nexthop gateway address 10.0.1.1 on"
    "set interface eth1 mtu 9000"
)

# Custom Bash Commands  
CUSTOM_BASH_ENABLED="true"
CUSTOM_BASH_COMMANDS=(
    "echo 'Gateway configured' >> /var/log/deployment.log"
    "mkdir -p /var/log/custom"
)
```

## 📝 Usage

### Primary Usage (CME Automated Deployment)

This script is designed to run automatically through CME. Simply:

1. **Place script** on Management Server in your chosen directory structure
2. **Configure CME template** with the `-cg` parameter pointing to your script
3. **Deploy gateways** - the script runs automatically after policy installation

### Testing Before Deployment

To test the script manually before using it in CME deployments:

1. **Upload script** to a test gateway:
```bash
scp run-script-cg-configured.sh admin@test-gateway:/tmp/
```

2. **Connect to gateway** and enter expert mode:
```bash
ssh admin@test-gateway
expert
```

3. **Make script executable**:
```bash
chmod +x /tmp/run-script-cg-configured.sh
```

4. **Run the script**:
```bash
./run-script-cg-configured.sh
```


#### Selective Configuration
Enable only specific features by setting their `*_ENABLED` variables to `"true"`:
```bash
DNS_ENABLED="true"     # Enable DNS configuration
NTP_ENABLED="true"     # Enable NTP configuration  
SYSLOG_ENABLED="false" # Skip syslog configuration
```

#### Custom Commands Only
To run only custom commands, disable all other features:
```bash
BANNER_ENABLED="false"
DNS_ENABLED="false"
# ... disable other features
CUSTOM_CLISH_ENABLED="true"
CUSTOM_BASH_ENABLED="true"
```

## 📊 Logging

The script provides comprehensive logging:

- **Log File**: `/var/log/cme_custom_gateway_scripts.log`
- **Console Output**: Real-time execution status
- **Success/Failure**: Clear indicators for each command
- **Timestamps**: All operations are timestamped

### Sample Log Output
```
==========================================
Check Point Gateway Configuration Script
Started: Fri Oct 24 15:05:19 EDT 2025
==========================================
Skipping banner configuration (disabled)...
Configuring expert password and session timeout...
Skipping expert password configuration (not defined)...
Skipping inactivity timeout configuration (not defined)...
Executing custom CLISH commands...
Running custom CLISH: add static-route 192.168.100.0/24 nexthop gateway address 10.0.1.1 on
Executing: add static-route 192.168.100.0/24 nexthop gateway address 10.0.1.1 on
SUCCESS: add static-route 192.168.100.0/24 nexthop gateway address 10.0.1.1 on
Saving configuration...
Executing: save config
SUCCESS: save config
Custom CLISH commands completed.
==========================================
Configuration script completed successfully.
Completed: Fri Oct 24 15:05:45 EDT 2025
Log file: /var/log/cme_custom_gateway_scripts.log
==========================================
```

## ⚠️ Important Notes

### Security Considerations
- **Review all configurations** before running in production
- **Test in lab environment** first
- **Use strong passwords and keys**
- **Limit script access** to authorized personnel

### CLISH Syntax
- Commands must use proper Check Point CLISH syntax
- Different Check Point versions may have syntax variations
- Test individual commands first if unsure


## 🔍 Troubleshooting

### Common Issues

#### CLISH Syntax Errors
```
CLINFR0329 Invalid command: 'your command'
```
**Solution**: Verify CLISH syntax for your Check Point version

#### Incomplete Commands
```
CLINFR0349 Incomplete command.
```
**Solution**: Check that all required parameters are provided

#### Permission Errors
```
ERROR: Command failed: set expert-password-hash
```
**Solution**: Ensure you're running in expert mode with proper privileges

#### Banner Message Issues
```
CLINFR0409 Invalid value 'false'. Correct value(s) - on,off
```
**Solution**: Use "on"/"off" for CLISH commands, "true"/"false" for script logic

### Validation

Test individual CLISH commands manually before running the full configuration script to ensure proper syntax for your Check Point version.

## 📚 Examples

### Example 1: Basic Network Configuration
```bash
# Enable basic network services
DNS_ENABLED="true"
DNS_PRIMARY="8.8.8.8"
DNS_SECONDARY="8.8.4.4"
DNS_SUFFIX="company.local"

NTP_ENABLED="true"
NTP_PRIMARY_SERVER="pool.ntp.org"
NTP_SECONDARY_SERVER="time.nist.gov"
TIMEZONE="America/New_York"
```

### Example 2: Security Hardening
```bash
# Enable security features
BANNER_ENABLED="true"
BANNER_LINE1="AUTHORIZED ACCESS ONLY"
BANNER_LINE2="All activity is monitored and logged"
BANNER_LINE3="Unauthorized access is prohibited"

EXPERT_PASSWORD_HASH='$6$rounds=5000$salt$hash...'
INACTIVITY_TIMEOUT="120"  # 2 hours
```

### Example 3: Custom Routes
```bash
CUSTOM_CLISH_ENABLED="true"
CUSTOM_CLISH_COMMANDS=(
    "add static-route 10.0.0.0/8 nexthop gateway address 192.168.1.1 on"
    "add static-route 172.16.0.0/12 nexthop gateway address 192.168.1.1 on"
    "set interface eth1 state on"
)
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test thoroughly in lab environment
4. Submit pull request with detailed description

## 📄 License

This script is provided as-is for educational and operational purposes. Use at your own risk and ensure compliance with your organization's security policies.

## 📞 Support

- Review Check Point documentation for CLISH command syntax
- Test in lab environment before production use
- Validate configurations match your security requirements

---

**Version**: 1.0  
**Last Updated**: October 2025  
**Compatibility**: Check Point R80.x and later