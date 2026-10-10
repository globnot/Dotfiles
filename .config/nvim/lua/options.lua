-- y/p passent par le presse-papier du système (wl-clipboard sous Wayland)
-- au lieu du registre interne à cette seule instance de Neovim — sans ça,
-- copier dans un fichier ouvert dans un terminal et coller dans un autre
-- fichier ouvert dans un AUTRE terminal (donc une autre instance nvim) ne
-- marche jamais, chaque instance ayant ses propres registres.
vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = false    -- IMPORTANT : garder les tabulations, ne pas convertir en espaces
vim.opt.tabstop = 4          -- largeur visuelle d'une tabulation = 4 espaces
vim.opt.shiftwidth = 4       -- indentation automatique = 4 (en tabulations)
vim.opt.softtabstop = 4      -- indentation quand tu appuies sur Tab = 4
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.colorcolumn = "80"

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
