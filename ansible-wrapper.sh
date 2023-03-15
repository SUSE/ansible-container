#! /bin/sh
PATH=/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin

KEED_USERID=""
if [[ $(id -ru) != "0" ]]; then
    KEED_USERID="--userns=keep-id"
fi

# make symlinks for mount points
# this needed to hand colons in file path names
LINK_DIR=`mktemp -d -p /tmp`
ln -s $(pwd)  ${LINK_DIR}/work
ln -s ${HOME} ${LINK_DIR}/home

podman run  --security-opt label=disable -it -v ${LINK_DIR}/work:/work -v ${LINK_DIR}/home:${HOME} ${KEED_USERID} --rm ansible "$(basename "${0}")" "$@"

# clean up symlink area
rm ${LINK_DIR}/work ${LINK_DIR}/home
rmdir ${LINK_DIR}
