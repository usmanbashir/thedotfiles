require('gitsigns').setup({
  -- Hunk-level counterparts to the file-level pickers on <leader>g.
  on_attach = function(bufnr)
    local gitsigns = require('gitsigns')

    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    map('n', ']h', function() gitsigns.nav_hunk('next') end, 'Next Git Hunk')
    map('n', '[h', function() gitsigns.nav_hunk('prev') end, 'Previous Git Hunk')

    map('n', '<leader>hs', gitsigns.stage_hunk, 'Stage Hunk')
    map('n', '<leader>hr', gitsigns.reset_hunk, 'Reset Hunk')

    map('v', '<leader>hs', function()
      gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end, 'Stage selected Hunk')
    map('v', '<leader>hr', function()
      gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end, 'Reset selected Hunk')

    map('n', '<leader>hS', gitsigns.stage_buffer, 'Stage Buffer')
    map('n', '<leader>hR', gitsigns.reset_buffer, 'Reset Buffer')

    map('n', '<leader>hp', gitsigns.preview_hunk, 'Preview Hunk')
    map('n', '<leader>hd', gitsigns.diffthis, 'Diff Buffer')
    map('n', '<leader>hb', function()
      gitsigns.blame_line({ full = true })
    end, 'Blame Line')
  end,
})
