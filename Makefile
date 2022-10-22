.PHONY: test check clean dist

TOP_DIR := $(shell pwd)

ENV_DIST_VERSION=latest

ROOT_BUILD_OS := alpine

ROOT_BUILD_FOLDER ?= build
ROOT_BUILD_PATH ?= ./${ROOT_BUILD_FOLDER}
ROOT_SCRIPT_FOLDER ?= dist
ROOT_LOG_PATH ?= ./log
ROOT_DIST ?= ./out

INFO_TEST_BUILD_PATH ?= test
INFO_TEST_BUILD_DOCKER_FILE ?= Dockerfile
INFO_TEST_BUILD_PARENT_IMAGE ?= golang:1.16.0-alpine3.13
INFO_TEST_BUILD_PARENT_CONTAINNER ?= test-parent-docker-drone-server
INFO_TEST_TAG_BUILD_IMAGE_NAME ?= sinlov/docker-drone-server
INFO_TEST_TAG_BUILD_CONTAINER_NAME ?= test-docker-drone-server

env:
	@echo "====== show build evn start" =====
	@echo ""
	@echo "ROOT_BUILD_OS                  ${ROOT_BUILD_OS}"
	@echo "ROOT_BUILD_FOLDER              ${ROOT_BUILD_FOLDER}"
	@echo "ROOT_BUILD_PATH                ${ROOT_BUILD_PATH}"
	@echo "ROOT_SCRIPT_FOLDER             ${ROOT_SCRIPT_FOLDER}"
	@echo "ROOT_LOG_PATH                  ${ROOT_LOG_PATH}"
	@echo "ROOT_DIST                      ${ROOT_DIST}"
	@echo ""
	@echo "INFO_TEST_BUILD_PARENT_IMAGE        ${INFO_TEST_BUILD_PARENT_IMAGE}"
	@echo "INFO_TEST_BUILD_PARENT_CONTAINNER   ${INFO_TEST_BUILD_PARENT_CONTAINNER}"
	@echo ""
	@echo "INFO_TEST_TAG_BUILD_IMAGE_NAME      ${INFO_TEST_TAG_BUILD_IMAGE_NAME}"
	@echo "INFO_TEST_TAG_BUILD_CONTAINER_NAME  ${INFO_TEST_TAG_BUILD_CONTAINER_NAME}"
	@echo ""
	@echo "====== show build evn en" =====


checkBuildPath:
	@if [ ! -d ${ROOT_BUILD_PATH} ]; then \
	mkdir -p ${ROOT_BUILD_PATH} && echo "~> mkdir ${ROOT_BUILD_PATH}"; \
	fi

checkDistPath:
	@if [ ! -d ${ROOT_DIST} ]; then \
	mkdir -p ${ROOT_DIST} && echo "~> mkdir ${ROOT_DIST}"; \
	fi

cleanBuild:
	@if [ -d ${ROOT_BUILD_PATH} ]; then \
	rm -rf ${ROOT_BUILD_PATH} && echo "~> cleaned ${ROOT_BUILD_PATH}"; \
	else \
	echo "~> has cleaned ${ROOT_BUILD_PATH}"; \
	fi

cleanLog:
	@if [ -d ${ROOT_LOG_PATH} ]; then \
	rm -rf ${ROOT_LOG_PATH} && echo "~> cleaned ${ROOT_LOG_PATH}"; \
	else \
	echo "~> has cleaned ${ROOT_LOG_PATH}"; \
	fi

cleanDist:
	@if [ -d ${ROOT_DIST} ]; then \
	rm -rf ${ROOT_DIST} && echo "~> cleaned ${ROOT_DIST}"; \
	else \
	echo "~> has cleaned ${ROOT_DIST}"; \
	fi

cleanAll: cleanBuild cleanDist cleanLog
	@echo "clean all finish"

dockerCleanImages:
	(while :; do echo 'y'; sleep 3; done) | docker image prune

dockerPruneAll:
	(while :; do echo 'y'; sleep 3; done) | docker container prune
	(while :; do echo 'y'; sleep 3; done) | docker image prune

clean: cleanBuild cleanLog
	@echo "~> clean finish"

