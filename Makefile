.PHONY: test check clean dist

TOP_DIR := $(shell pwd)

ENV_DIST_VERSION=latest

ROOT_BUILD_FOLDER ?= build
ROOT_BUILD_PATH ?= ./${ROOT_BUILD_FOLDER}
ROOT_LOG_PATH ?= ./log
ROOT_DIST_PATH ?= ./dist

include MakeDist.mk
include MakeDocker.mk

env: dockerEnv
	@echo "====== show root build evn start" =====
	@echo ""
	@echo "ROOT_BUILD_FOLDER              ${ROOT_BUILD_FOLDER}"
	@echo "ROOT_BUILD_PATH                ${ROOT_BUILD_PATH}"
	@echo "ROOT_DIST_PATH                 ${ROOT_DIST_PATH}"
	@echo "ROOT_LOG_PATH                  ${ROOT_LOG_PATH}"
	@echo ""
	@echo "====== show root build evn en" =====


help: helpDocker
	@echo "-- helper root"
	@echo ""
	@echo "Before run this project in docker must check docker and network"
	@echo ""
	@echo "make clean - remove binary file and log files"
	@echo ""
	@echo "local test build use"
