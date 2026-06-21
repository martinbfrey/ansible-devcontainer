#!/bin/bash

set -e

IDRAC_TOOLS_URL="https://dl.dell.com/FOLDER14347901M/1/Dell-iDRACTools-Web-LX-11.4.1.0-1685_A00.tar.gz"
INSTALL_SCRIPT_PATH="/tmp/idrac/iDRACTools/racadm/install_racadm.sh"

# Download Dell iDRAC Tools
echo "Downloading Dell iDRAC Tools..."
curl -L -o /tmp/idrac_lx.tgz -A "Mozilla/5.0" "$IDRAC_TOOLS_URL"
echo "Extracting tools..."
mkdir -p /tmp/idrac
tar xzf /tmp/idrac_lx.tgz -C /tmp/idrac

# Patch for Oracle Linux
echo "Patching for Oracle Linux..."
sed -i 's/centos/ol/g' /tmp/idrac/iDRACTools/racadm/install_racadm.sh

# Install Dell iDRAC Tools
echo "Installing iDRAC Tools..."
cd /tmp/idrac/iDRACTools/racadm/
./install_racadm.sh

# Clean up temporary files
echo "Cleaning up..."
rm -rf /tmp/idrac /tmp/idrac_lx.tgz

echo "Idrac tools install complete."
