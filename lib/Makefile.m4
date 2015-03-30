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

https: _THIS_SECURE_KEY _THIS_SECURE_CERT ; cp _THIS_SECURE_KEY $(build)/key.pem ; cp _THIS_SECURE_CERT $(build)/cert.pem
https-cert: ; $(bin)/mkcert $(build)/insecure-key.pem $(build)/insecure-cert.pem

user: ; $(bin)/mkuser _SERVER_USERNAME _SERVER_UID _SERVER_SECRET _THIS_ROOT
user-with-push: user ; { cd $(root); git add etc/passwd.json; git commit -m 'Added server credentials'; git push; }

docker-build: dockerfile https node user; docker build --rm -t _DOCKER_IMAGE .
docker-build-no-cache: dockerfile node user; docker build --no-cache=true --rm -t _DOCKER_IMAGE .

docker-run: docker-build docker-run-no-build ; 
docker-run-no-build: ; docker rm _DOCKER_CONTAINER 2> /dev/null ; docker run --rm -ti -v _THIS_ROOT:_SERVER_ROOT -p _THIS_PORT:_SERVER_PORT -p _THIS_SECURE_PORT:_SERVER_SECURE_PORT ifelse(_SSH_PORT, `', `', `-p '_THIS_SSH_PORT`:'_SERVER_SSH_PORT) --name _DOCKER_CONTAINER _DOCKER_IMAGE bash

kernel-development: docker-build kernel-development-no-build ; 
kernel-development-no-build: ; docker rm _DOCKER_CONTAINER 2> /dev/null ; docker run -d -v _THIS_ROOT:_SERVER_ROOT -p _THIS_PORT:_SERVER_PORT -p _THIS_SECURE_PORT:_SERVER_SECURE_PORT ifelse(_SSH_PORT, `', `', `-p '_THIS_SSH_PORT`:'_SERVER_SSH_PORT) --name _DOCKER_CONTAINER _DOCKER_IMAGE ./boot/bin/development kernel

kernel-boot: docker-build kernel-boot-no-build ; 
kernel-boot-no-build: ; docker rm _DOCKER_CONTAINER 2> /dev/null ; docker run -d -v _THIS_ROOT:_SERVER_ROOT -p _THIS_PORT:_SERVER_PORT -p _THIS_SECURE_PORT:_SERVER_SECURE_PORT ifelse(_SSH_PORT, `', `', `-p '_THIS_SSH_PORT`:'_SERVER_SSH_PORT) --name _DOCKER_CONTAINER _DOCKER_IMAGE ./boot/bin/launch kernel

kernel-halt: ; docker kill --signal=TERM _DOCKER_CONTAINER
kernel-halt-and-block: kernel-halt ; { while true; do sleep 1; docker inspect --format="{{ .State.Running }}" _DOCKER_CONTAINER | grep -qi false && exit 0; done }

kernel-running: ; docker inspect --format="{{ .State.Running }}" _DOCKER_CONTAINER | grep -qi 'true'

install: ; $(bin)/install _LOCAL_PUBLIC_KEY _LOCAL_PRIVATE_KEY _LOCAL_SECURE_KEY _LOCAL_SECURE_CERT _LOCAL_CONFIG _HOST_USER`@'_HOST_ADDR _HOST_REPOSITORY _HOST_HOME _HOST_SECURE_KEY _HOST_SECURE_CERT _HOST_CONFIG _HOST_ROOT
install-clean: ; $(bin)/install _LOCAL_PUBLIC_KEY _LOCAL_PRIVATE_KEY _LOCAL_SECURE_KEY _LOCAL_SECURE_CERT _LOCAL_CONFIG _HOST_USER`@'_HOST_ADDR _HOST_REPOSITORY _HOST_HOME _HOST_SECURE_KEY _HOST_SECURE_CERT _HOST_CONFIG _HOST_ROOT yes

install-shell: ; $(bin)/install-shell _SHELL_USER _SHELL_HOME _SHELL_BIN _SHELL_PORT _SHELL_PATH _LOCAL_PRIVATE_KEY _SHELL_SECURE_KEY _SHELL_SECURE_CERT _HOST_USER`@'_HOST_ADDR _HOST_SSH_PORT

connect: ; ssh -i _LOCAL_PRIVATE_KEY _HOST_USER`@'_HOST_ADDR
connect-kernel: ; read -p "Username: " NAME ; ssh -o PubkeyAuthentication=no -p _HOST_SSH_PORT $$NAME@_HOST_ADDR

permissions-freeze: ; cp -i $(root)/etc/permissions.acl /tmp/permissions.acl.frozen
permissions-thaw: ; cp -i /tmp/permissions.acl.frozen $(root)/etc/permissions.acl

work: ; echo wip
poke: ; $(bin)/poke _LOCAL_PRIVATE_KEY _HOST_USER`@'_HOST_ADDR _HOST_HOME _HOST_ROOT
clean: ; rm $(build)/* 

.PHONY: use-these-targets-to-manage-your-server info make dockerfile node https https-cert user user-with-push docker-build docker-build-no-cache docker-run docker-run-no-build kernel-development kernel-development-no-build kernel-boot kernel-boot-no-build kernel-halt kernel-halt-and-block kernel-running install install-clean install-shell connect connect-kernel poke clean
