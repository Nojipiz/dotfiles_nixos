--
-- Code Completion Stuff
--
lvim.builtin.cmp.experimental.ghost_text = true
lvim.lsp.installer.setup.automatic_installation = false

-- Tree sitter
lvim.builtin.treesitter.ignore_install = { "haskell", "c_sharp" }
lvim.builtin.treesitter.highlight.enabled = true
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "scala",
  "php",
  "kotlin",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "org",
  "tsx",
  "css",
  "rust",
  "java",
  "yaml",
}

-- local linters = require "lvim.lsp.null-ls.linters"
-- linters.setup {
--   { command = "eslint_d", filetypes = { "typescript", "typescriptreact" } }
-- }

local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  -- { command = "prettierd", filetypes = { "html", "vue", "css", "scss", "typescriptreact", "typescript" } },
}

-- Tailwind
-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "tailwindcss" })
-- require("lvim.lsp.manager").setup("tailwindcss", {
--   filetypes = { "typescriptreact" }
-- })

-- Scala
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.scala", "*.sbt" },
  command = "lua require('user.metals').setup()"
})
