checkBuildPath:
	@if [ ! -d ${ROOT_BUILD_PATH} ]; then \
	mkdir -p ${ROOT_BUILD_PATH} && echo "~> mkdir ${ROOT_BUILD_PATH}"; \
	fi

checkDistPath:
	@if [ ! -d ${ROOT_DIST_PATH} ]; then \
	mkdir -p ${ROOT_DIST_PATH} && echo "~> mkdir ${ROOT_DIST_PATH}"; \
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
	@if [ -d ${ROOT_DIST_PATH} ]; then \
	rm -rf ${ROOT_DIST_PATH} && echo "~> cleaned ${ROOT_DIST_PATH}"; \
	else \
	echo "~> has cleaned ${ROOT_DIST_PATH}"; \
	fi

clean: cleanBuild cleanLog
	@echo "~> clean finish"

cleanAll: cleanBuild cleanDist cleanLog
	@echo "clean all finish"