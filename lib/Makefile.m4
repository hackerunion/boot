include(`config.m4')

root = _LOCAL_ROOT
boot = _LOCAL_ROOT`/boot'
bin = _LOCAL_ROOT`/boot/bin'
lib = _LOCAL_ROOT`/boot/lib'
build = _LOCAL_ROOT`/boot/build'
src = _LOCAL_ROOT`/usr/src/kernel'

use-these-targets-to-manage-your-server: info;
info: ; cat $(boot)/Makefile | grep '^[a-z-]*:' | cut -d':' -f1

make: $(lib)/config.m4 $(lib)/Makefile.m4 ; m4 -I $(lib) $(lib)/Makefile.m4 > Makefile

dockerfile: $(lib)/config.m4 $(lib)/Dockerfile.m4 ; m4 -I $(lib) $(lib)/Dockerfile.m4 > Dockerfile
node: $(src)/package.json ; cp $(src)/package.json $(build)/package.json

user: ; $(bin)/mkuser _SERVER_USERNAME _SERVER_UID _SERVER_SECRET _LOCAL_ROOT
user-with-push: user ; { cd $(root); git add etc/passwd.json; git commit -m 'Added server credentials'; git push; }

boot2docker: ; boot2docker up; $(shell boot2docker shellinit)

docker-build: dockerfile node user; docker build --rm -t _DOCKER_IMAGE .
docker-build-no-cache: dockerfile node user; docker build --no-cache=true --rm -t _DOCKER_IMAGE .

docker-run: docker-build docker-run-no-build ; 
docker-run-no-build: ; docker rm _DOCKER_CONTAINER 2> /dev/null ; docker run --rm -ti -v _LOCAL_ROOT:_SERVER_ROOT -p _LOCAL_PORT:_SERVICE_PORT --name _DOCKER_CONTAINER _DOCKER_IMAGE bash

install: ; $(bin)/install _HOST_USER`@'_HOST_ADDR _PUBLIC_KEY _PRIVATE_KEY _HOST_REPOSITORY _HOST_HOME
install-clean: ; $(bin)/install _HOST_USER`@'_HOST_ADDR _PUBLIC_KEY _PRIVATE_KEY _HOST_REPOSITORY _HOST_HOME yes

connect: ; ssh -i _PRIVATE_KEY _HOST_USER`@'_HOST_ADDR
local: build; echo "TODO"
clean: ; rm $(build)/*
