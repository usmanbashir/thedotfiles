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

nnoremap('<leader>e', ':NvimTreeToggle<CR>')

-- Save with Ctrl + S
nnoremap('<C-s', ':w<CR>')

-- Close buffer
nnoremap('<C-c', ':q<CR>')

-- Clear search highlight
nnoremap('<leader>nh', ':nohlsearch<CR>')
vnoremap('<leader>nh', ':nohlsearch<CR>')

-- Telescope
nnoremap('<leader>p', '<Cmd>Telescope find_files<CR>')
--nnoremap('<leader>fhf', '<Cmd>Telescope find_files hidden=true<CR>')
nnoremap('<leader>b', '<Cmd>Telescope buffers<CR>')
nnoremap('<leader>g', '<Cmd>Telescope live_grep<CR>')
nnoremap('<leader>th', '<Cmd>Telescope help_tags<CR>')
nnoremap('<leader>ts', '<Cmd>Telescope<CR>')
nnoremap('<leader>r', '<Cmd>Telescope oldfiles<CR>')
nnoremap('<leader>s', '<Cmd>Telescope spell_suggest<CR>')
nnoremap('<leader>f', '<Cmd>Telescope current_buffer_fuzzy_find<CR>')


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

vim.keymap.set('n', '<leader>dk', vim.diagnostic.goto_prev, { buffer = 0 })
vim.keymap.set('n', '<leader>dj', vim.diagnostic.goto_next, { buffer = 0 })
vim.keymap.set('n', '<leader>dl', '<cmd>Telescope diagnostics<cr>', { buffer = 0 })

-- Insert the current date stamp when F5 is pressed in insert mode.
inoremap('<F5>', '<C-R>=strftime("%a / %b %d / %Y - %T")<CR>')

-- GitHub Copilot
-- inoremap('<C-j>', '<Esc>')
