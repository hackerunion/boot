dnl These are used to configure your local kernel, the remote host, and the server itself (running on the host)

define(`_LOCAL_ROOT', `/Users/brandon/kernel')
define(`_LOCAL_PRIVATE', _LOCAL_ROOT`/boot/private.ignore')
define(`_LOCAL_PORT', `8888')
define(`_LOCAL_SECURE_PORT', `8889')
define(`_LOCAL_SSH_PORT', `8890')
define(`_LOCAL_CONFIG', _LOCAL_ROOT`/boot/lib/config.m4.secret')
define(`_LOCAL_DEVELOPER_CONFIG', _LOCAL_ROOT`/boot/lib/developer.m4.ignore')
define(`_LOCAL_PUBLIC_KEY', _LOCAL_PRIVATE`/id_rsa.pub')
define(`_LOCAL_PRIVATE_KEY', _LOCAL_PRIVATE`/id_rsa')
define(`_LOCAL_SECURE_KEY', _LOCAL_PRIVATE`/key.pem')
define(`_LOCAL_SECURE_CERT', _LOCAL_PRIVATE`/cert.pem')

define(`_SHELL_USER', `webssh')
define(`_SHELL_HOME', `/home/webssh')
define(`_SHELL_PORT', `4200')
define(`_SHELL_PATH', `/')
define(`_SHELL_URI', `https://_HOST_ADDR:'defn(`_SHELL_PORT')defn(`_SHELL_PATH'))
define(`_SHELL_SECURE_KEY', _LOCAL_PRIVATE`/key.pem')
define(`_SHELL_SECURE_CERT', _LOCAL_PRIVATE`/cert.pem')
define(`_SHELL_BIN', _LOCAL_ROOT`/boot/bin/webssh')

define(`_HOST_HOME', `/home/ec2-user')
define(`_HOST_ROOT', _HOST_HOME`/root')
define(`_HOST_PORT', `80')
define(`_HOST_SECURE_PORT', `443')
define(`_HOST_SSH_PORT', `1337')
define(`_HOST_SHELL_PORT', `4200')
define(`_HOST_USER', `ec2-user')
define(`_HOST_ADDR', `52.11.72.188')
define(`_HOST_URI', `http://www.hackerunion.org/')
define(`_HOST_REPOSITORY', `git@github.com:hackerunion/root.git')
define(`_HOST_CONFIG', _HOST_HOME`/local/config.m4')
define(`_HOST_SECURE_KEY', _HOST_HOME`/local/key.pem')
define(`_HOST_SECURE_CERT', _HOST_HOME`/local/cert.pem')

define(`_DOCKER_IMAGE', `hu-image')
define(`_DOCKER_CONTAINER', `hu-live')

define(`_SERVER_ROOT', `/srv')
define(`_SERVER_PORT', `8888')
define(`_SERVER_SECURE_PORT', `8889')
define(`_SERVER_SSH_PORT', `8890')
define(`_SERVER_USERNAME', `server')
define(`_SERVER_UID', `1337')
define(`_SERVER_URI', `http://localhost:'_SERVER_PORT)
define(`_SERVER_SECURE_KEY', `/etc/ssl/server/key.pem')
define(`_SERVER_SECURE_CERT',`/etc/ssl/server/cert.pem')
define(`_SERVER_RSYNC', `/usr/bin/rsync')

sinclude(_LOCAL_CONFIG)
sinclude(_LOCAL_DEVELOPER_CONFIG)
