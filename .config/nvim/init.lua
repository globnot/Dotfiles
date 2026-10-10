vim.g.mapleader = " "

-- Login 42 pour le header std (plugin/stdheader.vim) : indépendant de $USER
-- système, qui vaut "globnot" ici, pas le login étudiant.
vim.g.user42 = "aborda"

require "options"
require "autocmds"
require "mappings"
