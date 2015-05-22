include(`config.m4')
include(`common.m4')

root = _THIS_ROOT
boot = $(root)/boot
host = $(root)/boot/host
bin = $(root)/boot/host/bin
lib = $(root)/boot/host/lib
build = $(root)/boot/host/build
src = $(root)/usr/src/kernel

use-these-targets-to-manage-your-server: info;
info: ; cat $(host)/Makefile | grep '^[a-z-]*:' | cut -d':' -f1

make: ; m4 -I $(lib) $(lib)/Makefile.m4 > Makefile

dockerfile: ; m4 -I $(lib) $(lib)/Dockerfile.m4 > Dockerfile
node: ; cp $(src)/package.json $(build)/package.json

https: ; cp _THIS_SECURE_KEY $(build)/key.pem ; cp _THIS_SECURE_CERT $(build)/cert.pem
https-cert: ; $(bin)/mkcert $(build)/insecure-key.pem $(build)/insecure-cert.pem

server-user: ; $(bin)/mkuser _SERVER_USERNAME _SERVER_UID _SERVER_SECRET _SERVER_SHELL _THIS_ROOT
server-group: ; $(bin)/mkgroup _SERVER_USERNAME _SERVER_UID _THIS_ROOT
user: server-user server-group

guest-user: ; $(bin)/mkuser _SERVER_GUEST_USERNAME _SERVER_GUEST_UID _SERVER_GUEST_SECRET _SERVER_GUEST_SHELL _THIS_ROOT
guest-group: ; $(bin)/mkgroup _SERVER_GUEST_USERNAME _SERVER_GUEST_UID _THIS_ROOT
guest: guest-user guest-group

default-users: user guest

docker-build: dockerfile https node user; docker build --rm -t _DOCKER_IMAGE .
docker-build-no-cache: dockerfile node user; docker build --no-cache=true --rm -t _DOCKER_IMAGE .

docker-run: docker-build docker-run-no-build ; 
docker-run-no-build: ; docker rm _DOCKER_CONTAINER 2> /dev/null ; docker run --rm -ti -v _THIS_ROOT:_SERVER_ROOT -p _THIS_PORT:_SERVER_PORT -p _THIS_SECURE_PORT:_SERVER_SECURE_PORT ifelse(_SSH_PORT, `', `', `-p '_THIS_SSH_PORT`:'_SERVER_SSH_PORT) --name _DOCKER_CONTAINER _DOCKER_IMAGE bash

kernel-development: docker-build kernel-development-no-build ; 
kernel-development-no-build: ; docker rm _DOCKER_CONTAINER 2> /dev/null ; docker run -d -v _THIS_ROOT:_SERVER_ROOT -p _THIS_PORT:_SERVER_PORT -p _THIS_SECURE_PORT:_SERVER_SECURE_PORT ifelse(_SSH_PORT, `', `', `-p '_THIS_SSH_PORT`:'_SERVER_SSH_PORT) --name _DOCKER_CONTAINER _DOCKER_IMAGE _SERVER_ROOT/boot/bin/development kernel

kernel-boot: docker-build kernel-boot-no-build ; 
kernel-boot-no-build: ; docker rm _DOCKER_CONTAINER 2> /dev/null ; docker run -d -v _THIS_ROOT:_SERVER_ROOT -p _THIS_PORT:_SERVER_PORT -p _THIS_SECURE_PORT:_SERVER_SECURE_PORT ifelse(_SSH_PORT, `', `', `-p '_THIS_SSH_PORT`:'_SERVER_SSH_PORT) --name _DOCKER_CONTAINER _DOCKER_IMAGE _SERVER_ROOT/boot/bin/launch kernel

kernel-halt: ; docker kill --signal=TERM _DOCKER_CONTAINER > /dev/null 2>&1
kernel-halt-and-block: kernel-halt ; { while true; do sleep 1; docker inspect --format="{{ .State.Running }}" _DOCKER_CONTAINER | grep -qi false && exit 0; done }

kernel-running: ; docker inspect --format="{{ .State.Running }}" _DOCKER_CONTAINER | grep -qi 'true'

kernel-locked: ; test -f _THIS_ROOT/var/lock/kernel/run

install: ; $(bin)/install _LOCAL_PUBLIC_KEY _LOCAL_PRIVATE_KEY _LOCAL_SECURE_KEY _LOCAL_SECURE_CERT _LOCAL_CONFIG _HOST_USER`@'_HOST_ADDR _HOST_REPOSITORY _HOST_HOME _HOST_SECURE_KEY _HOST_SECURE_CERT _HOST_CONFIG _HOST_ROOT
install-clean: ; $(bin)/install _LOCAL_PUBLIC_KEY _LOCAL_PRIVATE_KEY _LOCAL_SECURE_KEY _LOCAL_SECURE_CERT _LOCAL_CONFIG _HOST_USER`@'_HOST_ADDR _HOST_REPOSITORY _HOST_HOME _HOST_SECURE_KEY _HOST_SECURE_CERT _HOST_CONFIG _HOST_ROOT yes

install-shell: ; $(bin)/install-shell _HOST_FQDN _SHELL_USER _SHELL_HOME _SHELL_BIN _SHELL_PORT _SHELL_PATH _LOCAL_PRIVATE_KEY _SHELL_SECURE_KEY _SHELL_SECURE_CERT _HOST_USER`@'_HOST_ADDR _HOST_SSH_PORT

ssh-key-create: ; ssh-keygen -b 2048 -t rsa -f _CURRENT_PRIVATE_KEY -q -N "" ; mv defn(`_CURRENT_PRIVATE_KEY').pub _CURRENT_PUBLIC_KEY
ssh-key-install: ; ssh -ti _CURRENT_PRIVATE_KEY -p _HOST_SSH_PORT _CURRENT_USERNAME`@'_HOST_ADDR mkdir -p .ssh; scp -o PubkeyAuthentication=no -P _HOST_SSH_PORT _CURRENT_PUBLIC_KEY _CURRENT_USERNAME`@'_HOST_ADDR:_SERVER_HOME`/'.ssh/authorized_keys

connect: ; ssh -i _LOCAL_PRIVATE_KEY _HOST_USER`@'_HOST_ADDR
connect-kernel: ; ssh -i _CURRENT_PRIVATE_KEY -p _HOST_SSH_PORT _CURRENT_USERNAME`@'_HOST_ADDR
connect-kernel-password: ; ssh -o PubkeyAuthentication=no -p _HOST_SSH_PORT _CURRENT_USERNAME`@'_HOST_ADDR

permissions-freeze: ; cp -i $(root)/etc/permissions.acl /tmp/permissions.acl.frozen
permissions-thaw: ; cp -i /tmp/permissions.acl.frozen $(root)/etc/permissions.acl

lsyncd: ; ( type lsyncd && m4 -I $(lib) $(lib)/sync.m4 > $(build)/sync.cfg ) || ( echo "Please install lsyncd to continue." && false )

sandbox: lsyncd ; lsyncd $(build)/sync.cfg
sandbox-root: lsyncd ; sudo lsyncd $(build)/sync.cfg
sandbox-init: lsyncd ; mkdir -p _LOCAL_SANDBOX ; ssh -i _CURRENT_PRIVATE_KEY -p _HOST_SSH_PORT _CURRENT_USERNAME`@'_HOST_ADDR mkdir -p _SERVER_SANDBOX

rsync: ; rsync -a -e '/usr/bin/ssh -i _CURRENT_PRIVATE_KEY -p _HOST_SSH_PORT _CURRENT_USERNAME`@'_HOST_ADDR _LOCAL_SANDBOX :_SERVER_SANDBOX
rsync-password: ; rsync -a -e '/usr/bin/ssh -o PubkeyAuthentication=no -p _HOST_SSH_PORT _CURRENT_USERNAME`@'_HOST_ADDR _LOCAL_SANDBOX :_SERVER_SANDBOX

poke: ; $(bin)/poke _LOCAL_PRIVATE_KEY _HOST_USER`@'_HOST_ADDR _HOST_HOME _HOST_ROOT
resync: ; $(bin)/resync _LOCAL_PRIVATE_KEY _HOST_USER`@'_HOST_ADDR _HOST_HOME _HOST_ROOT

clean: ; rm $(build)/*

hack-init: ssh-key-create ssh-key-install sandbox-init 
hack-help: ; echo -e "$$(tput setaf 4)README: $$(tput smso)_LOCAL_SANDBOX$$(tput sgr0)$$(tput setaf 4) will be synchronized with $$(tput smso)_HOST_URI:_SERVER_SANDBOX$$(tput sgr0)$$(tput setaf 4) until you kill this process$$(tput sgr0)"

hack-now-root: hack-help sandbox-root
hack-now: hack-help sandbox

hack-new: hack-init hack-now
hack-new-root: hack-init hack-now-root
