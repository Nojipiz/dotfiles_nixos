--
-- Visuals Config File
--

-- Color scheme and details
lvim.colorscheme = "tokyonight"
vim.g.tokyonight_style = "night"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false
lvim.builtin.nvimtree.setup.renderer.group_empty = true
lvim.builtin.nvimtree.setup.view.width = "30%"

-- Config for Neovide GUI
vim.o.guifont = "Fira Code:h9"

-- My own fast theme change function
lvim.keys.normal_mode["|"] = ":lua ToggleTheme() <cr> "
function ToggleTheme()
  if (vim.o.background == "dark") then
    vim.o.background = "light"
  else
    vim.o.background = "dark"
  end
end
