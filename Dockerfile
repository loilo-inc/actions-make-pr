FROM alpine:3.10

RUN apk update --no-cache && \
        apk add curl git bash jq

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]