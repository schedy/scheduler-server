#!/bin/bash

unit_pgdata=''
unit_pgport=''

DEFAULT_PSQL_SETUP="/usr/bin/postgresql-setup"
PSQL_SETUP="${DEFAULT_PSQL_SETUP}"

DEFAULT_SYSTEMD_UNIT_NAME="postgresql"
SYSTEMD_UNIT_NAME="${DEFAULT_SYSTEMD_UNIT_NAME}"

INITDB_OPT="--initdb"

usage()
{
    cat<<EOF

    $0 [OPTIONS]

    OPTIONS:
        -h
            Shows this help page

        -p /path/to/postgresql-setup
            Overwrite the default path (${DEFAULT_PSQL_SETUP})
            of postgresql-setup

        -u UNIT_NAME
            Overwrite the default systemd unit name (${DEFAULT_SYSTEMD_UNIT_NAME})
            of postgresql database

        -n
            In Postgres 9.5 the setup script changed from
            '--initdb' to 'initdb' option. -n sets 'initdb'
            without -n '--initdb' is used.

EOF
}

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

while getopts ":hnp:u:" opt; do
    case $opt in
        h)
            usage
            exit 1
        ;;
        n)
            INITDB_OPT="initdb"
        ;;
        p)
            PSQL_SETUP=$OPTARG
        ;;
        u)
            SYSTEMD_UNIT_NAME=$OPTARG
        ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            exit 1
        ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
        ;;
    esac
done


if [[ ! -f "${PSQL_SETUP}" ]]; then
    echo "postgresql-setup not found under: '${PSQL_SETUP}'"
    echo "Default is '${DEFAULT_PSQL_SETUP}'. Maybe /usr/pgsql-Y.Z/bin/postgresqlYZ-setup?"
    echo "It can be set with -p /path/to/postgresql-setup"
    exit 2
fi

systemctl cat ${SYSTEMD_UNIT_NAME}.service > /dev/null
SCC_OK=$?
if [ $SCC_OK -gt 0 ];then
    echo "'${SYSTEMD_UNIT_NAME}' unit file not found?!"
    echo "Default unit name is: '${DEFAULT_SYSTEMD_UNIT_NAME}'. Maybe postgresql-Y.Z?"
    echo "It can be set with -u UNIT_NAME (without '.service')"
    exit 2
fi

handle_service_env ${SYSTEMD_UNIT_NAME}

# Already initialized?
if [[ -f "${unit_pgdata}/PG_VERSION" ]]; then
    echo "'${unit_pgdata}/PG_VERSION' found, skiping..."
    exit 0
else
    echo "No '${unit_pgdata}/PG_VERSION' found, run initdb..."
    PDDATA_DIR=$(dirname ${unit_pgdata})
    mkdir -p ${PDDATA_DIR}
    chown postgres.postgres ${PDDATA_DIR}
    export PGSETUP_INITDB_OPTIONS="--locale=en_US.UTF-8 --encoding=UTF-8"
    ${PSQL_SETUP} ${INITDB_OPT} ${SYSTEMD_UNIT_NAME}
    PGS_OK=$?
    if [ $PGS_OK = 0 ];then
        echo "${PSQL_SETUP} was successful"
        exit $PGS_OK
    else
        echo "${PSQL_SETUP} failed!"
        exit $PGS_OK
    fi
fi

# vim:set softtabstop=4 shiftwidth=4 tabstop=4 expandtab:
