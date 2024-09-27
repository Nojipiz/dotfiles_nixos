-- general
vim.opt.relativenumber = true
lvim.log.level = "warn"
lvim.format_on_save.enabled = true
lvim.format_on_save.pattern = { "*.tsx", "*.ts", '*.js', "*.scala", "*.sbt" }
lvim.leader = "space"
lvim.keys.insert_mode["ii"] = "<Esc>"
lvim.keys.normal_mode["<S-l>"] = "<cmd> BufferLineCycleNext<CR>"
lvim.keys.normal_mode["<S-h>"] = "<cmd> BufferLineCyclePrev<CR>"

require('user.dashboard')
require('user.visuals')
require('user.terminal')
require('user.lualine')
require('user.intellisense')

local _, actions = pcall(require, "telescope.actions")
lvim.builtin.telescope.defaults.mappings = {
  -- for input mode
  i = {
    ["<C-j>"] = actions.move_selection_next,
    ["<C-k>"] = actions.move_selection_previous,
    ["<C-n>"] = actions.cycle_history_next,
    ["<C-p>"] = actions.cycle_history_prev,
  },
  -- for normal mode
  n = {
    ["<C-j>"] = actions.move_selection_next,
    ["<C-k>"] = actions.move_selection_previous,
  },
}

lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }

-- Additional Plugins
lvim.plugins = {
  {
    -- Plugins for databases
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      {
        "tpope/vim-dadbod",
      },
      {
      "kristijanhusak/vim-dadbod-completion"
      }
    },
    config = function()
      require("user.database").setup()
    end,
    init = function()
        vim.g.db_ui_use_nerd_fonts = 1
        vim.g.db_ui_show_database_icon = 1
    end,
  },
  {
    -- Scala Support
    "scalameta/nvim-metals",
    config = function()
      require("user.metals").setup()
    end,
  },
  {
    -- Orgmode Support
    "nvim-orgmode/orgmode",
    config = function()
      require("user.orgmode").setup()
    end,
    ft = { "org" },
  },
  {
    -- ColorScheme
    "rebelot/kanagawa.nvim",
    config = function()
      require("user.kanagawa").setup()
    end
  },
  { -- Http client
    "rest-nvim/rest.nvim",
    config = function()
      require("user.rest").setup()
    end,
  }
}
