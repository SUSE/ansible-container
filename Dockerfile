FROM opensuse/tumbleweed

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN mkdir /container
COPY label-install /container
COPY label-uninstall /container

WORKDIR /work

LABEL INSTALL="/usr/bin/podman run --env IMAGE=IMAGE --rm --privileged -v /:/host IMAGE /bin/bash /container/label-install"
LABEL USER-INSTALL="/usr/bin/podman run --env IMAGE=IMAGE --rm -v \${PWD}/:/host IMAGE /bin/bash /container/label-install"
LABEL UNINSTALL="/usr/bin/podman run --rm --privileged -v /:/host IMAGE /bin/bash /container/label-uninstall"
LABEL USER-UNINSTALL="/usr/bin/podman run --rm -v \${PWD}/:/host IMAGE /bin/bash /container/label-uninstall"

RUN zypper -v -n in gcc libffi-devel python3 python3-pip wget ansible-core ansible sshpass openssh-clients

