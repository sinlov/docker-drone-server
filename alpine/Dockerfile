## steps Builder https://hub.docker.com/_/golang/tags
FROM golang:1.16.15 AS Builder

ENV DRONE_VERSION 2.19.0

# RUN apk add build-base && \
#     go env -w GO111MODULE=on

WORKDIR /src

# Build with online code
# RUN apk add curl && \
#   curl -L https://github.com/drone/drone/archive/refs/tags/v${DRONE_VERSION}.tar.gz -o v${DRONE_VERSION}.tar.gz && \
#   tar zxvf v${DRONE_VERSION}.tar.gz && rm v${DRONE_VERSION}.tar.gz

RUN apt-get install -y curl && \
  curl -L https://github.com/drone/drone/archive/refs/tags/v${DRONE_VERSION}.tar.gz -o v${DRONE_VERSION}.tar.gz && \
  tar zxvf v${DRONE_VERSION}.tar.gz && rm v${DRONE_VERSION}.tar.gz
# OR with offline tarball
# ADD drone-${DRONE_VERSION} /src/

# WORKDIR /src/drone-${DRONE_VERSION}
# beacuse drone-server change name to gitness
WORKDIR /src/gitness-${DRONE_VERSION}

RUN go mod download -x

ENV CGO_CFLAGS="-g -O2 -Wno-return-local-addr"

RUN go build -ldflags "-extldflags \"-static\"" -tags="nolimit" github.com/drone/drone/cmd/drone-server

## steps Certs
FROM alpine:3.13 AS Certs

RUN apk add -U --no-cache ca-certificates

## steps final
FROM alpine:3.13

EXPOSE 80 443
VOLUME /data

RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

ENV GODEBUG netdns=go
ENV XDG_CACHE_HOME /data
ENV DRONE_DATABASE_DRIVER sqlite3
ENV DRONE_DATABASE_DATASOURCE /data/database.sqlite
ENV DRONE_RUNNER_OS=linux
ENV DRONE_RUNNER_ARCH=amd64
ENV DRONE_SERVER_PORT=:80
ENV DRONE_SERVER_HOST=localhost
ENV DRONE_DATADOG_ENABLED=true
ENV DRONE_DATADOG_ENDPOINT=https://stats.drone.ci/api/v1/series

COPY --from=Certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=Builder /src/gitness-2.19.0/drone-server /bin/drone-server

ENTRYPOINT ["/bin/drone-server"]