# docker-drone-server

![docker version semver](https://img.shields.io/docker/v/sinlov/docker-drone-server?sort=semver)
[![docker image size](https://img.shields.io/docker/image-size/sinlov/docker-drone-server)](https://hub.docker.com/r/sinlov/docker-drone-server)
[![docker pulls](https://img.shields.io/docker/pulls/sinlov/docker-drone-server)](https://hub.docker.com/r/sinlov/docker-drone-server/tags?page=1&ordering=last_updated)

- docker hub see [https://hub.docker.com/r/sinlov/docker-drone-server](https://hub.docker.com/r/sinlov/docker-drone-server)

- for [https://www.drone.io/](https://www.drone.io/) opensource build

## useage

- super-duper-secret

```bash
# super-duper-secret
$ openssl rand -hex 16
```

- see [https://docs.drone.io/server/provider/gitea/#create-an-oauth-application](https://docs.drone.io/server/provider/gitea/#create-an-oauth-application) to change `DRONE_GITEA_SERVER` `DRONE_GITEA_CLIENT_ID` `DRONE_GITEA_CLIENT_SECRET`

- `DRONE_SERVER_HOST` use `ip:port` or host, like 192.168.110.181:30080
- `DRONE_RPC_SECRET` init by `openssl rand -hex 16`

```bash
# start server
docker run \
  --env=DRONE_GITEA_SERVER= \
  --env=DRONE_GITEA_CLIENT_ID= \
  --env=DRONE_GITEA_CLIENT_SECRET= \
  --env=DRONE_RPC_SECRET=super-duper-secret \
  --env=DRONE_SERVER_HOST=192.168.110.181:30080 \
  --env=DRONE_SERVER_PROTO=http \
  --publish=30080:80 \
  --publish=30443:443 \
  --restart=on-failure:1 \
  --detach=true \
  --name=test-docker-drone-server \
  sinlov/docker-drone-server:latest
# server log
docker logs test-docker-drone-server
# rm
docker rm -f test-docker-drone-server
```

### docker-compose

```yml
# copy right by sinlov at https://github.com/sinlov
# Licenses http://www.apache.org/licenses/LICENSE-2.0
# more info see https://docs.docker.com/compose/compose-file/ or https://docker.github.io/compose/compose-file/
version: '3.7'
services:
  ## drone start
  drone-server: # https://hub.docker.com/r/drone/drone
    container_name: "drone-server"
    image: 'sinlov/docker-drone-server:latest' # https://hub.docker.com/r/sinlov/docker-drone-server some as https://hub.docker.com/r/drone/drone/tags
    depends_on:
      - drone-db
    environment: # https://docs.drone.io/installation/providers/gitea/
      - DRONE_OPEN=true
      - DRONE_AGENTS_ENABLED=true
      # https://docs.drone.io/server/reference/drone-database-secret/ use DRONE_DATABASE_DATASOURCE or openssl rand -hex 16 for sqlite3
      - DRONE_DATABASE_SECRET=${ENV_DRONE_POSTGRESQL_PASSWORD}
      - DRONE_GITEA_SERVER=${ENV_DRONE_GITEA_SERVER}
      # https://docs.gitea.io/en-us/oauth2-provider/
      - DRONE_GITEA_CLIENT_ID=${ENV_DRONE_GITEA_CLIENT_ID}
      - DRONE_GITEA_CLIENT_SECRET=${ENV_DRONE_GITEA_CLIENT_SECRET}
      - DRONE_SERVER_HOST=${ENV_DRONE_SERVER_HOST}
      - DRONE_SERVER_PROTO=http
      # https://docs.drone.io/server/reference/drone-rpc-secret/ openssl rand -hex 16
      - DRONE_RPC_SECRET=${ENV_DRONE_RPC_SECRET}
      - DRONE_BRANCH=main
      - DRONE_REPO_BRANCH=main
      - DRONE_COMMIT_BRANCH=main
      - DRONE_USER_CREATE=username:${ENV_DRONE_USER_ADMIN_CREATE},admin:true # https://docs.drone.io/server/reference/drone-user-create/ let ENV_DRONE_USER_ADMIN_CREATE be admin to open Trusted
    volumes:
      - ./data/drone-server:/data
    ports:
      - 30200:80
      - 30201:443
    restart: always # on-failure:3 or unless-stopped default "no"
  ## drone end
```

## source repo

[https://github.com/sinlov/docker-drone-server](https://github.com/sinlov/docker-drone-server)

- maintain version start at drone 2.14.0

## todo-list

- rename `sinlov/docker-drone-server` to new github url
- rename `sinlov` to new org or user
- rename `docker-drone-server` to new docker image name
- add [secrets](https://github.com/sinlov/docker-drone-server/settings/secrets/actions) `New repository secret` name `ACCESS_TOKEN` from [hub.docker](https://hub.docker.com/settings/security)

## fast dev

```bash
# then test build as test/Dockerfile
$ make dockerTestRestartLatest
# clean test build
$ make dockerTestPruneLatest
```
