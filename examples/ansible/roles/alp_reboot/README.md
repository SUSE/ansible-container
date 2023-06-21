markdown

# Ansible Role: alp_reboot

## Overview

The `alp_reboot` role is designed to manage system reboots in an Ansible-controlled environment. It checks for the existence of a specific systemd service unit file, removes it if it does exist, and then recreates it based on a specific template. This role also manages the lingering settings for a specific user and initiates a system reboot when necessary.


## Role Variables

The main variable used in this role is `ansible_user`, which specifies the user account to enable lingering for and to execute tasks that require elevated privileges. Additionally, `playbook_path`, `ansible_playbook_basename`, and `reboot_mode` are also defined in this role.

## Tasks Included in This Role

Here's an overview of the tasks executed by this role:

1. Enable lingering for the `ansible_user`.
2. Check if the service unit file `/etc/systemd/system/myplaybook.service` exists. If it does, remove it.
3. Create a systemd service unit file from the template `myplaybook.service.j2` only if it did not exist previously.
4. Enable and start the `myplaybook` service, only if the service unit file did not previously exist.
5. Reboot the system if the service unit file did not previously exist.
6. Remove the `myplaybook.service` service file.
7. Reload the systemd daemon.
8. Conditionally end the playbook execution.



Usage

You can include this role in your Ansible playbook to manage system reboots.

The include_role syntax in the playbook looks like this:

```yaml

- name: Handle auto reboot, if needed
  include_role:
    name: alp_reboot
    tasks_from: start
  when: required_pkgs_install.changed and (reboot_mode | default('manual')) == 'auto'
```
Here's the breakdown of what's happening:

    The name: alp_reboot part specifies the role to include, which in this case is alp_reboot.

    The tasks_from: start part specifies the tasks file from the alp_reboot role to include. Ansible roles typically have a tasks directory that contains various task files. The start value refers to start.yml file within the tasks directory of the alp_reboot role.

    The when: required_pkgs_install.changed and (reboot_mode | default('manual')) == 'auto' part specifies the condition under which the tasks from the included role should be executed. In this case, the alp_reboot role will be included if the required_pkgs_install result has changed (i.e., packages have been installed) and the reboot_mode variable is set to 'auto'.

Similarly, towards the end of the playbook, the alp_reboot role is included again but with tasks_from: end. This refers to the end.yml file within the tasks directory of the alp_reboot role:

```yaml

- name: clean up
  include_role:
    name: alp_reboot
    tasks_from: end
  when: (reboot_mode | default('manual')) == 'auto'

Here, the role's tasks are executed when the reboot_mode variable is set to 'auto'. These tasks would typically include any cleanup activities that need to be performed after the main tasks of the role have been executed.
```
You can add the alp_reboot role to your playbook as shown:

```yaml

- hosts: alphost
  roles:
    - alp_reboot
  vars:
    ansible_user: your_user
    playbook_path: /path/to/your/playbook
    ansible_playbook_basename: your_playbook.yml
    reboot_mode: auto
```

Replace your_user, /path/to/your/playbook, and your_playbook.yml with the appropriate values. This playbook runs the alp_reboot role on the hosts defined under alphost.

Alternatively, you can use this role directly from the command line:


```bash

ansible-playbook setup_libvirt_host.yml -e "playbook_path=$(pwd)" -e "ansible_user=$(whoami)" -e "reboot_mode=auto"
```