runContainerParentBuild:
	@echo "run rm container image: ${INFO_TEST_BUILD_PARENT_IMAGE}"
	# docker run -d --rm --name ${INFO_TEST_BUILD_PARENT_CONTAINNER} ${INFO_TEST_BUILD_PARENT_IMAGE}
	docker run -d --rm --name ${INFO_TEST_BUILD_PARENT_CONTAINNER} ${INFO_TEST_BUILD_PARENT_IMAGE} tail -f /dev/null
	@echo ""
	@echo "-> run rm container name: ${INFO_TEST_BUILD_PARENT_CONTAINNER}"
	@echo "-> into container use: docker exec -it ${INFO_TEST_BUILD_PARENT_CONTAINNER} sh"

rmContainerParentBuild:
	-docker rm -f ${INFO_TEST_BUILD_PARENT_CONTAINNER}

pruneContainerParentBuild: rmContainerToTestBuild
	-docker rmi -f ${INFO_TEST_BUILD_PARENT_IMAGE}

testBuildLatest:
	cd ${INFO_TEST_BUILD_PATH} && \
	docker build --tag ${INFO_TEST_TAG_BUILD_IMAGE_NAME}:${ENV_DIST_VERSION} --file ${INFO_TEST_BUILD_DOCKER_FILE} .

testRunLatest:
	docker image inspect --format='{{ .Created}}' ${INFO_TEST_TAG_BUILD_IMAGE_NAME}:${ENV_DIST_VERSION}
	-docker run --rm --name ${INFO_TEST_TAG_BUILD_CONTAINER_NAME} ${INFO_TEST_TAG_BUILD_IMAGE_NAME}:${ENV_DIST_VERSION}
	# for inner check can use like this
	# docker run -it -d --entrypoint /bin/sh --name ${INFO_TEST_TAG_BUILD_CONTAINER_NAME} ${INFO_TEST_TAG_BUILD_IMAGE_NAME}:${ENV_DIST_VERSION}
	-docker inspect --format='{{ .State.Status}}' ${INFO_TEST_TAG_BUILD_CONTAINER_NAME}

testLogLatest:
	-docker logs ${INFO_TEST_TAG_BUILD_CONTAINER_NAME}

testRmLatest:
	-docker rm -f ${INFO_TEST_TAG_BUILD_CONTAINER_NAME}

testRmiLatest:
	-INFO_TEST_TAG_BUILD_CONTAINER_NAME=$(INFO_TEST_TAG_BUILD_CONTAINER_NAME) \
	INFO_TEST_TAG_BUILD_IMAGE_NAME=$(INFO_TEST_TAG_BUILD_IMAGE_NAME) \
	ROOT_DOCKER_IMAGE_TAG=$(ENV_DIST_VERSION) \
	ENV_DIST_VERSION=${ENV_DIST_VERSION} \
	docker rmi -f ${INFO_TEST_TAG_BUILD_IMAGE_NAME}:${ENV_DIST_VERSION}

testRestartLatest: testRmLatest testRmiLatest testBuildLatest testRunLatest
	@echo "restrat ${INFO_TEST_TAG_BUILD_CONTAINER_NAME} ${INFO_TEST_TAG_BUILD_IMAGE_NAME}:${ENV_DIST_VERSION}"

testStopLatest: testRmLatest testRmiLatest
	@echo "stop and remove ${INFO_TEST_TAG_BUILD_CONTAINER_NAME} ${INFO_TEST_TAG_BUILD_IMAGE_NAME}:${ENV_DIST_VERSION}"

testPruneLatest: testStopLatest
	@echo "prune and remove ${INFO_TEST_TAG_BUILD_IMAGE_NAME}:${ENV_DIST_VERSION}"

help:
	@echo "Before run this project in docker must check docker and network"
	@echo ""
	@echo "make clean - remove binary file and log files"
	@echo ""
	@echo "local test build use"
	@echo "make testStopLatest    ~> remove $(INFO_TEST_TAG_BUILD_IMAGE_NAME):$(ENV_DIST_VERSION)"
	@echo "make testRestartLatest ~> re build at test ${INFO_TEST_TAG_BUILD_IMAGE_NAME}:${ENV_DIST_VERSION}"