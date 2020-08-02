ARG CUDA_VERSION=11.0

FROM nvidia/cuda:${CUDA_VERSION}-cudnn7-devel-ubuntu20.04 as build
WORKDIR /opt
RUN apt-get update && apt-get install -y --no-install-recommends \
        wget ca-certificates g++ build-essential libssl-dev \
        zlib1g-dev libzip-dev libboost-filesystem-dev \
        libgoogle-perftools-dev

ARG VERSION=1.4.5
ENV LD_LIBRARY_PATH /usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
RUN wget -q https://github.com/lightvector/KataGo/archive/v${VERSION}.tar.gz && \
    tar xf v${VERSION}.tar.gz && \
    cd KataGo-$VERSION/cpp && \
    cmake . -DUSE_BACKEND=CUDA -DNO_GIT_REVISION=1 && \
    make

FROM nvidia/cuda:${CUDA_VERSION}-cudnn7-runtime-ubuntu18.04
WORKDIR /opt
ARG VERSION=1.4.5
COPY --from=build /opt/KataGo-$VERSION/cpp/katago /opt/katago

RUN apt-get update && apt-get install -y --no-install-recommends \
        wget libzip-dev libboost-filesystem-dev \
        libgoogle-perftools-dev && \
    rm -rf /var/lib/apt/lists/*

ARG SOURCE_URL=https://github.com/lightvector/KataGo/releases/download/v${VERSION}
RUN wget -q -O 30block.bin.gz $SOURCE_URL/g170-b30c320x2-s4824661760-d1229536699.bin.gz && \
    wget -q -O 40block.bin.gz $SOURCE_URL/g170-b40c256x2-s5095420928-d1229425124.bin.gz && \
    wget -q -O 20block.bin.gz $SOURCE_URL/g170e-b20c256x2-s5303129600-d1228401921.bin.gz

ENV PATH /opt:$PATH

ENTRYPOINT ["katago"]
