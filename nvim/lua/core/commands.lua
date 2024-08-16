-- All the commands fit to have

-- Jump to last cursor position unless it's invalid or in an event handler.
vim.cmd [[autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif]]

-- Highlight yanked content
vim.cmd [[au TextYankPost * silent! lua vim.highlight.on_yank()]]
