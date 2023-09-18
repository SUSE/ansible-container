# Containerized Ansible: What's inside #

This container provides the ansible toolstack inside a container.
* '''Dockerfile''' with the definition of the ansible container
  * based on OpenSUSE Tumbleweed
  * installs ansible and some additional tools

## Intended purpose

This container is intended as a reference example of an Ansible workload
container, based upon the latest Ansible version available for openSUSE
Tumbleweed, for use on SUSE's Adaptable Linux Platform, and is tailored
for that purpose, with included example playbooks that demonstrate how
to configure networking and enable Libvirt support.

### SUSE ALP Open Build Service

This container is being built in the
[Open Build Service SUSE:ALP:Workloads project](https://build.opensuse.org/package/show/SUSE:ALP:Workloads/ansible-container)
and published in
[registry.opensuse.org](https://registry.opensuse.org/cgi-bin/cooverview?srch_term=project%3D%5ESUSE%3A+container%3Dansible)

See our [Open Build Service integration workflow](OpenBuildService.md)
for more details.

### Testing

Note that [SUSE/alp-test-env][https://github.com/SUSE/alp-test-env] was
developed to support development and testing of this container. It can
be used to bring up one or more ALP test vms in a repeatable fashion
that can be used for testing purposes.

## System Setup ##
* Podman, python3-lxml and python3-rpm are needed on the container host. The run label commands are hard coded to use podman. Python3-lxml and python3-rpm  are required on the container host for ansible to interact with libvirt and gather package facts. Kernel-default-base does not contain the needed drivers for many Network Manager (nmcli) operations such as creating bonded interfaces and should be replaced with kernel-default.
  * `sudo transactional-update pkg install python3-rpm python3-lxml kernel-default -kernel-default-base`
  * system reboot is required after all transactional updates
    * `sudo shutdown -r now`

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
```

## Setup ALP as a Libvirt host

The `setup_libvirt_host.yml` playbook can be used to install the ALP
`kvm-container` workload and enable `libvirtd` as a systemd service.

To try out this example playbook, you can change directory to the
`/usr/local/share/ansible-container/examples/ansible` directory and
run the following command:

```shell
$ cd /usr/local/share/ansible-container/examples/ansible
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

## Create an openSUSE Tumbleweed appliance VM

The `create_tumbleweed_vm.yml` example playbook can be used to create
and start a Libvirt managed VM, called `tumbleweed`, based upon the
latest available Tumbleweed appliance VM image.

It leverages the `setup_libvirt_host.yml` example playbook, as outlined
previously, to ensure that the ALP host is ready to manage VMs before
creating the new VM, and may fail prompting you to reboot before running
the playbook again to finish setting up Libvirt and creating the VM.

```shell
$ cd /usr/local/share/ansible-container/examples/ansible
$ ansible-playbook create_tumbleweed_vm.yml
...
TASK [Query list of libvirt VMs] *******************************************************************************************************
ok: [alphost]

TASK [Show that Tumbleweed appliance has been created] *********************************************************************************
ok: [alphost] => {
    "msg": "Running VMs: tumbleweed"
}

PLAY RECAP *****************************************************************************************************************************
alphost                    : ok=15   changed=4    unreachable=0    failed=0    skipped=6    rescued=0    ignored=0

```

## Setup NeuVector on ALP host

The setup_neuvector.yml playbook can be used to deploy the NeuVector workload on an ALP host.

```shell
$ cd /usr/local/share/ansible-container/examples/ansible
$ ansible-playbook setup_neuvector.yml
...
TASK [Print message connect to NeuVector] ************************************************************************************************************************************************************************
ok: [alphost] => {
    "msg": "NeuVector is running on https://HOST_RUNNING_NEUVECTOR_SERVICE:8443 You need to accept the warning about the self-signed SSL certificate and log in with the following default credentials: admin / admin."
}
...
PLAY RECAP *****************************************************************************************************************************
alphost                    : ok=8   changed=6    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

For more details, you can refer to the [SUSE ALP documentation](https://documentation.suse.com/alp/dolomite/html/alp-dolomite/available-alp-workloads.html#task-run-neuvector-with-podman).

## Setup Kea DHCP Server on ALP Host

The setup_kea_dhcp_server.yml and setup_kea_dhcpv6_server.yml playbook automates the deployment and management of the Kea DHCPV4 and DHCPV6 server workload on an ALP host.

```shell
$ cd /usr/local/share/ansible-container/examples/ansible
$ ansible-playbook setup_kea_dhcp_server.yml
...
TASK [Start Kea DHCPv4 server using systemd] *********************************************************************************************************************************************************************
changed: [alphost]

PLAY RECAP *******************************************************************************************************************************************************************************************************
alphost                    : ok=6    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  

```
### Configuring DHCP Server:

For configuration, the playbooks utilize sample files named kea-dhcp4.conf and kea-dhcp6.conf. These files are located in the /templates directory and are provided as default configurations for Kea DHCPv4 and DHCPv6 servers, respectively.

While these default configurations are suitable for many environments, you might have specific requirements or preferences for your setup. In such cases, you can modify these files in the /templates directory before running the playbook, allowing for a more tailored DHCP configuration.

After deployment, the active Kea configuration files can be found in the /etc/kea directory. For a deep dive into configuring the Kea DHCP server, kindly refer to the official documentation available at https://kea.readthedocs.io/

## Setup Cockpit Web Server on ALP Host

The setup_cockpit.yml playbook automates the deployment of the Cockpit Web server on an ALP Dolomite host using a containerized approach with Podman.

```shell
$ cd /usr/local/share/ansible-container/examples/ansible
$ ansible-playbook setup_cockpit.yml
...
TASK [Start Cockpit Web server using systemd] ***************************************************************************************************
changed: [alphost]

PLAY RECAP ***************************************************************************************************************************************
alphost                    : ok=7    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```
After running the playbook, access the Cockpit Web interface at https://HOSTNAME_OR_IP_OF_ALP_HOST:9090. Accept the certificate warning due to the self-signed certificate.

## Deploy Firewalld on ALP Host

Using the setup_firewalld.yml Ansible playbook, deploy Firewalld via Podman on SUSE ALP Dolomite to define network trust levels. Ensure dbus and polkit configurations are set beforehand. Use the /usr/local/bin/firewall-cmd wrapper to manage the firewalld instance.

For an in-depth understanding, refer to the [Firewalld-Podman-Dolomite Documentation](https://documentation.suse.com/alp/dolomite/html/alp-dolomite/available-alp-workloads.html#task-run-firewalld-with-podman).

```shell
$ cd /usr/local/share/ansible-container/examples/ansible
$ ansible-playbook setup_firewalld.yml
...
PLAY RECAP ***************************************************************************************************************************************
alphost                    : ok=8    changed=5    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0

```

## Deploy GNOME Display Manager on ALP Host

This playbook simplifies the deployment and running of the GNOME Display Manager (GDM) on SUSE ALP Dolomite. Leveraging Podman, it allows users to run GDM within a containerized environment. The playbook will install necessary packages, configure SELinux, retrieve and set up the necessary container images, manage system services related to GDM, and start GDM as a service.

For an in-depth understanding, refer to the [GDM-Dolomite Documentation](https://documentation.suse.com/alp/dolomite/html/alp-dolomite/available-alp-workloads.html#task-run-gdm-with-podman)

```shell
$ cd /usr/local/share/ansible-container/examples/ansible
$ ansible-playbook setup_gnome_display_manager.yml
...
PLAY RECAP ***************************************************************************************************************************************
alphost                    : ok=10    changed=6    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0

```
