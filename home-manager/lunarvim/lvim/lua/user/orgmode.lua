local M = {}

M.setup = function()
  local status_ok, org_mode = pcall(require, "orgmode")
  org_mode.setup_ts_grammar()

  if not status_ok then
    return
  end

  org_mode.setup {
    org_agenda_files = { "~/Documents/SecondBrain/**/*" },
    org_default_notes_file = "~/Documents/SecondBrain/TODOS.org",
    org_agenda_templates = {
      T = {
        description = "Todo",
        template = "* TODO %?\n  DEADLINE: %T",
        target = "~/shared/orgs/todos.org",
      },
      w = {
        description = "Work todo",
        template = "* TODO %?\n  DEADLINE: %T",
        target = "~/shared/orgs/work.org",
      },
    },
    mappings = {
      global = {
        org_agenda = "go",
        org_capture = "gC",
      },
    },
  }
  SetCompletionSource()
end

function SetCompletionSource()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "org" },
    callback = function()
      require('cmp').setup.buffer(
        { sources = { { name = 'orgmode' } } }
      )
    end
  })
end

return M
