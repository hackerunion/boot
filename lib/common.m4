ifdef(`_REMOTE', sinclude(_HOST_HOME/local/config.m4))

define(`_THIS_ROOT', ifdef(`_REMOTE', _HOST_ROOT, _LOCAL_ROOT))
define(`_THIS_PORT', ifdef(`_REMOTE', _HOST_PORT, _LOCAL_PORT))
define(`_NEXT_ROOT', ifdef(`_REMOTE', _SERVER_ROOT, _HOST_ROOT))
define(`_NEXT_PORT', ifdef(`_REMOTE', _SERVER_PORT, _HOST_PORT))
