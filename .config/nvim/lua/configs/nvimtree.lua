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
		dotfiles = false,
		git_ignored = false,
	},
}

return options
