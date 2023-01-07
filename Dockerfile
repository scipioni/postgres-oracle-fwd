ARG base_tag=14.4
FROM postgres:${base_tag}

# Latest version
ARG ORACLE_CLIENT_URL=https://download.oracle.com/otn_software/linux/instantclient/instantclient-basic-linuxx64.zip
ARG ORACLE_SQLPLUS_URL=https://download.oracle.com/otn_software/linux/instantclient/instantclient-sqlplus-linuxx64.zip
ARG ORACLE_SDK_URL=https://download.oracle.com/otn_software/linux/instantclient/instantclient-sdk-linuxx64.zip

# Version specific setup
#ARG ORACLE_CLIENT_VERSION=18.5.0.0.0
#ARG ORACLE_CLIENT_PATH=185000
ARG ORACLE_CLIENT_VERSION=19.8.0.0.0
ARG ORACLE_CLIENT_PATH=19800
ARG ORACLE_CLIENT_URL=https://download.oracle.com/otn_software/linux/instantclient/${ORACLE_CLIENT_PATH}/instantclient-basic-linux.x64-${ORACLE_CLIENT_VERSION}dbru.zip
ARG ORACLE_SQLPLUS_URL=https://download.oracle.com/otn_software/linux/instantclient/${ORACLE_CLIENT_PATH}/instantclient-sqlplus-linux.x64-${ORACLE_CLIENT_VERSION}dbru.zip
ARG ORACLE_SDK_URL=https://download.oracle.com/otn_software/linux/instantclient/${ORACLE_CLIENT_PATH}/instantclient-sdk-linux.x64-${ORACLE_CLIENT_VERSION}dbru.zip

ENV ORACLE_HOME=/usr/lib/oracle/client

RUN apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates wget unzip; \
    # instant client
    wget -O instant_client.zip ${ORACLE_CLIENT_URL}; \
    unzip instant_client.zip; \
    # sqlplus
    wget -O sqlplus.zip ${ORACLE_SQLPLUS_URL}; \
    unzip sqlplus.zip; \
    # sdk
    wget -O sdk.zip ${ORACLE_SDK_URL}; \
    unzip sdk.zip; \
    # install
    mkdir -p ${ORACLE_HOME}; \
    mv instantclient*/* ${ORACLE_HOME}; \
    rm -r instantclient*; \
    rm instant_client.zip sqlplus.zip sdk.zip; \
    # required runtime libs: libaio
    apt-get install -y --no-install-recommends libaio1; \
    apt-get purge -y --auto-remove

ENV PATH $PATH:${ORACLE_HOME}


ARG ORACLE_FDW_VERSION=2_4_0
ARG ORACLE_FDW_URL=https://github.com/laurenz/oracle_fdw/archive/ORACLE_FDW_${ORACLE_FDW_VERSION}.tar.gz
ARG SOURCE_FILES=tmp/oracle_fdw

    # oracle_fdw
RUN mkdir -p ${SOURCE_FILES}; \
    wget -O - ${ORACLE_FDW_URL} | tar -zx --strip-components=1 -C ${SOURCE_FILES}; \
    cd ${SOURCE_FILES}; \
    # install
    apt-get install -y --no-install-recommends make gcc postgresql-server-dev-14; \
    make; \
    make install; \
    echo ${ORACLE_HOME} > /etc/ld.so.conf.d/oracle_instantclient.conf; \
    ldconfig; \
    # cleanup
    apt-get purge -y --auto-remove postgresql-server-dev-14 gcc make
