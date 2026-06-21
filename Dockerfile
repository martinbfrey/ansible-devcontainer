FROM oraclelinux:9

COPY kubernetes.repo /etc/yum.repos.d/kubernetes.repo

# hadolint ignore=DL3041
RUN dnf install -y oracle-epel-release-el9 \
    && rpm -ihv https://packages.microsoft.com/config/rhel/9/packages-microsoft-prod.rpm \
    && yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo \
    && dnf update --refresh -y \
    && dnf install -y \
    bash-completion sudo httpd-tools jq bind-utils \
    gcc-c++ autoconf automake libtool cmake git \
    dateutils unzip jq sshpass \
    python3.12 python3.12-pip python3.12-devel \
    # vSphere
    python3.12-lxml python3.12-cryptography python3.12-charset-normalizer \
    python3.12-idna python3.12-cffi python3.12-pycparser python3.12-ply \
    # Ansible
    python3.12-requests python3.12-pyyaml \
    # Kubernetes
    python3.12-setuptools python3.12-urllib3 \
    kubectl skopeo \
    # Kerberos for WinRM
    krb5-devel python3-libselinux krb5-workstation cyrus-sasl-gssapi \
    # Wireguard
    wireguard-tools \
    # Powershell LTS
    powershell-lts \
    # Required for community.general.java_keystore
    java-25-openjdk \
    # Hashicorp packer
    packer \
    && dnf clean all && rm -rf /var/cache/dnf

ARG PYTHONUNBUFFERED=1
ARG PIP_NO_CACHE_DIR=1
RUN pip3.12 install --no-cache-dir \
    xmltodict==1.0.4 pywinrm==0.5.0 netaddr==1.3.0 jmespath==1.1.0 ldap3==2.9.1 \
    kerberos==1.3.1 passlib==1.7.4 six==1.17.0 \
    # VSphere SDK. Versions must match vsphere-automation-sdk-python version (8.0.3)
    pyvmomi==8.0.3.0.1 aiohttp==3.14.1 vmware-vcenter==8.0.3.0 vmware-vapi-runtime==2.52.0 vmware-vapi-common-client==2.52.0 \
    # Ansible
    paramiko==5.0.0 jinja2==3.1.6 pyvim==3.0.3 zabbix-api==0.5.6 units==0.07 \
    rich==15.0.0 textfsm==2.1.0 pysnmp==7.1.27 pysnmp-mibs==0.1.6 librouteros==4.1.1 \
    kubernetes==36.0.2 openshift==0.13.2 omsdk==1.2.518 \
    ansible==13.8.0 \
    ansible-pylibssh==1.4.0 pyOpenSSL==26.3.0 \
    ansible-lint==26.4.0

# vSphere SDK
COPY vsphere_install.sh /vsphere_install.sh
RUN chmod +x /vsphere_install.sh && /vsphere_install.sh && rm /vsphere_install.sh

# Install helm
ARG HELM_VERSION=v3.21.2
RUN curl -L https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz -o helm-linux-amd64.tar.gz \
    && tar -xzvf helm-linux-amd64.tar.gz --strip-components=1 -C /usr/bin linux-amd64/helm \
    && rm -f helm-linux-amd64.tar.gz
RUN helm plugin install https://github.com/databus23/helm-diff --version 3.15.10

# Setup ansible user
RUN groupadd --gid 1000 ansible \
    && useradd -s /bin/bash --uid 1000 --gid 1000 -m ansible \
    && echo "ansible ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/ansible \
    && chmod 0440 /etc/sudoers.d/ansible

# Create directory to store powershell package configuration and VCF configuration
RUN mkdir -p /root/.config/NuGet \
    && mkdir -p /home/ansible/.config/NuGet \
    && chown -R 1000.1000 /home/ansible/.config \
    && mkdir -p /var/opt/VMware/PowerCLI
# Always trust PS Gallery when running as root
COPY nuget.config /root/.config/NuGet/nuget.config
# Always trust PS Gallery when running as ansible
COPY --chown=1000:1000 nuget.config /home/ansible/.config/NuGet/nuget.config

# Install VMware PowerCLI
RUN pwsh -NoLogo -NonInteractive -Command Install-Module -Scope AllUsers -Force -AcceptLicense VCF.PowerCLI -RequiredVersion 9.1.0.25380678
# Copy config declining VMware Customer Experience Program
COPY PowerCLI_Settings.xml /var/opt/VMware/PowerCLI/PowerCLI_Settings.xml

# Install hadolint to check dockerfile
RUN curl -L https://github.com/hadolint/hadolint/releases/download/v2.14.0/hadolint-linux-x86_64 -o /usr/local/bin/hadolint \
    && chmod 0755 /usr/local/bin/hadolint

RUN /usr/local/bin/ansible-galaxy collection install dellemc.os9:==1.0.4 \
        -p /usr/local/lib/python3.11/site-packages/ansible_collections \
    && /usr/local/bin/ansible-galaxy collection install dellemc.os10:==1.2.7 \
        -p /usr/local/lib/python3.11/site-packages/ansible_collections

# Install idrac tools
COPY idrac_install.sh /idrac_install.sh
RUN chmod +x /idrac_install.sh \
    && /idrac_install.sh \
    && rm /idrac_install.sh

# Patch dellemc openmanage collection and omsdk to support TLS1.3
COPY dellemc-openmanage-idrac_services.py /usr/local/lib/python3.11/site-packages/ansible_collections/dellemc/openmanage/plugins/modules/dellemc_configure_idrac_services.py
COPY omsdk-iDRAC.json /usr/local/lib/python3.11/site-packages/omdrivers/iDRAC/Config/iDRAC.json
COPY omsdk-iDRACConfig.py /usr/local/lib/python3.11/site-packages/omdrivers/lifecycle/iDRAC/iDRACConfig.py
COPY omsdk-iDRAC.py /usr/local/lib/python3.11/site-packages/omdrivers/enums/iDRAC/iDRAC.py
COPY omsdk-iDRACEnums.py /usr/local/lib/python3.11/site-packages/omdrivers/enums/iDRAC/iDRACEnums.py

# Install xmlrpc module
ARG XMLRPC_VERSION=52b58aba29f41754dd57faaf17f9092ea278b535
RUN mkdir -p /usr/share/ansible/plugins/modules && \
    curl -L -o /usr/share/ansible/plugins/modules/xmlrpc_client.py \
    https://gitlab.com/stemid/ansible-xmlrpc-client-module/-/raw/${XMLRPC_VERSION}/xmlrpc_client.py
