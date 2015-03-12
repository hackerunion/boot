define(`_LOCAL_ROOT', `/Users/brandon/kernel')
define(`_LOCAL_PORT', `8888')
define(`_SERVER_ROOT', `/srv')
define(`_SERVER_USERNAME', `server')
define(`_SERVER_UID', `1337')
define(`_SERVICE_PORT', `8888')
define(`_SERVICE_URI', `http://localhost:'_SERVICE_PORT)
define(`_HOST_HOME', `/home/ec2-user')
define(`_HOST_USER', `ec2-user')
define(`_HOST_ADDR', `52.11.72.188')
define(`_HOST_REPOSITORY', `git@github.com:hackerunion/root.git')
define(`_DOCKER_IMAGE', `hu-image')
define(`_DOCKER_CONTAINER', `hu-live')
define(`_PUBLIC_KEY', _LOCAL_ROOT`/boot/private.ignore/id_rsa.pub')
define(`_PRIVATE_KEY', _LOCAL_ROOT`/boot/private.ignore/id_rsa')
sinclude(`config.m4.secret')
