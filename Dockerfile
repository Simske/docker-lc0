FROM nvidia/cuda:10.1-cudnn7-devel

# install prerequisites
RUN apt-get update && apt-get dist-upgrade -y && apt clean all
RUN apt-get update && apt-get install -y curl wget supervisor git clang-6.0 ninja-build protobuf-compiler libprotobuf-dev python3-pip && apt-get clean all
RUN pip3 install meson

# download and compile lc0
RUN     cd ~ && \
        git clone -b release/0.22 --recurse-submodules https://github.com/LeelaChessZero/lc0.git lc0 && \
        ./lc0/build.sh

RUN     mkdir /lc0 && \
        ln -s /root/lc0/build/release/lc0 /lc0/lc0

# download network
#RUN     cd /lczero && \
#        wget https://lczero.org/get_network?sha=03c8b3db4fded51bb92584a3e98a2cb4dc402ba037b9534ed1a8af99eb350f1a

