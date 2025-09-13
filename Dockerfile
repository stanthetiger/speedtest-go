ARG ALPINE_VERSION=3.22
ARG GO_VERSION=1.25

FROM golang:${GO_VERSION}-alpine${ALPINE_VERSION} AS builder
WORKDIR /build
COPY ./ ./
RUN go build -ldflags "-w -s" -trimpath -o speedtest .
RUN mv web/assets/example-singleServer-gauges.html web/assets/index.html && \
    sed -i 's/LibreSpeed Example/LibreSpeed SpeedTest Go/g' web/assets/index.html

FROM alpine:${ALPINE_VERSION}
ENV TZ="UTC" UID=1000 GID=1000
RUN apk add --update --no-cache ca-certificates su-exec && \
    mkdir /config
WORKDIR /app
COPY --from=builder /build/web/assets/index.html /build/web/assets/*.js /app/assets-default/
COPY --from=builder /build/entrypoint.sh /build/speedtest /build/settings.toml /app/

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["/app/speedtest", "-c", "/config/settings.toml"]
