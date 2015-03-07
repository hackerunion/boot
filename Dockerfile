FROM node:0.12
VOLUME /srv

ADD ./build/package.json /tmp/package.json
RUN cd /tmp && npm install -g

ENV PATH=/srv/bin:$PATH \
    ROOT=/srv \
    PORT=8888

EXPOSE 8888
