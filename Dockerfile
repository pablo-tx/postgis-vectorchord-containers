ARG BASE=ghcr.io/cloudnative-pg/postgresql:17-standard-trixie
FROM $BASE

ARG PG_MAJOR
ARG POSTGIS_VERSION
ARG POSTGIS_MAJOR
ARG VECTORCHORD_TAG
ARG TARGETARCH

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        "postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION" \
        "postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts"
    

# Install VectorChord extension
ADD https://github.com/tensorchord/VectorChord/releases/download/$VECTORCHORD_TAG/postgresql-${PG_MAJOR}-vchord_${VECTORCHORD_TAG#"v"}-1_$TARGETARCH.deb /tmp/vchord.deb
RUN apt-get install -y /tmp/vchord.deb && \
    rm -f /tmp/vchord.deb && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/* /var/cache/* /var/log/*

USER 26
