-- Lualine configuration

local non_language_ft = {'fugitive'}

require('lualine').setup({
  options = {
    theme = "auto",
    -- Separators might look weird for certain fonts (eg Cascadia)
    component_separators = {left = '╲', right = '╱'},
    section_separators = {left = '', right = ''},
    globalstatus = false,
  },
  extensions = {
    'fugitive',
    'nvim-tree',
    'quickfix',
  },
  -- TODO: Implement some of these [component snippets](https://github.com/nvim-lualine/lualine.nvim/wiki/Component-snippets)
  sections = {
    lualine_a = {'mode'},
    lualine_b = {
      {'branch'},
      {'diff'},
    },
    lualine_c = {
      {
        'filename',
        file_status = true,
        newfile_status = true,
        symbols = {
          modified = ' ',
          readonly = ' ',
          unnamed = ' ❓',
          newfile = ' 📄',
        }
      },
      {
        function()
          local msg = 'No LSP'
          local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
          local clients = vim.lsp.get_active_clients()

          if next(clients) == nil  then
            return msg
          end

          -- Check for utility buffers
          for ft in non_language_ft do
            if ft:match(buf_ft) then
              return ''
            end
          end

          for _, client in ipairs(clients) do
            local filetypes = client.config.filetypes

            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
              -- return 'LSP:'..client.name  -- Return LSP name
              return ''  -- Only display if no LSP is found
            end
          end

          return msg
        end,
        icon = '',
        color = {fg = '#ffffff', gui = 'bold'},
        separator = "",
      },
      {
        'diagnostics',
        sources = {'nvim_diagnostic'},
        sections = {'error', 'warn', 'info'},
      },
    },
    lualine_x = {
      'encoding',
      'fileformat',
      'filetype',
    },
    lualine_y = {'progress'},
    lualine_z = {
      {
        function () return '' end,
        separator = ''
      },
      {'location'},
    }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {'branch', 'diff'},
    lualine_c = {'filename'},
    lualine_x = {
      'encoding',
      'fileformat',
      'filetype',
    },
    lualine_y = {'progress'},
    lualine_z = {
      {'location'},
    }
  },
})
