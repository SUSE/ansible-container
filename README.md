# What's inside

This container provide ansible toolstack inside a container.
* '''Dockerfile''' with the definition of the ansible container
** based on OpenSUSE Tumbleweed
** installs ansible and some additional tools
* System Setup
** Make sure needed packages installed on the host
---
# sudo transactional-update pkg install podman python310-rpm
---
*** Install ansible commands wrapers
If current user is root /usr/local/bin is updated, for non-root users
the user's ~/bin area is updated.
---
as root:
# (cd ~; podman container runlabel root-install ansible)
as non-root
# (cd ~; podman container runlabel user-install ansible)
---
*** Ansible Commands
---
ansible
ansible-community
ansible-config
ansible-connection
ansible-console
ansible-doc
ansible-galaxy
ansible-inventory
ansible-playbook
ansible-pull
ansible-vault
---

*** Uninstall ansible commands wrapers
---
as root:
# (cd ~; podman container runlabel root-unstall ansible)
as non-root
# (cd ~; podman container runlabel user-unstall ansible)
---
