FROM vastai/tensorflow as BUILDER

# install prerequisites
RUN apt-get update && apt-get install -y clang-6.0 ninja-build libprotobuf10
#RUN pip3 install meson
RUN pip3 install git+https://github.com/Simske/meson.git

# download and compile lc0
RUN     cd ~ && \
        git clone -b release/0.22 --recurse-submodules https://github.com/LeelaChessZero/lc0.git lc0 && \
        ./lc0/build.sh


FROM vastai/tensorflow

RUN apt-get update && apt-get install -y libprotobuf10

WORKDIR /lc0
COPY --from=0 /root/lc0/build/release/lc0 .
ENV PATH /lc0:$PATH

# download network
#RUN     cd /lczero && \
#        wget https://lczero.org/get_network?sha=03c8b3db4fded51bb92584a3e98a2cb4dc402ba037b9534ed1a8af99eb350f1a


