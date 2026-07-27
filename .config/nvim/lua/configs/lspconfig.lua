require("nvchad.configs.lspconfig").defaults()

-- read :h vim.lsp.config for changing options of lsp servers

-- Désactive l'auto-insertion de #include à l'acceptation d'une completion :
-- les projets 42 centralisent tous les includes dans un seul header projet
-- (ex: cub3d.h), donc clangd ajoute sinon des #include redondants/indésirables
-- (ex: messages.h) au lieu de se fier à celui déjà inclus transitivement.
-- Doit être appelé AVANT vim.lsp.enable : enable() démarre immédiatement le
-- client pour un buffer déjà ouvert en utilisant l'état actuel du registre,
-- donc un vim.lsp.config() après coup arrive trop tard pour ce démarrage-là.
vim.lsp.config("clangd", {
  cmd = { "clangd", "--header-insertion=never" },
})

local servers = { "html", "cssls", "clangd" }
vim.lsp.enable(servers)
