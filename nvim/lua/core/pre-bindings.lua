local Utils = require('core.utils')

local inoremap = Utils.inoremap
local nnoremap = Utils.nnoremap
local vnoremap = Utils.vnoremap

vim.g.mapleader = ','
vim.g.maplocalleader = ','

inoremap('jj', '<Esc>')

nnoremap("<C-h>", "<C-w>h")
nnoremap("<C-j>", "<C-w>j")
nnoremap("<C-k>", "<C-w>k")
nnoremap("<C-l>", "<C-w>l")

-- Make ; do the same thing as :
-- It's one less key to hit every time I want to execute a command.
nnoremap(";", ":")

-- Make `j` and `k` keys work the way one expects them to work. Instead of 
-- working in some archaic 'movment by file line instead of screen line' fashion.
nnoremap('j', 'gj')
nnoremap('k', 'gk')

-- Splits
nnoremap("<leader>ws", ":split<CR>")
nnoremap("<leader>vs", ":vsplit<CR>")

--nnoremap('<leader>e', ':NvimTreeToggle<CR>')

-- Save with <leader> + w
vim.keymap.set('n', '<leader>w', vim.cmd.w)

-- Close current buffer
vim.keymap.set('n', '<leader>q', vim.cmd.q)

-- Clear search highlight
nnoremap('<leader>nh', ':nohlsearch<CR>')
vnoremap('<leader>nh', ':nohlsearch<CR>')

-- Disable arrow keys while in normal and insert modes to always
-- force myself to keep using hjkl.
--
-- That means they still function in the visual mode.
nnoremap('<up>', '<nop>')
nnoremap('<down>', '<nop>')
nnoremap('<left>', '<nop>')
nnoremap('<right>', '<nop>')
inoremap('<up>', '<nop>')
inoremap('<down>', '<nop>')
inoremap('<left>', '<nop>')
inoremap('<right>', '<nop>')

-- Insert the current date stamp when F5 is pressed in insert mode.
inoremap('<F5>', '<C-R>=strftime("%a / %b %d / %Y - %T")<CR>')
