#!/bin/bash

DIR=$1

for FILE in $(ls -1 *.in); do
    sed -e "s%@INSTALL_DIR@%${DIR}%g" ${FILE} > ./$(basename --suffix=.in ${FILE})
done

# vim:set softtabstop=4 shiftwidth=4 tabstop=4 expandtab:
