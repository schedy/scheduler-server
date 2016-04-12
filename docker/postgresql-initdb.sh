#!/bin/bash

unit_pgdata=''
unit_pgport=''

handle_service_env()
{
    local service="$1"

    local systemd_env="$(systemctl show -p Environment "${service}.service")" \
        || { return; }

    for env_var in `echo "$systemd_env" | sed 's/^Environment=//'`; do
        # If one variable name is defined multiple times the last definition wins.
        case "$env_var" in
            PGDATA=*)
                unit_pgdata="${env_var##PGDATA=}"
                echo "unit's datadir: '$unit_pgdata'"
                ;;
            PGPORT=*)
                unit_pgport="${env_var##PGPORT=}"
                echo "unit's pgport: $unit_pgport"
                ;;
        esac
    done
}

handle_service_env postgresql

# Already initialized?
if test -f "${unit_pgdata}/PG_VERSION"; then
    echo "'${unit_pgdata}/PG_VERSION' found, skiping..."
    exit 0
else
    echo "No '${unit_pgdata}/PG_VERSION' found, run initdb..."
    PDDATA_DIR=$(dirname ${unit_pgdata})
    mkdir -p ${PDDATA_DIR}
    chown postgres.postgres ${PDDATA_DIR}
    export PGSETUP_INITDB_OPTIONS="--locale=en_US.UTF-8 --encoding=UTF-8"
    /usr/bin/postgresql-setup --initdb 
    PGS_OK=$?
    if [ $PGS_OK = 0 ];then
        echo "/usr/bin/postgresql-setup was successful"
        exit $PGS_OK
    else
        echo "/usr/bin/postgresql-setup failed!"
        exit $PGS_OK
    fi
fi

# vim:set softtabstop=4 shiftwidth=4 tabstop=4 expandtab:
