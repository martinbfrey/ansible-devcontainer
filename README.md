# Ansible dev-container

This projects provides a [dev-container](https://containers.dev/) for [Visual Studio Code](https://code.visualstudio.com/) running Ansible inside the container. It is based on [Oracle Linux 9](https://docs.oracle.com/en/operating-systems/oracle-linux/9/).

## Dev Container setup

Example:

```JSON
{
    "name": "ansible",
    "image": "ghcr.io/martinbfrey/ansible-devcontainer:main",
    "customizations": {
        "vscode": {
            "extensions": [
                "redhat.ansible",
                "ms-python.python",
                "mhutchie.git-graph",
                "samuelcolvin.jinjahtml",
                "redhat.vscode-yaml",
                "donjayamanne.githistory",
                "ms-vscode.PowerShell",
                "streetsidesoftware.code-spell-checker",
                "davidanson.vscode-markdownlint",
                "ms-kubernetes-tools.vscode-kubernetes-tools",
                "ISPAPP.mikrotik-routeros-script-tools",
                "redhat.vscode-xml"
            ]
        }
    },
    "containerUser": "ansible",
    "updateRemoteUserUID": false,
	"runArgs": [
        "--userns=keep-id:uid=1000,gid=1000",
        "--cap-add=CAP_NET_RAW",
        "--network=slirp4netns:cidr=172.28.0.0/24"
	],
    "containerEnv": {
        "DEV_CONTAINER": "true",
        "DEPLOY_HOST": "${localEnv:HOSTNAME}"
    },
    "workspaceFolder": "/workspace",
    "workspaceMount": "source=${localWorkspaceFolder}/..,target=/workspace,type=bind,consistency=cached"
}
```
