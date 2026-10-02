-- Configuration pour nvim-tree

local options = {
	view = {
		preserve_window_proportions = true,
	},
	actions = {
		open_file = {
			resize_window = false,
		},
	},
	filters = {
		-- dotfiles = false sinon .config lui-même (un dossier qui commence
		-- par un point) disparaîtrait de l'arbo, ce qui viderait ce repo.
		-- .claude est exclu individuellement à la place, via custom.
		dotfiles = false,
		git_ignored = false,
		-- Regex Vim (vim.fn.match), pas Lua : \. pas %. pour un point littéral.
		custom = { "^\\.claude$" },
	},
}

return options
