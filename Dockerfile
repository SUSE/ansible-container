FROM opensuse/tumbleweed

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN mkdir /container
COPY label-install /container
COPY label-uninstall /container

WORKDIR /work

LABEL INSTALL="/usr/bin/podman run --env IMAGE=IMAGE --rm --security-opt label=disable -v /:/host IMAGE /bin/bash /container/label-install"
LABEL USER-INSTALL="/usr/bin/podman run --env IMAGE=IMAGE --security-opt label=disable --rm -v \${PWD}/:/host IMAGE /bin/bash /container/label-install"
LABEL UNINSTALL="/usr/bin/podman run --rm --security-opt label=disable -v /:/host IMAGE /bin/bash /container/label-uninstall"
LABEL USER-UNINSTALL="/usr/bin/podman run --rm --security-opt label=disable -v \${PWD}/:/host IMAGE /bin/bash /container/label-uninstall"

RUN zypper -v -n in gcc libffi-devel python3 python3-pip wget ansible-core ansible sshpass openssh-clients

