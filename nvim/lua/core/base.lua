local o = vim.opt

vim.wo.number = true

o.title = true
o.expandtab = true

o.backup = false

-- Keep at least 10 line around the cursor.
o.scrolloff = 10

o.ignorecase = true
o.smartcase = true

-- # Text Formatting

o.smarttab = true
o.breakindent = true
o.shiftwidth = 2
o.tabstop = 2

o.wildignore:append { '*/node_modules/*' }

-- Not sure about these
-- opt.inncommand = 'split'

-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = '*',
  command = "set nopaste"
})

-- Not sure if this belongs in this file or another
o.spell = true

o.cursorline = true

o.termguicolors = true


-- TODO: noinsert
o.completeopt = {'menu', 'menuone', 'preview', 'noselect'}


-- Set maximum line width and text formatting for documents
o.textwidth = 90
-- TODO: Find a better options
--o.formatoptions = 'tcawjqro'

-- Conceal links for Org-mode and beyond?
o.conceallevel = 2
o.concealcursor = 'nc'


-- vim.g.copilot_no_tab_map = true
-- vim.g.copilot_assume_mapped = true
-- vim.g.copilot_tab_fallback = ""

vim.opt_global.dictionary = '~/.config/dicts/en_US.dict'
