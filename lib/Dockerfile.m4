include(`config.m4')

FROM node:0.12
USER root

ADD ./build/package.json /tmp/package.json

# TODO: figure out how to properly avoid release file expiration (based on old image?)
RUN apt-get -o Acquire::Check-Valid-Until=false update && apt-get install -y \
    cron

RUN cd /tmp && npm install -g

ENV SERVER_ROOT=_SERVER_ROOT \
    SERVER_USERNAME=_SERVER_USERNAME \
    SERVER_UID=_SERVER_UID \
    SERVER_SECRET=_SERVER_SECRET \
    SERVICE_PORT=_SERVICE_PORT \
    SERVICE_URI=_SERVICE_URI \
    COOKIE_SECRET=_COOKIE_SECRET \
    HOST_HOME=_HOST_HOME \
    HOST_USER=_HOST_USER \
    HOST_ADDR=_HOST_ADDR \
    HOST_REPOSITORY=_HOST_REPOSITORY \
    DOCKER_CONTAINER=_DOCKER_CONTAINER \
    DOCKER_IMAGE=_DOCKER_IMAGE

VOLUME _SERVER_ROOT
WORKDIR _SERVER_ROOT

EXPOSE _SERVICE_PORT
