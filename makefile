VERSION_TAG=0.29-rc
LC0_VERSION=0.29.0-rc0
TAG_SUFFIX=
PULL=true
DOCKERHUB_BASE=docker.io/simske/lc0
GHCR_BASE=ghcr.io/simske/lc0

ifeq "$(PULL)" "true"
PULL_FLAG=--pull
else
PULL_FLAG=
endif

default: lc0 stockfish

lc0:
	docker build $(PULL_FLAG) --build-arg LC0_VERSION=${LC0_VERSION} \
		-t ${DOCKERHUB_BASE}:${VERSION_TAG}${TAG_SUFFIX} \
		-t ${DOCKERHUB_BASE}:${LC0_VERSION}${TAG_SUFFIX} \
		-t ${GHCR_BASE}:${VERSION_TAG}${TAG_SUFFIX} \
		-t ${GHCR_BASE}:${LC0_VERSION}${TAG_SUFFIX} \
		--target=lc0 .


stockfish:
	docker build $(PULL_FLAG) --build-arg LC0_VERSION=${LC0_VERSION} \
		-t ${DOCKERHUB_BASE}:${VERSION_TAG}-stockfish${TAG_SUFFIX} \
		-t ${DOCKERHUB_BASE}:${LC0_VERSION}-stockfish${TAG_SUFFIX} \
		-t ${GHCR_BASE}-stockfish:${VERSION_TAG}${TAG_SUFFIX} \
		-t ${GHCR_BASE}-stockfish:${LC0_VERSION}${TAG_SUFFIX} \
		--target=stockfish .

tag-latest-lc0: lc0
	docker tag ${GHCR_BASE}:${LC0_VERSION}${TAG_SUFFIX} ${DOCKERHUB_BASE}:latest${TAG_SUFFIX}
	docker tag ${GHCR_BASE}:${LC0_VERSION}${TAG_SUFFIX} ${GHCR_BASE}:latest${TAG_SUFFIX}

tag-latest-stockfish: stockfish
	docker tag ${GHCR_BASE}-stockfish:${LC0_VERSION}${TAG_SUFFIX} ${DOCKERHUB_BASE}:latest-stockfish${TAG_SUFFIX}
	docker tag ${GHCR_BASE}-stockfish:${LC0_VERSION}${TAG_SUFFIX} ${GHCR_BASE}-stockfish:latest${TAG_SUFFIX}

tag-latest: tag-latest-lc0 tag-latest-stockfish

push-lc0: lc0
	docker push ${DOCKERHUB_BASE}:${VERSION_TAG}${TAG_SUFFIX}
	docker push ${DOCKERHUB_BASE}:${LC0_VERSION}${TAG_SUFFIX}
	docker push ${GHCR_BASE}:${VERSION_TAG}${TAG_SUFFIX}
	docker push ${GHCR_BASE}:${LC0_VERSION}${TAG_SUFFIX}

push-stockfish: stockfish
	docker push ${DOCKERHUB_BASE}:${VERSION_TAG}-stockfish${TAG_SUFFIX}
	docker push ${DOCKERHUB_BASE}:${LC0_VERSION}-stockfish${TAG_SUFFIX}
	docker push ${GHCR_BASE}-stockfish:${VERSION_TAG}${TAG_SUFFIX}
	docker push ${GHCR_BASE}-stockfish:${LC0_VERSION}${TAG_SUFFIX}

push: push-lc0 push-stockfish

push-latest-lc0: tag-latest-lc0 push-lc0
	docker push ${DOCKERHUB_BASE}:latest${TAG_SUFFIX}
	docker push ${GHCR_BASE}:latest${TAG_SUFFIX}

push-latest-stockfish: tag-latest-stockfish push-stockfish
	docker push ${DOCKERHUB_BASE}:latest-stockfish${TAG_SUFFIX}
	docker push ${GHCR_BASE}-stockfish:latest${TAG_SUFFIX}

push-latest: push-latest-lc0 push-latest-stockfish
