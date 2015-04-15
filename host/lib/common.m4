ifdef(`_REMOTE', sinclude(_HOST_CONFIG))

define(`_NL',`
')

define(`_THIS_UID', translit(esyscmd(`id -u'), _NL))
define(`_THIS_GID', translit(esyscmd(`id -g'), _NL))
define(`_THIS_ROOT', ifdef(`_REMOTE', _HOST_ROOT, _LOCAL_ROOT))
define(`_THIS_PORT', ifdef(`_REMOTE', _HOST_PORT, _LOCAL_PORT))
define(`_THIS_CONFIG', ifdef(`_REMOTE', _HOST_CONFIG, _LOCAL_CONFIG))
define(`_THIS_SSH_PORT', ifdef(`_REMOTE', _HOST_SSH_PORT, _LOCAL_SSH_PORT))
define(`_THIS_SECURE_KEY', ifdef(`_REMOTE', _HOST_SECURE_KEY, _LOCAL_SECURE_KEY))
define(`_THIS_SECURE_CERT', ifdef(`_REMOTE', _HOST_SECURE_CERT, _LOCAL_SECURE_CERT))
define(`_THIS_SECURE_PORT', ifdef(`_REMOTE', _HOST_SECURE_PORT, _LOCAL_SECURE_PORT))
