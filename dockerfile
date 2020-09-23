# dockerfile for caddyserver 

ARG CADDY_VERSION=2.2.0-rc.3

FROM alpine:3.11.6

ARG BUILD_DATE
ARG VCS_REF

ENV PORT=8000 CADDY_VERSION=2.2.0-rc.3 CADDY_ARCHITECTURE=amd64

LABEL maintainer="DevOps <noreply@yfreighttrust.com>" \
    architecture="amd64/x86_64" \
    caddy-version="2.2.0-rc.3" \
    alpine-version="3.11.6" \
    build="26-May-2020" \
    org.opencontainers.image.title="alpine-caddy" \
    org.opencontainers.image.description="Alpine Caddyserver" \
    org.opencontainers.image.authors="CONTRIBUTORS <noreply@yfreighttrust.com>" \
    org.opencontainers.image.vendor="Freight Trust and Clearing" \
    org.opencontainers.image.version="v2.2.0-rc.3" \
    org.opencontainers.image.url="https://quay.io/organization/freight/alpine-caddy/" \
    org.opencontainers.image.source="https://github.com/freight-trust/alpine-caddy" \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.created=$BUILD_DATE



ARG plugins=http.git,http.cache,http.expires,http.minify,http.realip

RUN apk add --no-cache openssh-client git tar curl libcap



RUN curl --silent --show-error --fail --location --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - \
      "https://caddyserver.com/download/linux/amd64?plugins=${plugins}&license=personal&telemetry=off" \
    | tar --no-same-owner -C /usr/bin/ -xz caddy && \
    chmod 0755 /usr/bin/caddy && \
    addgroup -S caddy && \
    adduser -D -S -s /sbin/nologin -G caddy caddy && \
    setcap cap_net_bind_service=+ep `readlink -f /usr/bin/caddy` && \
    /usr/bin/caddy -version

EXPOSE 80 443 2015
VOLUME /srv
WORKDIR /srv

COPY files/Caddyfile /etc/Caddyfile
COPY files/index.html /srv/index.html

RUN chown -R caddy:caddy /srv

USER caddy

ENTRYPOINT ["/usr/bin/caddy"]
CMD ["--conf", "/etc/Caddyfile"]
