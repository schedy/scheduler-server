# ####################################################################################################
#
# To build an image:
# docker build <PATH_TO_FOLDER_OF_THIS_FILE> 
# e.g.
# docker build -t worker-image .
#
# ####################################################################################################
#
# TODO: make use of -h, --hostname="" -  Container host name
#         -> %H is used in estimator/executor/reporter
#       maybe also --add-host=[]      -  Add a custom host-to-IP mapping (host:ip)
#         -> to find the scheduler-server
#
# To build a container:
# docker create -v <PG_DATA_STORE>:/data/:Z -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
#        --hostname <HOSTNAME> --add-host scheduler-server:WWW.XXX.YYY.ZZZ <IMAGE-ID_OR_NAME>
# e.g.
# docker create --name worker-container -v /data/worker/docker-psql:/data/:Z \
#        -v /sys/fs/cgroup:/sys/fs/cgroup:ro --hostname ts003 --add-host scheduler-server:127.0.0.1 worker-image
#
# <PG_DATA_STORE> is the path on the host system to store the
# postgres 'database cluster'. Without '-v <PG_DATA_STORE>:/data/:Z'
# the 'database cluster' will be located inside the container and
# will be lost when the container is deleted!
#
# Alternatively you can also create a Docker 'named volume' and mount
# in /data:
# docker create --privileged -v myDATA:/data/:Z <IMAGE-ID_OR_NAME>
#
# <HOSTNAME> estimator/executor/reporter use the given hostname as worker name, so better
# set it to something meaning full in production.
#
# --add-host: config.rb has the scheduler server set to "scheduler-server", so point it to the IP
#   under which the scheduler server is reachable.
#
# --privileged might be needed for systemd to work! We might need that in future for devices?
# see: http://lwn.net/SubscriberLink/676831/bc927a5c0955d2b7/
#
# ####################################################################################################
#
# To start a container:
# docker start <CONTAINER-ID_OR_NAME>
# e.g.
# docker start worker-container
#
# ####################################################################################################
# 
# To get a bash in the container:
# docker exec -it <CONTAINER-ID_OR_NAME> /bin/bash
# e.g.
# docker exec -it worker-container /bin/bash
#
# ####################################################################################################
#
# The postgresql db inside the container has it's 'database cluster'
# in /data/postgresql/data.
# You can change that in the file:
# 30-postgres-setup.conf
# 
# NOTE:
# Your filesystem layout should ideally look like:
# /ROOT_OWNED_MOUNTPOINT/POSTGRES_OWNED_DIRECTORY/DATADIR
# see: http://www.postgresql.org/docs/9.4/static/creating-cluster.html
#      https://bugzilla.redhat.com/show_bug.cgi?id=1247477#c1
#
# ####################################################################################################
#
# To get a start up graph from Systemd:
# systemd-analyze dot schedule*.service postgres*.service | grep -v -E 'mount|slice|basic.target|systemd-journald.socket|shutdown.target|network.target'
#

FROM fedora:23

VOLUME ["/sys/fs/cgroup"]
VOLUME ["/tmp"]
VOLUME ["/run"]

ENV container docker

CMD ["/usr/lib/systemd/systemd"]

RUN dnf -y --setopt=tsflags=nodocs group install "C Development Tools and Libraries"
RUN dnf -y --setopt=tsflags=nodocs install rubygem-bundler ruby-devel redhat-rpm-config postgresql-devel postgresql-server bash-completion

##################################################################
# needed for some debuging will be removed once it's working :)
##################################################################
RUN dnf -y install procps-ng net-tools
##################################################################

# Postgres part
ADD postgresql-initdb.service /usr/lib/systemd/system/
ADD postgresql-initdb.sh /usr/libexec/
ADD 30-postgres-setup.conf /etc/systemd/system/postgresql.service.d/
RUN systemctl enable postgresql-initdb.service postgresql.service


# Scheduler-Worker part
RUN useradd --create-home --home-dir /opt/tester --system --user-group tester
ADD scheduler-worker.tar.bz2 /opt/tester/scheduler-worker/
RUN chown -R tester.tester /opt/tester/scheduler-worker/


USER tester
WORKDIR /opt/tester/scheduler-worker/
RUN bundle install --deployment

USER root

ADD scheduler-worker-init.sh /usr/libexec/

ADD \
    scheduler-worker-cleaner.service \
    scheduler-worker-estimator.service \
    scheduler-worker-executor.service \
    scheduler-worker-reporter.service \
    scheduler-worker-init.service \
    /usr/lib/systemd/system/

RUN systemctl enable \
    scheduler-worker-cleaner.service \
    scheduler-worker-estimator.service \
    scheduler-worker-executor.service \
    scheduler-worker-reporter.service

