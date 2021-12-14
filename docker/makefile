VERSION_TAG=0.28
LC0_VERSION=0.28.2
PULL=true
DOCKERHUB_BASE=docker.io/simske/lc0
GHCR_BASE=ghcr.io/simske/lc0

default: lc0 stockfish

lc0:
	docker build --build-arg LC0_VERSION=${LC0_VERSION} \
		-t ${DOCKERHUB_BASE}:${VERSION_TAG} \
		-t ${DOCKERHUB_BASE}:${LC0_VERSION} \
		-t ${GHCR_BASE}:${VERSION_TAG} \
		-t ${GHCR_BASE}:${LC0_VERSION} \
		--target=lc0 .


stockfish:
	docker build --build-arg LC0_VERSION=${LC0_VERSION} \
		-t ${DOCKERHUB_BASE}:${VERSION_TAG}-stockfish \
		-t ${DOCKERHUB_BASE}:${LC0_VERSION}-stockfish \
		-t ${GHCR_BASE}-stockfish:${VERSION_TAG} \
		-t ${GHCR_BASE}-stockfish:${LC0_VERSION} \
		--target=stockfish .

tag-latest-lc0: lc0
	docker tag ${GHCR_BASE}:${LC0_VERSION} ${DOCKERHUB_BASE}:latest
	docker tag ${GHCR_BASE}:${LC0_VERSION} ${GHCR_BASE}:latest

tag-latest-stockfish: stockfish
	docker tag ${GHCR_BASE}-stockfish:${LC0_VERSION} ${DOCKERHUB_BASE}:latest-stockfish
	docker tag ${GHCR_BASE}-stockfish:${LC0_VERSION} ${GHCR_BASE}-stockfish:latest

tag-latest: tag-latest-lc0 tag-latest-stockfish

push-lc0: lc0
	docker push ${DOCKERHUB_BASE}:${VERSION_TAG}
	docker push ${DOCKERHUB_BASE}:${LC0_VERSION}
	docker push ${GHCR_BASE}:${VERSION_TAG}
	docker push ${GHCR_BASE}:${LC0_VERSION}

push-stockfish: stockfish
	docker push ${DOCKERHUB_BASE}:${VERSION_TAG}-stockfish
	docker push ${DOCKERHUB_BASE}:${LC0_VERSION}-stockfish
	docker push ${GHCR_BASE}-stockfish:${VERSION_TAG}
	docker push ${GHCR_BASE}-stockfish:${LC0_VERSION}

push: push-lc0 push-stockfish

push-latest-lc0: tag-latest-lc0 push-lc0
	docker push ${DOCKERHUB_BASE}:latest
	docker push ${GHCR_BASE}:latest

push-latest-stockfish: tag-latest-stockfish push-stockfish
	docker push ${DOCKERHUB_BASE}:latest-stockfish
	docker push ${GHCR_BASE}-stockfish:latest

push-latest: push-latest-lc0 push-latest-stockfish
