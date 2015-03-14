define(`_LOCAL_ROOT', `/Users/brandon/kernel')
define(`_LOCAL_PORT', `8888')
define(`_LOCAL_CONFIG', _LOCAL_ROOT`/boot/lib/config.m4.secret')

define(`_HOST_HOME', `/home/ec2-user')
define(`_HOST_ROOT', _HOST_HOME`/root')
define(`_HOST_PORT', `80')
define(`_HOST_USER', `ec2-user')
define(`_HOST_ADDR', `52.11.72.188')
define(`_HOST_URI', `http://www.hackerunion.org/')
define(`_HOST_REPOSITORY', `git@github.com:hackerunion/root.git')

define(`_DOCKER_IMAGE', `hu-image')
define(`_DOCKER_CONTAINER', `hu-live')

define(`_LOCAL_PUBLIC_KEY', _LOCAL_ROOT`/boot/private.ignore/id_rsa.pub')
define(`_LOCAL_PRIVATE_KEY', _LOCAL_ROOT`/boot/private.ignore/id_rsa')

define(`_SERVER_ROOT', `/srv')
define(`_SERVER_PORT', `8888')
define(`_SERVER_USERNAME', `server')
define(`_SERVER_UID', `1337')
define(`_SERVER_URI', `http://localhost:'_SERVER_PORT)

define(`_SSH_PORT', 25)

sinclude(_LOCAL_CONFIG)
