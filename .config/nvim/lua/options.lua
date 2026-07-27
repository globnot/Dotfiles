require "nvchad.options"

-- Le sandbox Flatpak (io.neovim.nvim) impose XDG_CONFIG_HOME/DATA/STATE/CACHE
-- vers ~/.var/app/io.neovim.nvim/... pour tout process enfant lancé par nvim.
-- Ça rend invisibles les configs XDG des outils invoqués depuis nvim — ex:
-- clangd cherchait ~/.var/app/.../config/clangd/config.yaml au lieu de
-- ~/.config/clangd/config.yaml, et retombait donc sans CompilationDatabase
-- (gd sautait au prototype dans le .h au lieu du .c). On restaure les vrais
-- chemins pour tout ce que nvim spawn ensuite (clangd, :terminal, formatters).
if vim.env.XDG_CONFIG_HOME and vim.env.XDG_CONFIG_HOME:match "%.var/app/" then
  vim.env.XDG_CONFIG_HOME = vim.env.HOME .. "/.config"
  vim.env.XDG_DATA_HOME = vim.env.HOME .. "/.local/share"
  vim.env.XDG_STATE_HOME = vim.env.HOME .. "/.local/state"
  vim.env.XDG_CACHE_HOME = vim.env.HOME .. "/.cache"
end

-- add yours here!
vim.opt.expandtab = false    -- IMPORTANT : garder les tabulations, ne pas convertir en espaces
vim.opt.tabstop = 4          -- largeur visuelle d'une tabulation = 4 espaces
vim.opt.shiftwidth = 4       -- indentation automatique = 4 (en tabulations)
vim.opt.softtabstop = 4      -- indentation quand tu appuies sur Tab = 4
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.colorcolumn = "80"

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
