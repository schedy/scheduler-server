# ####################################################################################################
#
# To build an image:
# docker build <PATH_TO_FOLDER_OF_THIS_FILE> 
# e.g.
# docker build -t scheduler-image .
#
# ####################################################################################################
#
# To build a container:
# docker create -v <PG_DATA_STORE>:/data/:Z -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
#        --add-host rabbit-server:WWW.XXX.YYY.ZZZ <IMAGE-ID_OR_NAME>
# e.g.
# docker create --name scheduler-container -v /data/docker-psql:/data/:Z \
#        -v /sys/fs/cgroup:/sys/fs/cgroup:ro --add-host rabbit-server:0.0.0.0 scheduler-image
#
# <PG_DATA_STORE> is the path on the host system to store the
# postgres 'database cluster'. Without '-v <PG_DATA_STORE>:/data/:Z'
# the 'database cluster' will be located inside the container and
# will be lost when the container is deleted!
#
# scheduler-celery-deamon.service and scheduler-celery-interpreter.service need a working RabbitMQ
# server port is the standart port 5672, the IP can be configured over the host name rabbit-server.
#
# Alternatively you can also create a Docker 'named volume' and mount
# in /data:
# docker create -v myDATA:/data/:Z <IMAGE-ID_OR_NAME>
#
# --privileged might be needed for systemd to work!
# see: http://lwn.net/SubscriberLink/676831/bc927a5c0955d2b7/
#
# ####################################################################################################
#
# To start a container:
# docker start <CONTAINER-ID_OR_NAME>
# e.g.
# docker start scheduler-container
#
# ####################################################################################################
# 
# To get a bash in the container:
# docker exec -it <CONTAINER-ID_OR_NAME> /bin/bash
# e.g.
# docker exec -it scheduler-container /bin/bash
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
# By default 2 seapig-worker instances will be started, if you need
# more or less, add resp. remove the symlinks in:
# /etc/systemd/system/multi-user.target.wants/
# to 
# /usr/lib/systemd/system/scheduler-seapig-worker@.service
#
# ####################################################################################################
# 
# systemd-analyze dot | grep -E 'digraph|}|scheduler|postgresql' | grep -v -E 'mount|slice|basic.target|systemd-journald.socket|shutdown.target|network.target'
#

FROM fedora:23

VOLUME ["/sys/fs/cgroup"]
VOLUME ["/run"]
VOLUME ["/tmp"]

ENV container docker

CMD ["/usr/lib/systemd/systemd"]

RUN dnf -y --setopt=tsflags=nodocs group install "C Development Tools and Libraries"
RUN dnf -y --setopt=tsflags=nodocs install cpio rubygem-bundler ruby-devel redhat-rpm-config libxml2-devel libxslt-devel postgresql-devel postgresql-server nodejs bash-completion

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

# Scheduler part
RUN useradd --create-home --home-dir /opt/schedy --system --user-group schedy
ADD scheduler-server.tar.bz2 /opt/schedy/scheduler/
RUN chown -R schedy.schedy /opt/schedy/scheduler/
USER schedy
WORKDIR /opt/schedy/scheduler/
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install --deployment
ENV RAILS_ENV production
#RUN bundle exec rake assets:precompile
#WORKDIR /opt/schedy/scheduler/worker
#RUN bundle install --deployment
EXPOSE 3000 3001

USER root

WORKDIR /opt/schedy/scheduler/
RUN mkdir /etc/scheduler/; \
    echo "SECRET_KEY_BASE=$(bundle exec rake secret)" > /etc/scheduler/secret.env; \
    chmod 600 /etc/scheduler/secret.env; \
    chown schedy.schedy /etc/scheduler/secret.env

ADD scheduler-dealer.service \
    scheduler-rails.service \
    scheduler-init.service \
    scheduler-status-saver.service \
    scheduler-celery-daemon.service \
    scheduler-celery-interpreter.service \
    scheduler-seapig-notifier.service \
    scheduler-seapig-server.service \
    scheduler-seapig-session-saver.service \
    scheduler-seapig-worker@.service \
    /usr/lib/systemd/system/

ADD scheduler-init.sh /usr/libexec/

RUN systemctl enable \
    scheduler-dealer.service \
    scheduler-rails.service \
    scheduler-init.service \
    scheduler-status-saver.service \
    scheduler-celery-daemon.service \
    scheduler-celery-interpreter.service \
    scheduler-seapig-notifier.service \
    scheduler-seapig-server.service \
    scheduler-seapig-worker@proc-001.service \
    scheduler-seapig-worker@proc-002.service \
    scheduler-seapig-session-saver.service

ADD celery.conf /etc/scheduler/

