ARG PG_MAJOR=15  # as of right now, only version 15 is found on s390x dev packages
ARG CLANG_MAJOR=19

FROM --platform=linux/s390x postgres:$PG_MAJOR
ARG PG_MAJOR
ARG CLANG_MAJOR

COPY . /tmp/pgvector

RUN apt-get update \
    && apt-mark hold locales

RUN # fixes some dependency conflicts               \
    apt install -y --allow-downgrades               \
        libpq5=15.13-0+deb12u1                      \
        libpq-dev=15.13-0+deb12u1                   \
    # necessary for pgvector build                  \
    && apt-get install -y clang-19                  \
    && apt-get install -y --no-install-recommends   \
        build-essential                             \
        postgresql-server-dev-$PG_MAJOR             \
    && cd /tmp/pgvector                             \
    && make clean                                   \
    && make OPTFLAGS=""                             \
    && make install                                 \
    && mkdir /usr/share/doc/pgvector                \
    && cp LICENSE README.md /usr/share/doc/pgvector

RUN rm -r /tmp/pgvector

RUN apt-get remove -y                   \
        clang-19                        \
        build-essential                 \
        postgresql-server-dev-$PG_MAJOR \
    && apt-get autoremove -y            \
    && apt-mark unhold locales          \
    && rm -rf /var/lib/apt/lists/*

