#!/bin/bash
# Clone repository
git clone --branch v8.0.3.0 https://github.com/vmware/vsphere-automation-sdk-python.git /tmp/vasp
# Install dependencies from whl files
mkdir -p /usr/local/lib/python3.12/vsphere-automation-sdk-python
echo "Installing nsx-python-sdk..."
cp /tmp/vasp/lib/nsx-python-sdk/nsx_python_sdk-4.2.0-py2.py3-none-any.whl \
    /usr/local/lib/python3.12/vsphere-automation-sdk-python/
pip3.12 install --upgrade /usr/local/lib/python3.12/vsphere-automation-sdk-python/nsx_python_sdk-4.2.0-py2.py3-none-any.whl
echo "Installing nsx-policy-python-sdk..."
cp /tmp/vasp/lib/nsx-policy-python-sdk/nsx_policy_python_sdk-4.2.0-py2.py3-none-any.whl \
    /usr/local/lib/python3.12/vsphere-automation-sdk-python/
pip3.12 install --upgrade /usr/local/lib/python3.12/vsphere-automation-sdk-python/nsx_policy_python_sdk-4.2.0-py2.py3-none-any.whl
echo "Installing nsx-vmc-policy-python-sdk..."
cp /tmp/vasp/lib/nsx-vmc-policy-python-sdk/nsx_vmc_policy_python_sdk-4.1.2.0.1-py2.py3-none-any.whl \
    /usr/local/lib/python3.12/vsphere-automation-sdk-python/
pip3.12 install --upgrade /usr/local/lib/python3.12/vsphere-automation-sdk-python/nsx_vmc_policy_python_sdk-4.1.2.0.1-py2.py3-none-any.whl
echo "Installing nsx-vmc-aws-integration-python-sdk..."
cp /tmp/vasp/lib/nsx-vmc-aws-integration-python-sdk/nsx_vmc_aws_integration_python_sdk-4.1.2.0.1-py2.py3-none-any.whl \
    /usr/local/lib/python3.12/vsphere-automation-sdk-python/
pip3.12 install --upgrade /usr/local/lib/python3.12/vsphere-automation-sdk-python/nsx_vmc_aws_integration_python_sdk-4.1.2.0.1-py2.py3-none-any.whl
echo "Installing vmwarecloud-aws/..."
cp /tmp/vasp/lib/vmwarecloud-aws/vmwarecloud_aws-1.64.1-py2.py3-none-any.whl \
    /usr/local/lib/python3.12/vsphere-automation-sdk-python/
pip3.12 install --upgrade /usr/local/lib/python3.12/vsphere-automation-sdk-python/vmwarecloud_aws-1.64.1-py2.py3-none-any.whl
echo "Installing vmwarecloud-draas..."
cp /tmp/vasp/lib/vmwarecloud-draas/vmwarecloud_draas-1.23.1-py2.py3-none-any.whl \
    /usr/local/lib/python3.12/vsphere-automation-sdk-python/
pip3.12 install --upgrade /usr/local/lib/python3.12/vsphere-automation-sdk-python/vmwarecloud_draas-1.23.1-py2.py3-none-any.whl
# Install vsphere-automation-sdk
echo "Installing vsphere-automation-sdk"
pip3.12 install --upgrade /tmp/vasp
# Cleanup
echo "Cleaning up ..."
rm -rf /tmp/vasp
echo "Vsphere automation sdk install complete."
