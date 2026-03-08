FROM debian:bookworm-slim AS base

ARG LUAROCKS_VERSION=3.13.0
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        cracklib-runtime \
        cmake \
        pkg-config \
        cppcheck \
        libpwquality-dev \
        lua5.4 \
        liblua5.4-dev \
        curl \
        ca-certificates \
        tar \
        libreadline-dev \
        unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -O "https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz" \
    && tar -xzf "luarocks-${LUAROCKS_VERSION}.tar.gz" \
    && cd "luarocks-${LUAROCKS_VERSION}" \
    && ./configure && make && make install \
    && luarocks install busted \
    && luarocks install luacheck \
    && rm -rf "luarocks-${LUAROCKS_VERSION}.tar.gz" "luarocks-${LUAROCKS_VERSION}"

WORKDIR /workspace

FROM base AS test

COPY . /workspace

RUN cmake -S . -B build \
    && cmake --build build \
    && ctest --test-dir build --output-on-failure
