# Containerized Ansible: What's inside #

This container provides the ansible toolstack inside a container.
* '''Dockerfile''' with the definition of the ansible container
  * based on OpenSUSE Tumbleweed
  * installs ansible and some additional tools
## System Setup ##
* Podman and python3-rpm are needed on the container host. The run label commands are hard coded to use podman and python3-rpm is required on the container host for ansible to gather package facts.
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
Since ansible is running within a container, the local host is the container and not
system instantiating the container. Any changes made to the local host are made to the
container and would be lost when the container exits. To make host running the container
host.containers.internal can be used in inventory record like:
```
inventory.yaml:
all:
  hosts:
      host.containers.internal:
```

The inventory record could also contain other hosts to be managed.

### SSH keys must be set up ###
The container must be able to SSH to the system being managed. So, the system must support SSH access and
the SSH keys must have been created (using `ssh-keygen`) and the public key must be in the `.ssh/authorized_keys` file for the
target user. While the root user can be used so long as the system allows SSH'ing to the root account,
the preferred method to to use an non-root account that has passwordless sudo rights. Anny operation in ansible
play books that require system privilege would then need to use "become: true"

SSH access can be validated with `ssh localhost`.


