# SPDX-License-Identifier: MIT
# Define the tags for OBS and build script builds:
#!BuildTag: suse/alp/workloads/ansible:latest
#!BuildTag: suse/alp/workloads/ansible:%PKG_VERSION%.%TAG_OFFSET%
#!BuildTag: suse/alp/workloads/ansible:%PKG_VERSION%.%TAG_OFFSET%.%RELEASE%

FROM opensuse/tumbleweed:latest

# Mandatory labels for the build service:
#   https://en.opensuse.org/Building_derived_containers
# Define labels according to https://en.opensuse.org/Building_derived_containers
# labelprefix=com.suse.alp.workloads.ansible
LABEL org.opencontainers.image.title="Ansible base container"
LABEL org.opencontainers.image.description="Container for Ansible"
LABEL org.opencontainers.image.created="%BUILDTIME%"
LABEL org.opencontainers.image.version="0.1"
LABEL org.openbuildservice.disturl="%DISTURL%"
LABEL org.opensuse.reference="registry.opensuse.org/suse/alp/workloads/tumbleweed_containerfiles/suse/alp/workloads/ansible:%PKG_VERSION%-%RELEASE%"
LABEL com.suse.supportlevel="techpreview"
LABEL com.suse.eula="beta"
LABEL com.suse.image-type="application"
LABEL com.suse.release-stage="alpha"
# endlabelprefix

# openssh-clients : for ansble ssh

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN mkdir /container
COPY label-install /container
COPY label-uninstall /container
COPY ansible-wrapper.sh /container/ansible-wrapper.sh
RUN chmod +x  /container/ansible-wrapper.sh

WORKDIR /work

LABEL INSTALL="/usr/bin/podman run --env IMAGE=IMAGE --rm --security-opt label=disable -v /:/host IMAGE /bin/bash /container/label-install"
LABEL UNINSTALL="/usr/bin/podman run --rm --security-opt label=disable -v /:/host IMAGE /bin/bash /container/label-uninstall"
LABEL USER-INSTALL="/usr/bin/podman run --env IMAGE=IMAGE --security-opt label=disable --rm -v \${PWD}/:/host IMAGE /bin/bash /container/label-install"
LABEL USER-UNINSTALL="/usr/bin/podman run --rm --security-opt label=disable -v \${PWD}/:/host IMAGE /bin/bash /container/label-uninstall"

RUN zypper -v -n in \
ansible-core \
ansible \
ansible-test \
openssh-clients \
git \
python3-libvirt-python \
python3-netaddr \
;zypper clean --all


