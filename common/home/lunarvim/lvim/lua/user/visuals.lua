--
-- Visuals Config File
--

-- Color scheme and details
lvim.colorscheme = "kanagawa"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false
lvim.builtin.nvimtree.setup.renderer.group_empty = true
lvim.builtin.nvimtree.setup.view.width = "30%"

-- Config for Neovide GUI
vim.opt.guifont = "monospace:h10"

-- My own fast theme change function
lvim.keys.normal_mode["|"] = ":lua ToggleTheme() <cr> "
function ToggleTheme()
  if (vim.o.background == "dark") then
    vim.o.background = "light"
  else
    vim.o.background = "dark"
  end
end
