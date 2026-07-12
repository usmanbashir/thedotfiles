-- Pickers for staged-only / unstaged-only files. Telescope's builtin
-- `git_status` merges both into one list, distinguished only by the porcelain
-- status column, which doesn't fuzzy-match well.
local action_state = require('telescope.actions.state')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local make_entry = require('telescope.make_entry')
local conf = require('telescope.config').values

local M = {}

local function git_root()
  local root = vim.fn.systemlist({ 'git', 'rev-parse', '--show-toplevel' })[1]
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return root
end

local function git(root, args)
  local command = { 'git', '-c', 'core.quotepath=false', '-C', root }
  vim.list_extend(command, args)
  return command
end

local function diff_previewer(root, diff_args)
  return previewers.new_buffer_previewer({
    title = 'Diff Preview',
    get_buffer_by_name = function(_, entry)
      return entry.value
    end,
    define_preview = function(self, entry)
      local args = { '--no-pager', 'diff' }
      vim.list_extend(args, diff_args)
      vim.list_extend(args, { '--', entry.value })

      local lines = vim.fn.systemlist(git(root, args))
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
      vim.api.nvim_set_option_value('filetype', 'diff', { buf = self.state.bufnr })
    end,
  })
end

-- `diff_args` selects the half of the index we care about: `--cached` diffs HEAD
-- against the index (staged), no flag diffs the index against the working tree
-- (unstaged). `toggle_args` moves a file across that line, so <Tab> removes it
-- from whichever list you're looking at.
local function changed_files(title, diff_args, toggle_args)
  local root = git_root()
  if not root then
    vim.notify('Not inside a Git repository', vim.log.levels.WARN)
    return
  end

  local opts = { cwd = root }

  local function make_finder()
    local args = { 'diff', '--name-only' }
    vim.list_extend(args, diff_args)

    return finders.new_oneshot_job(git(root, args), {
      entry_maker = make_entry.gen_from_file(opts),
    })
  end

  pickers.new(opts, {
    prompt_title = title,
    finder = make_finder(),
    sorter = conf.file_sorter(opts),
    previewer = diff_previewer(root, diff_args),
    layout_strategy = 'vertical',
    layout_config = {
      vertical = {
        width = 0.5,
      },
    },
    attach_mappings = function(prompt_bufnr, map)
      local toggle_staged = function()
        local entry = action_state.get_selected_entry()
        if not entry then
          return
        end

        vim.fn.system(git(root, toggle_args(entry.value)))
        if vim.v.shell_error ~= 0 then
          vim.notify('git failed on ' .. entry.value, vim.log.levels.ERROR)
          return
        end

        action_state.get_current_picker(prompt_bufnr):refresh(make_finder(), { reset_prompt = false })
      end

      map({ 'i', 'n' }, '<Tab>', toggle_staged)
      return true
    end,
  }):find()
end

function M.staged()
  changed_files('Staged Files', { '--cached' }, function(file)
    return { 'restore', '--staged', '--', file }
  end)
end

function M.unstaged()
  changed_files('Unstaged Files', {}, function(file)
    return { 'add', '--', file }
  end)
end

return M
