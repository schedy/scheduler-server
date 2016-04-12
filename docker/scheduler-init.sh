#!/bin/bash


check_db() {
    echo "Check if DB is set up."
    # some vars which we need
    DBM_OK=5
    CU_OK=5
    CDB_OK=5


    pushd /opt/schedy/scheduler/
    su -c "RAILS_ENV=production bundle exec rake db:migrate" schedy
    DBM_OK=$?
    popd

    if [ $DBM_OK = 0 ]; then
        echo "All fine, skipping..."
        return $DBM_OK
    else
        HAS_ROLE=$(su -c "/usr/bin/psql -A -t -c \"select count(*) from pg_user where usename='schedy'\"" postgres 2>/dev/null || echo "42")
        if [ $HAS_ROLE = 0 ]; then
            echo "No role 'schedy' in postgresql, create role..."
            su -c "/usr/bin/createuser --echo --login schedy" postgres
            CU_OK=$?
        elif [ $HAS_ROLE = 42 ]; then
            echo "Is postgresql not running? giving up!"
            return 42
        fi

        if [ $CU_OK = 0 ]; then
            HAS_DB=$(su -c "/usr/bin/psql -A -t -c \"select count(*) from pg_database where datname='scheduler' \"" postgres 2>/dev/null || echo "42")
            if [ $HAS_DB = 0 ]; then
                echo "No db 'scheduler' in postgresql, create db..."
                su -c "/usr/bin/createdb --echo --owner=schedy scheduler" postgres
                CDB_OK=$?
            elif [ $HAS_ROLE = 42 ]; then
                echo "Is postgresql not running? giving up!"
                return 42
            fi

            if [ $CDB_OK = 0 ]; then
                echo "Now db:migrate should work, try again..."
                pushd /opt/schedy/scheduler/
                su -c "RAILS_ENV=production bundle exec rake db:migrate" schedy
                DBM_OK=$?
                popd

                if [ $DBM_OK = 0 ]; then
                    echo "all fine now, scheduler can start..."
                    return 0
                else
                    echo "db:migrate still fails, giving up!" 
                    return $DBM_OK
                fi
            else
                echo "/usr/bin/createdb failed!"
                return $CDB_OK
            fi
        else
            echo "/usr/bin/createuser failed!"
            return $CU_OK
        fi
    fi
    # should never be reached!
    return 1
}

check_rails_pid() {
    echo "Check if rails server.pid needs to be removed!"
    if [ -f /opt/schedy/scheduler/tmp/pids/server.pid ]; then
        echo "found /opt/schedy/scheduler/tmp/pids/server.pid, this looks could be a problem!"

        SYSTEMCTL_PID=$(systemctl show --no-pager --property=MainPID scheduler-rails.service| cut -f2 -d=)
        FILE_PID=$(cat /opt/schedy/scheduler/tmp/pids/server.pid)
        if [ $SYSTEMCTL_PID = $FILE_PID ]; then
            echo "Rails is running?! don't touch the .pid file:"
            echo $(systemctl status scheduler-rails.service)
            return 0
        else
            echo "It seems Rails is not running! remove the .pid file:"
            echo $(systemctl status scheduler-rails.service)
            rm -vf /opt/schedy/scheduler/tmp/pids/server.pid
            RM_OK=$?
            if [ $RM_OK = 0 ]; then
                echo "file removed!"
                return $RM_OK
            else 
                echo "could not remove /opt/schedy/scheduler/tmp/pids/server.pid file?!"
                return 1
            fi
        fi
    else
        echo "no /opt/schedy/scheduler/tmp/pids/server.pid found, no problem! continue..."
        return 0
    fi
    # should never be reached!
    return 1
}

#############################################################################
#############################################################################
##
## MAIN
##
#############################################################################
#############################################################################

if check_db && \
   check_rails_pid
then
    echo "all init checks passed!"
    exit 0
else
    echo "something failed during init phase!"
    exit 1
fi

# vim:set softtabstop=4 shiftwidth=4 tabstop=4 expandtab:
