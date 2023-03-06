# Containerized Ansible: What's inside #

This container provides the ansible toolstack inside a container.
* '''Dockerfile''' with the definition of the ansible container
  * based on OpenSUSE Tumbleweed
  * installs ansible and some additional tools
## System Setup ##
* Podman and python3-rpm are needed on the container host. The run label commands are hard coded to use podman and python3-rpm is required on the container host for ansible to gather package facts. Kernel-default-base does not contain the needed drivers for many Network Manager (nmcli) operations such as creating bonded interfaces and should be replaced with kernel-default.
  * sudo transactional-update pkg install python3-rpm kernel-default -kernel-default-base
  * system reboot is required after all transactional updates
    * sudo shutdown -r now

## Ansible commands
The ansible commands are provided as symlinks to ansible-wrapper.sh.
The commands will instantiate the container and execute the ansible
command.

## To install ansible commands ##

* as root:
  * for the root user the ansible commands are placed in /usr/local/bin
  * podman container runlabel install ansible
* as non-root
  * For non-root users 'podman container runlabel user-install ansible' will place the ansible commands in ${PWD}/bin. The following will install the ansible commands into the current user's bin area (~/bin).
  * (cd ~; podman container runlabel user-install ansible)

## Ansible Commands ##
* ansible
* ansible-community
* ansible-config
* ansible-connection
* ansible-console
* ansible-doc
* ansible-galaxy
* ansible-inventory
* ansible-lint
* ansible-playbook
* ansible-pull
* ansible-test
* ansible-vault

## Uninstall ansible commands  ##
* as root:
  * podman container runlabel uninstall ansible
* as non-root

  * (cd ~; podman container runlabel user-uninstall ansible)

## Operation is through SSH back to container host or to other remote systems  ##
Since Ansible is running within a container, the default localhost environment
is the container itself and not the system hosting the container instance. As
such any changes made to the localhost environment are in fact being made to
the container and would be lost when the container exits.

Instead Ansible can be targetted at the host running the container, namely
host.containers.internal, via an SSH connection, using an Ansible inventory
similar to that found in `examples/ansible/inventory/inventory.yaml`, which
looks like:

```yaml
alhost_group:
  hosts:
    alphost:
      ansible_host: host.containers.internal
      ansible_python_interpreter: /usr/bin/python3
```

NOTE: An equivalent `alphost` default inventory item has also been added to
the container's `/etc/ansible/hosts` inventory, which can be leveraged by the
`ansible` command line tool.

For example to run the `setup` module to collect and show the system facts
from the `alphost` you could run a command like the following:

```shell
$ ansible alphost -m setup
alphost | SUCCESS => {
    "ansible_facts": {
...
    },
    "changed": false
}
```

The inventory record could also contain other hosts to be managed.

### SSH keys must be set up ###
The container must be able to SSH to the system being managed. So, the system must support SSH access and
the SSH keys must have been created (using `ssh-keygen`) and the public key must be in the `.ssh/authorized_keys` file for the
target user. While the root user can be used so long as the system allows SSH'ing to the root account,
the preferred method to to use an non-root account that has passwordless sudo rights. Any operations in ansible
play books that require system privilege would then need to use "become: true"

SSH access can be validated with `ssh localhost`.


# Examples

See the `examples/ansible` for example Ansible playbooks.

On an ALP system where the Ansible workload container has been installed,
using the `install` runlabel, the examples will be available under the
`/usr/local/share/ansible-container/examples/ansible` directory.

There are three playbooks currently under /usr/local/share/ansible-container/examples/ansible
* playbook.yml
* network.yml
* setup_libvirt_host.yml


## Simple Ansible test (playbook.yml)
The 'playbook.yml' tests several common ansible operations, such as gathering facts and testing for installed packages.
The play is invoked changing to directory `/usr/local/share/ansible-container/examples/ansible` and entering:
```shell
$ ansible-playbook playbook.yml
...
PLAY RECAP ***************************************************************************************************************
alphost                    : ok=8    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

## Ansible driving nmcli to change system networking (network.yml)
The 'network.yml' uses the 'community.general.nmcli' plugin to test common network operations such as assigning static IP addresses to NICs and creating bonded interfaces.

The NICs, IP addresses, bond names, bonded NICs are defined in the 'vars" section of network.yml and should be updated to reflect the current user environment. The 'network.yml' play is run by changing to directory `/usr/local/share/ansible-container/examples/ansible` and entering:
```shell
$ ansible-playbook network.yml 
...
ASK [Ping test Bond IPs] ************************************************************************************************
ok: [alphost] => (item={'name': 'bondcon0', 'ifname': 'bond0', 'ip4': '192.168.181.10/24', 'gw4': '192.168.181.2', 'mode': 'active-backup'})
ok: [alphost] => (item={'name': 'bondcon1', 'ifname': 'bond1', 'ip4': '192.168.181.11/24', 'gw4': '192.168.181.2', 'mode': 'balance-alb'})

TASK [Ping test static nics IPs] *****************************************************************************************
ok: [alphost] => (item={'name': 'enp2s0', 'ifname': 'enp2s0', 'ip4': '192.168.181.3/24', 'gw4': '192.168.181.2', 'dns4': ['8.8.8.8']})
ok: [alphost] => (item={'name': 'enp3s0', 'ifname': 'enp3s0', 'ip4': '192.168.181.4/24', 'gw4': '192.168.181.2', 'dns4': ['8.8.8.8']})

PLAY RECAP ***************************************************************************************************************
alphost                    : ok=9    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   


## Setup ALP as a Libvirt host

The `setup_libvirt_host.yml` playbook can be used to install the ALP
`kvm-container` workload and enable `libvirtd` as a systemd service.

To try out this example playbook, you can change directory to the
`/usr/local/share/ansible-container/examples/ansible` directory and
run the following command:

```shell
$ ansible-playbook setup_libvirt_host.yml
...
PLAY RECAP *****************************************************************************************************************************
alphost                    : ok=9    changed=2    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0

$ sudo /usr/local/bin/virsh list --all
using /etc/kvm-container.conf as configuration file
+ podman exec -ti libvirtd virsh list --all
Authorization not available. Check if polkit service is running or see debug message for more information.
 Id   Name   State
--------------------
```

NOTE: If the required kernel and supporting packages are not already
installed a reboot will be required to complete the install of those
packages; please follow the directions generated by the playbook, and
re-run the playbook after the reboot has completed successfully to
finish the setup of the `libvirtd` service.

