include(`config.m4')
include(`common.m4')

root = _THIS_ROOT
boot = $(root)/boot
bin = $(root)/boot/bin
lib = $(root)/boot/lib
build = $(root)/boot/build
src = $(root)/usr/src/kernel

use-these-targets-to-manage-your-server: info;
info: ; cat $(boot)/Makefile | grep '^[a-z-]*:' | cut -d':' -f1

make: $(lib)/config.m4 $(lib)/Makefile.m4 ; m4 -I $(lib) $(lib)/Makefile.m4 > Makefile

dockerfile: $(lib)/config.m4 $(lib)/Dockerfile.m4 ; m4 -I $(lib) $(lib)/Dockerfile.m4 > Dockerfile
node: $(src)/package.json ; cp $(src)/package.json $(build)/package.json

user: ; $(bin)/mkuser _SERVER_USERNAME _SERVER_UID _SERVER_SECRET _THIS_ROOT
user-with-push: user ; { cd $(root); git add etc/passwd.json; git commit -m 'Added server credentials'; git push; }

boot2docker: ; boot2docker up; $(shell boot2docker shellinit)

docker-build: dockerfile node user; docker build --rm -t _DOCKER_IMAGE .
docker-build-no-cache: dockerfile node user; docker build --no-cache=true --rm -t _DOCKER_IMAGE .

docker-run: docker-build docker-run-no-build ; 
docker-run-no-build: ; docker rm _DOCKER_CONTAINER 2> /dev/null ; docker run --rm -ti -v _THIS_ROOT:_SERVER_ROOT -p _THIS_PORT:_SERVER_PORT ifelse(_SSH_PORT, `', `', `-p '_SSH_PORT`:'_SSH_PORT) --name _DOCKER_CONTAINER _DOCKER_IMAGE bash

kernel-boot: docker-build kernel-boot-no-build ; 
kernel-boot-no-build: ; docker rm _DOCKER_CONTAINER 2> /dev/null ; docker run -d -v _THIS_ROOT:_SERVER_ROOT -p _THIS_PORT:_SERVER_PORT ifelse(_SSH_PORT, `', `', `-p '_SSH_PORT`:'_SSH_PORT) --name _DOCKER_CONTAINER _DOCKER_IMAGE ./boot/bin/launch kernel _SSH_PORT

kernel-halt: ; docker kill --signal=TERM _DOCKER_CONTAINER
kernel-halt-and-block: kernel-halt ; { while true; do sleep 1; docker inspect --format="{{ .State.Running }}" _DOCKER_CONTAINER | grep -qi false && exit 0; done }

kernel-running: ; docker inspect --format="{{ .State.Running }}" _DOCKER_CONTAINER | grep -qi 'true'

install: ; $(bin)/install _LOCAL_PUBLIC_KEY _LOCAL_PRIVATE_KEY _LOCAL_CONFIG _HOST_USER`@'_HOST_ADDR _HOST_REPOSITORY _HOST_HOME _HOST_ROOT
install-clean: ; $(bin)/install _LOCAL_PUBLIC_KEY _LOCAL_PRIVATE_KEY _LOCAL_CONFIG _HOST_USER`@'_HOST_ADDR _HOST_REPOSITORY _HOST_HOME _HOST_ROOT yes

connect: ; ssh -i _LOCAL_PRIVATE_KEY _HOST_USER`@'_HOST_ADDR
local: ; echo "TODO"
clean: ; rm $(build)/* 
