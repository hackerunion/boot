include(`config.m4')
include(`common.m4')

FROM node:0.12
USER root

# TODO: figure out how to properly avoid release file expiration (based on old image?)
RUN apt-get -o Acquire::Check-Valid-Until=false update && apt-get install -y \
    sudo \
    rsync \
    rsyslog \
    nano \
    busybox \
    jq \
    cron ifelse(_SERVER_SSH_PORT, `', `', ` \
    openssh-server') ifdef(`_SERVER_EDITOR', ` \
    _SERVER_EDITOR')

# manually start syslog and cron (to ensure files are present for later)
RUN service rsyslog start
RUN service cron start

# cron runs into a permissions issue; this avoids the problem (file only exists after cron start)
RUN sed -i '/session\s*required\s*pam_loginuid.so/c\#session required pam_loginuid.so' /etc/pam.d/cron

ENV PATH=$PATH:_SERVER_ROOT`/bin' \
    SERVER_ROOT=_SERVER_ROOT \
    SERVER_PORT=_SERVER_PORT \
    SERVER_SECURE_PORT=_SERVER_SECURE_PORT \
    SERVER_USERNAME=_SERVER_USERNAME \
    SERVER_UID=_SERVER_UID \
    SERVER_URI=_SERVER_URI \
    SERVER_SECRET=_SERVER_SECRET \
    SERVER_SECRET_ROTATE=_SERVER_SECRET_ROTATE \
    SERVER_GUEST_USERNAME=_SERVER_GUEST_USERNAME \
    SERVER_GUEST_UID=_SERVER_GUEST_UID \
    SERVER_GUEST_SECRET=_SERVER_GUEST_SECRET \
    SERVER_COOKIE_SECRET=_SERVER_COOKIE_SECRET \
    SERVER_SECURE_KEY=_SERVER_SECURE_KEY \
    SERVER_SECURE_CERT=_SERVER_SECURE_CERT \
    SERVER_SSH_PORT=_SERVER_SSH_PORT \
    SERVER_CGI_TIMEOUT=_SERVER_CGI_TIMEOUT \
    SERVER_BODY_LIMIT=_SERVER_BODY_LIMIT \
    SHELL_URI=_SHELL_URI \
    HOST_UID=_THIS_UID \
    HOST_GID=_THIS_GID \
    HOST_SSH_PORT=_HOST_SSH_PORT \
    NODE_PATH=/usr/local/lib/node_modules/kernel/node_modules:/usr/local/lib/node_modules

ADD ./build/package.json /tmp/package.json
RUN cd /tmp && npm install -g

ADD ./build/key.pem _SERVER_SECURE_KEY
ADD ./build/cert.pem _SERVER_SECURE_CERT

VOLUME _SERVER_ROOT
WORKDIR _SERVER_ROOT

EXPOSE _SERVER_PORT _SERVER_SECURE_PORT ifelse(_SERVER_SSH_PORT, `', `', `_SERVER_SSH_PORT')
