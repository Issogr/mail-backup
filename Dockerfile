FROM python:3.14-alpine3.24

ARG OFFLINEIMAP_VERSION=8.0.3

RUN apk add --no-cache ca-certificates su-exec tzdata \
    && pip install --no-cache-dir "offlineimap==${OFFLINEIMAP_VERSION}" \
    && offlineimap -V

COPY --chmod=755 deploy/entrypoint.sh /entrypoint.sh

ENV CONFIG_PATH=/vol/config \
    HOME=/tmp \
    MAIL_PATH=/vol/mail \
    PGID=1000 \
    PUID=1000 \
    TZ=UTC

VOLUME ["/vol"]

ENTRYPOINT ["/entrypoint.sh"]
