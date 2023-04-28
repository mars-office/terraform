#!/bin/bash
echo "Start Ubuntu provisioning of k3s..."

# Disable firewall
/usr/sbin/netfilter-persistent stop
/usr/sbin/netfilter-persistent flush

systemctl stop netfilter-persistent.service
systemctl disable netfilter-persistent.service
# END Disable firewall



echo "Success."
