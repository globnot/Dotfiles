require "nvchad.autocmds"

-- Forcer les fichiers .h à être reconnus comme du C
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.h",
  callback = function()
    vim.bo.filetype = "c"
  end,
})

-- Norme 42 : utiliser /* */ au lieu de // pour les commentaires C/C++
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    vim.opt_local.commentstring = "/* %s */"
  end,
})
