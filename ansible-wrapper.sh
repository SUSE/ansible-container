#! /bin/sh
PATH=/sbin:/usr/sbin:/usr/local/sbin:/root/bin:/usr/local/bin:/usr/bin:/bin

KEED_USERID=""
if [[ $(id -ru) != "0" ]]; then
    KEED_USERID="--userns=keep-id"
fi

podman run  --security-opt label=disable -it -v ${PWD}:/work -v ${HOME}:${HOME} ${KEED_USERID} --rm ansible "$(basename "${0}")" "$@"

