#!/bin/bash

if [[ -n ${REPO_PROXY} ]]; then
    echo "Set up '${REPO_PROXY}' as repo proxy!"
    dnf -y --setopt=tsflags=nodocs --setopt=proxy=${REPO_PROXY} makecache
    dnf -y --setopt=tsflags=nodocs --setopt=proxy=${REPO_PROXY} install 'dnf-command(config-manager)'
    dnf config-manager --setopt=proxy=${REPO_PROXY} $(for REPO in $(dnf repolist -v | grep Repo-id | awk '{print $3}'); do echo -n "$REPO "; done) --save
else
    echo "No proxy on as --build-arg=REPO_PROXY_ARG='...' given!"
    dnf -y --setopt=tsflags=nodocs makecache
fi
