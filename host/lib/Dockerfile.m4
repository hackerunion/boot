include(`config.m4')
include(`common.m4')

FROM node:0.12
USER root

# TODO: figure out how to properly avoid release file expiration (based on old image?)
RUN apt-get -o Acquire::Check-Valid-Until=false update && apt-get install -y \
    rsync \
    cron ifelse(_SERVER_SSH_PORT, `', `', ` \
    openssh-server')

ENV PATH=$PATH:_SERVER_ROOT`/bin' \
    SERVER_ROOT=_SERVER_ROOT \
    SERVER_PORT=_SERVER_PORT \
    SERVER_SECURE_PORT=_SERVER_SECURE_PORT \
    SERVER_USERNAME=_SERVER_USERNAME \
    SERVER_UID=_SERVER_UID \
    SERVER_URI=_SERVER_URI \
    SERVER_SECRET=_SERVER_SECRET \
    COOKIE_SECRET=_COOKIE_SECRET \
    SERVER_SECURE_KEY=_SERVER_SECURE_KEY \
    SERVER_SECURE_CERT=_SERVER_SECURE_CERT \
    SERVER_SSH_PORT=_SERVER_SSH_PORT \
    SHELL_URI=_SHELL_URI \
    HOST_UID=_THIS_UID \
    HOST_GID=_THIS_GID \
    NODE_PATH=/usr/local/lib/node_modules/kernel/node_modules:/usr/local/lib/node_modules

ADD ./build/package.json /tmp/package.json
RUN cd /tmp && npm install -g

ADD ./build/key.pem _SERVER_SECURE_KEY
ADD ./build/cert.pem _SERVER_SECURE_CERT

VOLUME _SERVER_ROOT
WORKDIR _SERVER_ROOT

EXPOSE _SERVER_PORT _SERVER_SECURE_PORT ifelse(_SERVER_SSH_PORT, `', `', `_SERVER_SSH_PORT')
