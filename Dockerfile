FROM debian:12 as build

RUN apt update -y && apt install -y build-essential \
        libcurl4-openssl-dev \
        liblzma-dev \
        libssl-dev \
        python-dev-is-python3 \
        python3-pip \
        lld \
        curl \
    && rm -rf /var/lib/apt/lists/*

ARG MONGO_VERSION=

RUN mkdir /src && \
    curl -o /tmp/mongo.tar.gz -L "https://github.com/mongodb/mongo/archive/refs/tags/r${MONGO_VERSION}.tar.gz" && \
    tar xaf /tmp/mongo.tar.gz --strip-components=1 -C /src && \
    rm /tmp/mongo.tar.gz

WORKDIR /src

COPY ./no_avx_patch.diff /no_avx_patch.diff
RUN patch -p0 < /no_avx_patch.diff

ARG NUM_JOBS=

RUN export GIT_PYTHON_REFRESH=quiet && \
    python3 -m pip install requirements_parser --break-system-packages && \
    python3 -m pip install -r etc/pip/compile-requirements.txt --break-system-packages && \
    if [ "${NUM_JOBS}" -gt 0 ]; then export JOBS_ARG="-j ${NUM_JOBS}"; fi && \
    python3 buildscripts/scons.py install-devcore MONGO_VERSION="${MONGO_VERSION}" --release --disable-warnings-as-errors ${JOBS_ARG} && \
    mv build/install /install && \
    strip --strip-debug /install/bin/mongod && \
    strip --strip-debug /install/bin/mongos && \
    strip --strip-debug /install/bin/mongo && \
    rm -rf build

FROM debian:12

RUN apt update -y && \
    apt install -y libcurl4 && \
    apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /install/bin/mongo* /usr/local/bin/

RUN mkdir -p /data/db && \
    chmod -R 750 /data && \
    chown -R 999:999 /data

USER 999

ENTRYPOINT [ "/usr/local/bin/mongod" ]
