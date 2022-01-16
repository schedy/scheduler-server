# podman build -f Dockerfile.postgresql -t schedy-postgres

FROM fedora:33 AS base
RUN dnf -y install procps-ng iproute psmisc mc less findutils # ps, ss, killall, mc, less


FROM base AS postgres
RUN groupadd -g 1000 postgres && \
    useradd -u 1000 -g 1000 postgres   #postgres doesn't want to be run as root
RUN dnf -y install https://download.postgresql.org/pub/repos/yum/reporpms/F-33-x86_64/pgdg-fedora-repo-latest.noarch.rpm
RUN dnf -y install postgresql13-server postgresql13-contrib glibc-langpack-en
EXPOSE 5432
COPY db/pg_dump.sql /
RUN mkdir /data && mkdir /data/data && chown postgres:postgres -R /data && chmod -R 0750 /data
USER postgres
RUN /usr/pgsql-13/bin/initdb /data/data
RUN sed -i 's/#listen_addresses/listen_addresses/' /data/data/postgresql.conf
RUN find /usr -name postgres
RUN /usr/pgsql-13/bin/postgres -c listen_addresses='' -D /data/data & sleep 5 && createuser scheduler && createdb -O scheduler scheduler && psql -U scheduler scheduler < /pg_dump.sql && killall postgres && sleep 5
VOLUME /data
ENTRYPOINT ["/usr/pgsql-13/bin/postgres", "-D", "/data/data"]

