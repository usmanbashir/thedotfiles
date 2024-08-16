local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use 'lewis6991/impatient.nvim'

  -- Indentation tracking
  -- TODO: Configure the plugin to be more rich
  use 'lukas-reineke/indent-blankline.nvim'

  use 'sheerun/vim-polyglot'

  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    requires = { {'nvim-lua/plenary.nvim'} },
    config = function() require('core.plugins.telescope') end,
  }

  use 'jeffkreeftmeijer/vim-numbertoggle'

  use 'nvim-treesitter/nvim-treesitter'

  -- Merged into code
  -- use {
  --   'lewis6991/spellsitter.nvim',
  --   config = function()
  --     require('spellsitter').setup()
  --   end
  -- }

  use {
    'neovim/nvim-lspconfig',
    config = function() require('core.plugins/lspconfig') end
  }

  -- Autocomplete
  use { 'onsails/lspkind.nvim' }
  use {
    "hrsh7th/nvim-cmp",
    -- Sources for nvim-cmp
    requires = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      -- "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-cmdline",
      -- "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-calc",
      "uga-rosa/cmp-dictionary",
      -- "L3MON4D3/LuaSnip",
      -- 'saadparwaiz1/cmp_luasnip',
      "ray-x/cmp-treesitter",
    },
    config = function()
      require('core.plugins/cmp')
    end
  }

  -- require('cmp_dictionary').setup({
  --   async = true,
  --   max_number_items = 10,
  --   exact_length = -1,
  -- })

  use {
    'nvim-lualine/lualine.nvim',
    config = function() require('core.plugins/lualine') end,
    requires = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icons
      opt = true
    },
  }

  use {
    'tpope/vim-fugitive'
  }

  use {
  'lewis6991/gitsigns.nvim',
  config = function() require('gitsigns').setup() end
  }

  use {
    'folke/tokyonight.nvim'
  }

  use {
    'kyazdani42/nvim-tree.lua',
    config = function() require('core.plugins/nvim-tree') end,
    requires = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icons
    },
  }


  use {
    'williamboman/mason.nvim',
    requires = {
      {'williamboman/mason-lspconfig.nvim'},
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup()
      require("mason-lspconfig").setup_handlers({
        function (server_name) -- default handler (optional)
          require("lspconfig")[server_name].setup {
            on_attach = function()
              vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = 0 })
              vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = 0 })
              vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = 0 })
              vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, { buffer = 0 })
              vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = 0 })
              vim.keymap.set('n', 'gra', vim.lsp.buf.rename, { buffer = 0 })
              vim.keymap.set('n', 'ga', vim.lsp.buf.code_action, { buffer = 0 })
              vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = 0 })
              vim.keymap.set('n', 'gf', function()
                vim.lsp.buf.format { async = true }
              end, { buffer = 0 })
            end
          }
        end,
      })
    end
  }

  use 'tpope/vim-repeat'

  -- TODO: Find out why this plugin won't work with my setup
  -- use {
  --   'nvim-treesitter/nvim-treesitter-context',
  --   after = 'nvim-treesitter',
  --   config = function()
  --     require('treesitter-context').setup()
  --   end
  -- }

  -- TODO: Eventually replace this plugin with `nvim-treesitter-context`
  use 'wellle/context.vim'


  -- TODO: Decide if I want to use this. As I tried it, but it kinda interferes with `context.vm`
  -- use {
  --   'AckslD/nvim-whichkey-setup.lua',
  --   requires = {'liuchengxu/vim-which-key'},
  -- }

  use 'vimwiki/vimwiki'

  use {
    'nvim-orgmode/orgmode',
    config = function()
      require('orgmode').setup()
    end
  }

  use 'github/copilot.vim'
  vim.g.copilot_no_tab_map = true
  vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
  vim.g.copilot_filetypes = {
    ["*"] = false,
    ["javascript"] = true,
    ["typescript"] = true,
    ["ruby"] = true,
    ["css"] = true,
    ["sass"] = true,
    ["html"] = true,
    ["slim"] = true,
    ["yaml"] = true,
    ["lua"] = true,
    ["rust"] = true,
    ["c"] = true,
    ["c#"] = true,
    ["c++"] = true,
    ["go"] = true,
    ["python"] = true,
  }

  use 'tpope/vim-rails'

  if packer_bootstrap then
    require('packer').sync()
  end
end)
