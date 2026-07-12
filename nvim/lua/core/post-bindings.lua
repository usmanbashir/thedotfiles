vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'NvimTree toggle' })

local builtin = require('telescope.builtin')
local telescope_git = require('config.telescope-git')

vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Search Files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Search by Grep' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = 'Find existing buffers' })
vim.keymap.set('n', '<leader>fs', builtin.spell_suggest, { desc = 'Search Spelling Suggestions' })
vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = 'Telescope current buffer fuzzy find' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Search Help' })
vim.keymap.set('n', '<leader>f.', builtin.oldfiles, { desc = 'Search Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Search current Word' })
vim.keymap.set('n', '<leader>ft', builtin.treesitter, { desc = 'Telescope treesitter' })
vim.keymap.set('n', '<leader>fc', builtin.commands, { desc = 'Telescope commands' })
vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = 'Search Keymaps' })
vim.keymap.set('n', '<leader>fr', builtin.registers, { desc = 'Telescope registers' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = 'Search Diagnostics' })

vim.keymap.set('n', '<leader>gg', ':Git<CR>', { desc = 'Fugitive status' })
vim.keymap.set('n', '<leader>gc', builtin.git_status, { desc = 'Search Changed Files' })
vim.keymap.set('n', '<leader>gs', telescope_git.staged, { desc = 'Search Staged Files' })
vim.keymap.set('n', '<leader>gu', telescope_git.unstaged, { desc = 'Search Unstaged Files' })

vim.keymap.set('n', '<leader>ts', builtin.builtin, { desc = 'Search Telescope' })

vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic' })
