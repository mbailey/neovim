# NEOVIM CHEAT SHEET - PREFIX: <leader>

NAVIGATION:
  h j k l  Move cursor    w  Next word
  b  Previous word        e  End of word
  gg  Top of file         G  Bottom of file
  0  Start of line        $  End of line
  %  Matching bracket     f<char>  Find char

FILES:
  <leader>ff  Find files   <leader>fr  Recent files
  <leader>fg  Live grep    <leader>fb  Buffers
  <leader>e   File explorer <leader>w   Save file
  <leader>q   Close buffer  <leader>Q   Quit

EDITING:
  i  Insert mode          a  Append after cursor
  o  New line below       O  New line above
  u  Undo                 <C-r>  Redo
  dd Delete line          yy  Copy line
  p  Paste after          P  Paste before

CODE:
  <leader>ca  Code actions  <leader>cf  Format
  <leader>cr  Rename        <leader>cd  Go to definition
  <leader>cs  Document symbols
  K  Show documentation    gc  Comment toggle

VISUAL MODE (v):
  v  Visual mode          V  Visual line mode
  <C-v>  Visual block     >  Indent right
  <  Indent left          y  Copy selection

SPLITS:
  <leader>sv  Split vertical   <leader>sh  Split horizontal
  <C-h j k l>  Navigate splits <leader>sc  Close split
  <leader>sm  Maximize split
