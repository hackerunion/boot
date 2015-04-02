include(`config.m4')
include(`common.m4')

settings {
  nodaemon = true,
}

sync {
  default.rsync,
  source = "_LOCAL_SANDBOX",
  target = ":_SERVER_SANDBOX",
  rsync = {
    binary = "_SERVER_RSYNC",
    archive = true,
    compress = true,
    rsh = "sudo ssh -i _CURRENT_PRIVATE_KEY -p _HOST_SSH_PORT _CURRENT_USERNAME@_HOST_ADDR"
  }
}
