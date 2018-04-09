#!/bin/bash

function finish {
    /bin/logger -t ZABBIX_SCHEDY -- "{$$} oh my god, they killed me!"
}
trap finish SIGINT SIGTERM

QUEUE=$1
STATUS=$2
SQL=""

/bin/logger -t ZABBIX_SCHEDY -- "{$$} ${QUEUE} - ${STATUS}: start"


trap "{ trap - EXIT;  }" EXIT


case ${QUEUE} in
    executions)
        TABLE="execution_statuses"
        ;;
    tasks)
        TABLE="task_statuses"
        ;;
    *)
        /bin/logger -t ZABBIX_SCHEDY -- "{$$} ups?! unknown queue! ZBX_NOTSUPPORTED"
        echo "ZBX_NOTSUPPORTED"
        exit 1
        ;;
esac

SQL="SELECT status_counter FROM stats_counter WHERE status_name = '${STATUS}' and status_table = '${TABLE}'"

VAL=$(psql --pset='format=unaligned' --quiet --tuples-only --host 127.0.0.1 scheduler --command "${SQL}")

/bin/logger -t ZABBIX_SCHEDY -- "{$$} ${QUEUE} - ${STATUS}: $VAL"

if [[ ${VAL} == ${VAL//[^0-9]/} ]]; then
    echo ${VAL}
    exit 0
else
    /bin/logger -t ZABBIX_SCHEDY -- "{$$} ups?! ZBX_NOTSUPPORTED"
    echo "ZBX_NOTSUPPORTED"
    exit 1
fi
