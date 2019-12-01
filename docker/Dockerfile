## Compile Stage ##
###################
FROM nvidia/cuda:10.1-cudnn7-devel as builder

## Install Prerequisites
RUN apt-get update && apt-get install -y git ninja-build protobuf-compiler libprotobuf-dev python3 python3-pip && \
    ln -s /usr/bin/python3 /usr/bin/python
RUN pip3 install meson

# download and compile lc0
RUN     cd /root && \
        git clone --depth 1 -b release/0.23 --recurse-submodules https://github.com/LeelaChessZero/lc0.git lc0
RUN     /root/lc0/build.sh

## Runtime Stage ##
###################
FROM nvidia/cuda:10.1-cudnn7-devel

# Dependencies
RUN apt-get update && apt-get install -y libprotobuf10 wget && apt-get clean
COPY --from=builder /root/lc0/build/release/./subprojects/zlib-1.2.11/libz.so /lib64/
ENV LD_LIBRARY_PATH /lib64

# Copy scripts for network download and lc0 startup
WORKDIR /lc0
COPY ./scripts/* /lc0/
RUN chmod +x /lc0/* && \
    mkdir /lc0/weights
COPY --from=builder /root/lc0/build/release/lc0 .
ENV PATH /lc0:$PATH

ENTRYPOINT ["/lc0/download_run_lc0"]
