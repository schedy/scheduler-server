# podman build -f Dockerfile.nginx -t schedy-nginx

FROM fedora:33 AS base
RUN dnf -y install procps-ng iproute psmisc mc less # ps, ss, killall, mc, less


FROM base AS release
RUN dnf -y install nginx
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 8000
ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]

