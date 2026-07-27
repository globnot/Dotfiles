-- Utilitaires pour l'interface utilisateur

local M = {}

-- Redimensionner la fenêtre nvim-tree
M.resize_nvim_tree = function(delta)
	for _, win in pairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype == "NvimTree" then
			local width = vim.api.nvim_win_get_width(win)
			vim.api.nvim_win_set_width(win, width + delta)
			break
		end
	end
end

return M
