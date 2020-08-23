ARG VERSION=1.4.5
ARG CUDA_VERSION=10.2

FROM nvidia/cuda:${CUDA_VERSION}-cudnn7-devel-ubuntu18.04 as build
WORKDIR /opt
RUN apt-get update && apt-get install -y --no-install-recommends \
        wget ca-certificates g++ build-essential libssl-dev \
        zlib1g-dev libzip-dev libboost-filesystem-dev \
        libgoogle-perftools-dev

ARG CMAKE_VERSION=3.18.1
RUN wget -q https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz && \
    tar xf cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz

ARG VERSION
RUN wget -q https://github.com/lightvector/KataGo/archive/v${VERSION}.tar.gz && \
    tar xf v${VERSION}.tar.gz && \
    cd KataGo-$VERSION/cpp && \
    /opt/cmake-3.18.1-Linux-x86_64/bin/cmake . -DUSE_BACKEND=CUDA -DNO_GIT_REVISION=1 && \
    make

FROM gcr.io/distroless/cc-debian10
ARG VERSION

COPY --from=build \
    /lib/x86_64-linux-gnu/libc.so.6 \
	/lib/x86_64-linux-gnu/libdl.so.2 \
	/lib/x86_64-linux-gnu/libgcc_s.so.1 \
	/lib/x86_64-linux-gnu/libm.so.6 \
	/lib/x86_64-linux-gnu/libpthread.so.0 \
	/lib/x86_64-linux-gnu/librt.so.1 \
	/lib/x86_64-linux-gnu/libz.so.1 \
	/lib/x86_64-linux-gnu/
COPY --from=build \
	/lib64/ld-linux-x86-64.so.2 \
	/lib64/
COPY --from=build \
    /usr/lib/x86_64-linux-gnu/libboost_filesystem.so.1.65.1 \
	/usr/lib/x86_64-linux-gnu/libboost_system.so.1.65.1 \
	/usr/lib/x86_64-linux-gnu/libcublasLt.so.10 \
    /usr/lib/x86_64-linux-gnu/libcudnn.so.7 \
	/usr/lib/x86_64-linux-gnu/libcublas.so.10 \
	/usr/lib/x86_64-linux-gnu/libstdc++.so.6 \
	/usr/lib/x86_64-linux-gnu/libzip.so.4 \
	/usr/lib/x86_64-linux-gnu/

COPY --from=build \
    /opt/KataGo-$VERSION/cpp/katago \
    /

ENTRYPOINT ["/katago"]
