ARG LC0_VERSION \
    LC0_ARCHITECTURE=ivybridge \
    LC0_NETWORK_NAME=752187.pb.gz \
    LC0_NETWORK_URL=https://training.lczero.org/get_network?sha=65d1d197e81e221552b0803dd3623c738887dcb132e084fbab20f93deb66a0c0
ARG STOCKFISH_URL=https://stockfishchess.org/files/stockfish_14.1_linux_x64_avx2.zip
ARG CUDA_VERSION=11.2.0-cudnn8
#################
## Compile lc0 ##
#################
FROM docker.io/nvidia/cuda:${CUDA_VERSION}-devel-ubuntu20.04 AS lc0_build
ARG LC0_VERSION LC0_ARCHITECTURE

## Install Prerequisites
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git ninja-build \
        build-essential python python3-pip \
        libeigen3-dev libopenblas-dev && \
    pip3 install meson

# download and compile lc0
RUN     git clone -b v${LC0_VERSION} --recurse-submodules https://github.com/LeelaChessZero/lc0.git /root/lc0
RUN     sed -i "s/march=native/march=${LC0_ARCHITECTURE}/g" /root/lc0/meson.build && \
        /root/lc0/build.sh

# prepare directory structure for runtime
COPY ./scripts/* /lc0/
RUN cp /root/lc0/build/release/lc0 /lc0/lc0 && \
    chmod +x /lc0/* && \
    mkdir /lc0/weights

########################
## Download stockfish ##
########################
FROM alpine:3 AS stockfish_build
ARG STOCKFISH_URL

RUN apk add --no-cache wget unzip

# download and unpack stockfish
RUN cd /root && \
    wget -4 "${STOCKFISH_URL}" -O stockfish.zip && \
    unzip stockfish.zip && \
    mkdir /stockfish && \
    mv stockfish_*/stockfish_*_x64_avx2 /stockfish/stockfish && \
    chmod +x /stockfish/stockfish


#################
## lc0 runtime ##
#################
FROM docker.io/nvidia/cuda:${CUDA_VERSION}-runtime-ubuntu20.04 AS lc0
ARG LC0_VERSION LC0_NETWORK_NAME LC0_NETWORK_URL

LABEL maintainer="Simske <mail@simske.com>"
LABEL org.opencontainers.image.url="https://github.com/Simske/docker-lc0"
LABEL org.opencontainers.image.source="https://github.com/Simske/docker-lc0"
LABEL org.opencontainers.image.license="GPL-3.0+"
LABEL lc0_version ${LC0_VERSION}

# Dependencies
RUN apt-get update && apt-get install -y wget libopenblas-base && apt-get clean

# Copy scripts for network download and lc0 startup
COPY --from=lc0_build /lc0 /lc0
WORKDIR /lc0
ENV PATH /lc0:$PATH

# Download default network
RUN echo "NETWORK_NAME='${LC0_NETWORK_NAME}'\nNETWORK_URL='${LC0_NETWORK_URL}'" > /lc0/default_network.env && \
    /lc0/download_network "${LC0_NETWORK_URL}" "${LC0_NETWORK_NAME}"

CMD ["/lc0/run_lc0"]

#############################
## lc0 runtime + stockfish ##
#############################
FROM lc0 AS stockfish
COPY --from=stockfish_build /stockfish/ /
ENV PATH /stockfish:$PATH