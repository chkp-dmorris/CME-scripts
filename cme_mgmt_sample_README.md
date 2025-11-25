## CME Template Parameter: -cp

To use a Custom Management script with CME, specify the `-cp` parameter in your template or automation.

**Syntax:**
```
-cp '$FWDIR/conf/mgmt-script.sh param1 param2 ...'
```

- Use single quotes around the command and parameters.
- Replace `mgmt-script.sh` with your script name (e.g., `cme_mgmt_sample.sh`).
- You can pass additional parameters as needed.

**Example:**
```
-cp '$FWDIR/conf/cme_mgmt_sample.sh param1 param2'
```

For more details about the Custom Management Script and its parameters, see the official documentation section: **Management Parameters**.
# CME Gateway Management Sample Script

This README provides instructions and context for the `cme_mgmt_sample.sh` script, designed for use with Check Point Cloud Management Extension (CME) automation workflows.

## Further Documentation

- Official CME Admin Guide: [Check Point CME Documentation](https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CME/Content/Topics-CME/CME_Structure_and_Configurations.htm)

## Usage Steps

1. Edit the script to customize the `MGMT_CLI_COMMAND` array for your desired mgmt_cli operation. 
2. Place `cme_mgmt_sample.sh` on your Check Point Management Server.
3. Ensure Unix line endings (especially if edited on Windows):
	```bash
	dos2unix cme_mgmt_sample.sh
	```
4. Make the script executable:
	```bash
	chmod +x cme_mgmt_sample.sh
	```
5. Configure CME to use the script with the `-cg` parameter in your template or automation:
	```bash
	-cg '$FWDIR/conf/cme_mgmt_sample.sh'
	```
6. CME will automatically execute the script on the gateway after deployment and initial policy installation.

**Note:** The gateway name is passed by CME as the first argument to the script (`$1`).

## Logging

All output is logged to `/var/log/cme_mgmt_config.elg` on the Managment Server.

## Example Folder Structure

```
/home/admin/cme-scripts/
├── cme_mgmt_sample.sh
└── versions/
	 ├── cme_mgmt_sample-v1.0.sh
	 └── cme_mgmt_sample-v1.1.sh
```

## Purpose

This script automates management tasks for Check Point gateways using the `mgmt_cli` tool. It is intended to be executed by CME, which passes the gateway name as the first argument.

## Usage

```
./cme_mgmt_sample.sh <gateway_name>
```
- `<gateway_name>`: The name of the gateway object to manage. CME will automatically provide this argument when running the script.

## Customization

- Edit the `MGMT_CLI_COMMAND` array in the script to specify the desired `mgmt_cli` operation (e.g., set color, add comments, delete gateway, etc.).
- All output is logged to `/var/log/cme_mgmt_config.elg` for troubleshooting and auditing.

## Example Command

The default command in the script sets the gateway color to blue:
```
MGMT_CLI_COMMAND=(set simple-gateway name "$GATEWAY_NAME" color blue)
```
You can change this to any valid `mgmt_cli` command.

## Logging

- All script output is logged to `/var/log/cme_mgmt_config.elg`.
- The script logs start, command execution, publish, and completion events.

## Publishing Changes

After a successful `mgmt_cli` operation, the script automatically publishes changes using:
```
mgmt_cli publish --format json -r true
```

## mgmt_cli Command Reference

For a full list of available `mgmt_cli` commands and syntax, see the official Check Point API documentation:
- https://sc1.checkpoint.com/documents/latest/APIs/

## Troubleshooting

- Ensure the script has execute permissions: `chmod +x cme_mgmt_sample.sh`
- Check the log file for errors: `/var/log/cme_mgmt_config.elg`
- Verify that CME is passing the correct gateway name as the first argument.

## License

This script is provided as a template for Check Point CME automation. Modify and use as needed for your environment.
