# Split resizing

In NeoVim, you have several options for resizing splits:

Using keyboard commands:

 • <C-w> > - Increase width of current window
 • <C-w> < - Decrease width of current window
 • <C-w> + - Increase height of current window
 • <C-w> - - Decrease height of current window
 • <C-w> = - Make all windows equal size

Using counts:

 • 10<C-w>+ - Increase height by 10 lines
 • 20<C-w>> - Increase width by 20 characters

Using mouse (if enabled):

 • Click and drag the divider between splits

Using commands:

 • :resize 60 - Set height to 60 lines
 • :vertical resize 80 - Set width to 80 characters
 • :resize +5 or :resize -5 - Adjust height relatively
 • :vertical resize +5 or :vertical resize -5 - Adjust width relatively

You can also map these commands to custom keybindings in your NeoVim config if you want easier access to resizing functions.
