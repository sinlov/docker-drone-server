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

- `DRONE_SERVER_HOST` use `ip:port` or host

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

## source repo

[https://github.com/sinlov/docker-drone-server](https://github.com/sinlov/docker-drone-server)


## todo-list

- rename `sinlov/docker-drone-server` to new github url
- rename `sinlov` to new org or user
- rename `docker-drone-server` to new docker image name
- add [secrets](https://github.com/sinlov/docker-drone-server/settings/secrets/actions) `New repository secret` name `ACCESS_TOKEN` from [hub.docker](https://hub.docker.com/settings/security)

## fast dev

```bash
$ make runContainerParentBuild

# then test build as test/Dockerfile
$ make testRestartLatest
# clean test build
$ make testPruneLatest
```

- just online use Dockerfile