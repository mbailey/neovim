# Neovim environment

> how to view the env var within nvim?

● To view environment variables within Neovim, you can use:

  :echo $NVIM_SOCKET_PATH

  Or to see all environment variables:
  :echo environ()

  To check the current server name (socket path) that Neovim is using:
  :echo v:servername

  You can also check from Neovim's command mode:
  :!echo $NVIM_SOCKET_PATH

  If you want to verify that Neovim is actually listening on the socket, you can run:
  :echo serverlist()

  This will show all active Neovim server sockets.

