include(`config.m4')
include(`common.m4')

FROM node:0.12
USER root

RUN cd /tmp && npm install -g

ENV PATH=$PATH:_SERVER_ROOT`/bin' \
    SERVER_ROOT=_SERVER_ROOT \
    SERVER_PORT=_SERVER_PORT \
    SERVER_USERNAME=_SERVER_USERNAME \
    SERVER_UID=_SERVER_UID \
    SERVER_URI=_SERVER_URI \
    SERVER_SECRET=_SERVER_SECRET \
    COOKIE_SECRET=_COOKIE_SECRET 

VOLUME _SERVER_ROOT
WORKDIR _SERVER_ROOT

ADD ./build/package.json /tmp/package.json

# TODO: figure out how to properly avoid release file expiration (based on old image?)
RUN apt-get -o Acquire::Check-Valid-Until=false update && apt-get install -y \
    cron

EXPOSE _SERVER_PORT
