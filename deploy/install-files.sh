#!/bin/bash

read -s -p "Installation Dir: " INSTDIR
echo

./generate-files.sh ${INSTDIR}

install -o root -g root -m 0755 -T scheduler-init.sh /usr/libexec/scheduler-init.sh
install -o root -g root -m 0644 *.service /usr/lib/systemd/system/

systemctl enable \
    scheduler-dealer.service \
    scheduler-rails.service \
    scheduler-init.service \
    scheduler-status-saver.service \
    scheduler-seapig-server.service \
    scheduler-seapig-router-session-manager.service \
    scheduler-seapig-postgres-notifier.service

systemctl enable \
    scheduler-seapig-worker@proc-001.service \
    scheduler-seapig-worker@proc-002.service \
    scheduler-seapig-worker@proc-003.service \
    scheduler-seapig-worker@proc-004.service

systemctl daemon-reload

cat<<EOF
Rails needs some secret, the scheduler-rails.service file includes
it from /etc/scheduler/secret.env, it can be created with:

cd <SCHEDULER_ROOT>
mkdir /etc/scheduler/
echo "SECRET_KEY_BASE=\$(bundle exec rake secret)" > /etc/scheduler/secret.env
chmod 600 /etc/scheduler/secret.env
chown schedy.schedy /etc/scheduler/secret.env
EOF

# vim:set softtabstop=4 shiftwidth=4 tabstop=4 expandtab:
