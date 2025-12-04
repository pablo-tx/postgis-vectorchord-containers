ARG BASE=ghcr.io/cloudnative-pg/postgresql:17-standard-trixie
FROM $BASE

ARG PG_MAJOR
ARG POSTGIS_VERSION
ARG POSTGIS_MAJOR
ARG VECTORCHORD_TAG
ARG TARGETARCH

USER root

ADD https://github.com/tensorchord/VectorChord/releases/download/$VECTORCHORD_TAG/postgresql-${PG_MAJOR}-vchord_${VECTORCHORD_TAG#"v"}-1_$TARGETARCH.deb /tmp/vchord.deb

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        "postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION" \
        "postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts" && \
        apt-get install -y /tmp/vchord.deb && \
        rm -rf /var/lib/apt/lists/* && \
        rm -rf /var/cache/* && \
        apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
        rm -rf /var/log/* && \
        rm -f /tmp/vchord.deb

USER 26
