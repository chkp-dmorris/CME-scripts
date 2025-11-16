#!/bin/bash

#Gateway Helper Script for CME Automation

LOG="/var/log/cme_helper.log"

echo "[${0} $(date +"%T")] CME Gateway Helper" >> $LOG

if test -f "/opt/cme_gw_helper"; then
    echo "[${0} $(date +"%T")] - Nothing to do, exiting" >> $LOG
    break

else
    echo "[${0} $(date +"%T")] - Rebooting the gateway and setting pointer" >> $LOG
    touch /opt/cme_gw_helper
    sleep 10
    reboot
fi