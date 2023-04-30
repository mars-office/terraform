#!/bin/bash
echo "Start Ubuntu provisioning of k3s..."

export MASTER="${master}"
export PRIMARY="${primary}"
export TOKEN="${k3s_token}"
export SERVER="${k3s_url}"
export PUBLICIP=$(curl -s ifconfig.co)
export CLUSTERDNS="${cluster_dns}"

# Disable firewall
/usr/sbin/netfilter-persistent stop
/usr/sbin/netfilter-persistent flush

systemctl stop netfilter-persistent.service
systemctl disable netfilter-persistent.service
# END Disable firewall

# iSCSI for Longhorn
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y  open-iscsi curl util-linux
systemctl enable --now iscsid.service


# K3S config
export K3S_TOKEN=$TOKEN
if [ "$MASTER" = "true" ]; then
    # master
    if [ "$PRIMARY" = "true" ]; then
        # primary
        export INSTALL_K3S_EXEC="server --disable traefik --tls-san $PUBLICIP --tls-san $CLUSTERDNS --cluster-init"
    else
        # secondary
        export K3S_URL=$SERVER
        export INSTALL_K3S_EXEC="server --tls-san $PUBLICIP --tls-san $CLUSTERDNS --disable traefik"
    fi
else
    # worker
    export K3S_URL=$SERVER
fi

curl -sfL https://get.k3s.io | sh -

systemctl enable k3s

echo "Success."
