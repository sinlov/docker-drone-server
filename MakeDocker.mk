INFO_BUILD_DOCKER_TAG = ${ENV_DIST_VERSION}
# INFO_BUILD_DOCKER_TAG = latest
INFO_BUILD_DOCKER_IMAGE_NAME ?= sinlov/docker-drone-server
INFO_BUILD_DOCKER_FILE = Dockerfile
INFO_BUILD_FROM_IMAGE ?= alpine:3.13

INFO_TEST_BUILD_DOCKER_FILE ?= Dockerfile.s6
INFO_TEST_BUILD_PARENT_IMAGE ?= golang:1.16.0-alpine3.13
INFO_TEST_BUILD_PARENT_CONTAINER ?= test-parent-docker-drone-server
INFO_TEST_TAG_BUILD_CONTAINER_NAME ?= test-docker-drone-server

dockerEnv:
	@echo "====== docker env print start"
	@echo "INFO_BUILD_DOCKER_IMAGE_NAME        ${INFO_BUILD_DOCKER_IMAGE_NAME}"
	@echo "INFO_BUILD_DOCKER_TAG               ${INFO_BUILD_DOCKER_TAG}"
	@echo "INFO_BUILD_DOCKER_FILE              ${INFO_BUILD_DOCKER_FILE}"
	@echo "INFO_BUILD_FROM_IMAGE               ${INFO_BUILD_FROM_IMAGE}"
	@echo ""
	@echo "INFO_TEST_BUILD_PARENT_IMAGE        ${INFO_TEST_BUILD_PARENT_IMAGE}"
	@echo "INFO_TEST_BUILD_PARENT_CONTAINER    ${INFO_TEST_BUILD_PARENT_CONTAINER}"
	@echo ""
	@echo "INFO_TEST_TAG_BUILD_CONTAINER_NAME  ${INFO_TEST_TAG_BUILD_CONTAINER_NAME}"
	@echo ""
	@echo "====== docker env print end"

dockerCleanImages:
	(while :; do echo 'y'; sleep 3; done) | docker image prune

dockerPruneAll:
	(while :; do echo 'y'; sleep 3; done) | docker container prune
	(while :; do echo 'y'; sleep 3; done) | docker image prune

dockerAllPull:
	docker pull ${INFO_BUILD_FROM_IMAGE}
	docker pull ${INFO_TEST_BUILD_PARENT_IMAGE}

dockerRunContainerParentBuild:
	@echo "run rm container image: ${INFO_TEST_BUILD_PARENT_IMAGE}"
	# docker run -d --rm --name ${INFO_TEST_BUILD_PARENT_CONTAINER} ${INFO_TEST_BUILD_PARENT_IMAGE}
	docker run -d --rm --name ${INFO_TEST_BUILD_PARENT_CONTAINER} ${INFO_TEST_BUILD_PARENT_IMAGE} tail -f /dev/null
	@echo ""
	@echo "-> run rm container name: ${INFO_TEST_BUILD_PARENT_CONTAINER}"
	@echo "-> into container use: docker exec -it ${INFO_TEST_BUILD_PARENT_CONTAINER} sh"

dockerRmContainerParentBuild:
	-docker rm -f ${INFO_TEST_BUILD_PARENT_CONTAINER}

dockerPruneContainerParentBuild: dockerRmContainerParentBuild
	-docker rmi -f ${INFO_TEST_BUILD_PARENT_IMAGE}

dockerTestBuildLatest:
	docker build --tag ${INFO_BUILD_DOCKER_IMAGE_NAME}:${INFO_BUILD_DOCKER_TAG} --file ${INFO_TEST_BUILD_DOCKER_FILE} .

dockerTestRunLatest:
	docker image inspect --format='{{ .Created}}' ${INFO_BUILD_DOCKER_IMAGE_NAME}:${INFO_BUILD_DOCKER_TAG}
	-docker run --rm --name ${INFO_TEST_TAG_BUILD_CONTAINER_NAME} ${INFO_BUILD_DOCKER_IMAGE_NAME}:${INFO_BUILD_DOCKER_TAG}
	# for inner check can use like this
	# docker run -it -d --entrypoint /bin/sh --name ${INFO_TEST_TAG_BUILD_CONTAINER_NAME} ${INFO_TEST_TAG_BUILD_IMAGE_NAME}:${INFO_BUILD_DOCKER_TAG}
	-docker inspect --format='{{ .State.Status}}' ${INFO_TEST_TAG_BUILD_CONTAINER_NAME}

dockerTestLogLatest:
	-docker logs ${INFO_TEST_TAG_BUILD_CONTAINER_NAME}

dockerTestRmLatest:
	-docker rm -f ${INFO_TEST_TAG_BUILD_CONTAINER_NAME}

dockerTestRmiLatest:
	-INFO_TEST_TAG_BUILD_CONTAINER_NAME=$(INFO_TEST_TAG_BUILD_CONTAINER_NAME) \
	INFO_TEST_TAG_BUILD_IMAGE_NAME=$(INFO_BUILD_DOCKER_IMAGE_NAME) \
	ROOT_DOCKER_IMAGE_TAG=$(INFO_BUILD_DOCKER_TAG) \
	INFO_BUILD_DOCKER_TAG=${INFO_BUILD_DOCKER_TAG} \
	docker rmi -f ${INFO_BUILD_DOCKER_IMAGE_NAME}:${INFO_BUILD_DOCKER_TAG}

dockerTestRestartLatest: dockerTestRmLatest dockerTestRmiLatest dockerTestBuildLatest dockerTestRunLatest
	@echo "restart ${INFO_TEST_TAG_BUILD_CONTAINER_NAME} ${INFO_BUILD_DOCKER_IMAGE_NAME}:${INFO_BUILD_DOCKER_TAG}"

dockerTestStopLatest: dockerTestRmLatest dockerTestRmiLatest
	@echo "stop and remove ${INFO_TEST_TAG_BUILD_CONTAINER_NAME} ${INFO_BUILD_DOCKER_IMAGE_NAME}:${INFO_BUILD_DOCKER_TAG}"

dockerTestPruneLatest: dockerTestStopLatest
	@echo "prune and remove ${INFO_BUILD_DOCKER_IMAGE_NAME}:${INFO_BUILD_DOCKER_TAG}"

dockerRmiBuild:
	-docker rmi -f ${INFO_BUILD_DOCKER_IMAGE_NAME}:${INFO_BUILD_DOCKER_TAG}

dockerBuild:
	docker build --tag ${INFO_BUILD_DOCKER_IMAGE_NAME}:${INFO_BUILD_DOCKER_TAG} --file ${INFO_BUILD_DOCKER_FILE} .

dockerPushBuild: dockerRmiBuild dockerBuild
	docker push ${INFO_BUILD_DOCKER_IMAGE_NAME}:${INFO_BUILD_DOCKER_TAG}
	@echo "=> push ${INFO_BUILD_DOCKER_IMAGE_NAME}:${INFO_BUILD_DOCKER_TAG}"

helpDocker:
	@echo "-- helper helpDocker"
	@echo ""
	@echo "make dockerTestRestartLatest    ~> remove $(INFO_BUILD_DOCKER_IMAGE_NAME):$(INFO_BUILD_DOCKER_TAG)"
	@echo "make dockerTestPruneLatest ~> re build at test ${INFO_BUILD_DOCKER_IMAGE_NAME}:${INFO_BUILD_DOCKER_TAG}"
	@echo ""