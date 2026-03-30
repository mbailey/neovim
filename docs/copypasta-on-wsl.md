# copypasta on wsl

Since clipboard (`wl-copy`) works on Fedora but fails in Ubuntu under WSL, let's troubleshoot and fix it.

### **1. Verify `wl-copy` is Installed**

Ensure `wl-copy` is properly installed in Ubuntu:

```sh
which wl-copy
```

If it's not installed, install it:

```sh
sudo apt install wl-clipboard
```

### **2. Check if `wl-copy` Works Manually**

Run the following command to test clipboard access:

```sh
echo "test" | wl-copy
wl-paste
```

- If this fails with an error, then `wl-copy` isn't working properly in WSL.
- If it succeeds, the issue may be specific to Neovim.

### **3. Verify WSL Clipboard Integration**

Unlike Fedora (which runs a Wayland session natively), WSL does not always
support Wayland properly. Check if `wl-copy` can access a Wayland session:

```sh
echo $WAYLAND_DISPLAY
```

If it's empty, Wayland isn't available, and `wl-copy` won't work.

#### **Alternative: Use `win32yank.exe` Instead of `wl-copy`**

Since WSL doesn't natively support Wayland-based clipboard tools, the recommended workaround is to use `win32yank.exe`, which integrates with the Windows clipboard directly.

##### **Install `win32yank.exe`**

Run:

```sh
wget https://github.com/equalsraf/win32yank/releases/download/v0.1.1/win32yank.exe -O ~/.local/bin/win32yank.exe
chmod +x ~/.local/bin/win32yank.exe
```

##### **Update Neovim Config to Use `win32yank`**

Modify your `init.vim` or `init.lua`:

**For `init.vim`:**

```vim
set clipboard=unnamedplus
let g:clipboard = {
  \   'name': 'win32yank',
  \   'copy': {
  \      '+': 'win32yank.exe -i --crlf',
  \      '*': 'win32yank.exe -i --crlf',
  \    },
  \   'paste': {
  \      '+': 'win32yank.exe -o --lf',
  \      '*': 'win32yank.exe -o --lf',
  \   },
  \   'cache_enabled': 0,
  \ }
```

**For `init.lua`:**

```lua
vim.opt.clipboard = "unnamedplus"
vim.g.clipboard = {
  name = "win32yank",
  copy = {
    ["+"] = "win32yank.exe -i
```
