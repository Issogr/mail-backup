FROM alpine:3.8

RUN \
  echo "**** install packages ****" && \
    apk add --no-cache \
      offlineimap ca-certificates

# copy local files
COPY ./deploy/ /

# default environment
ENV CONFIG_PATH="/vol/config" \
    SECRETS_PATH="/vol/secrets" \
    MAIL_PATH="/vol/mail"

RUN mkdir -p \
  "${CONFIG_PATH}/email" \
  "${SECRETS_PATH}" \
  "${MAIL_PATH}"

RUN chmod +x entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
