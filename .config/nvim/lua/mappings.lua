require "nvchad.mappings"

local ui = require "utils.ui"

-- Commentaire bloc style norme 42 : /*\n** ...\n*/
local function toggle_42_block_comment(start_line, end_line)
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  local all_commented = #lines > 0
  for _, line in ipairs(lines) do
    if not line:match("^%s*%*%*") then
      all_commented = false
      break
    end
  end

  if all_commented then
    local new_lines = {}
    for _, line in ipairs(lines) do
      new_lines[#new_lines + 1] = line:gsub("^(%s*)%*%*%s?", "%1")
    end
    local line_above = vim.api.nvim_buf_get_lines(0, start_line - 2, start_line - 1, false)[1]
    local line_below = vim.api.nvim_buf_get_lines(0, end_line, end_line + 1, false)[1]
    if line_above and line_above:match("^%s*/%*%s*$") and line_below and line_below:match("^%s*%*/%s*$") then
      vim.api.nvim_buf_set_lines(0, start_line - 2, end_line + 1, false, new_lines)
    else
      vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, new_lines)
    end
  else
    local min_indent = nil
    for _, line in ipairs(lines) do
      if line ~= "" then
        local indent = line:match("^(%s*)") or ""
        if min_indent == nil or #indent < #min_indent then
          min_indent = indent
        end
      end
    end
    min_indent = min_indent or ""

    local new_lines = { min_indent .. "/*" }
    for _, line in ipairs(lines) do
      if line == "" then
        new_lines[#new_lines + 1] = min_indent .. "**"
      else
        new_lines[#new_lines + 1] = min_indent .. "** " .. line:sub(#min_indent + 1)
      end
    end
    new_lines[#new_lines + 1] = min_indent .. "*/"
    vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, new_lines)
  end
end

-- Redimensionner nvim-tree dynamiquement
vim.keymap.set('n', '<leader>+', function() ui.resize_nvim_tree(5) end, { noremap = true, silent = true, desc = "Increase nvim-tree width" })
vim.keymap.set('n', '<leader>-', function() ui.resize_nvim_tree(-5) end, { noremap = true, silent = true, desc = "Decrease nvim-tree width" })
-- Copier dans le presse-papiers système
vim.keymap.set('n', 'y', '"+y', { noremap = true, silent = true })
vim.keymap.set('n', 'yy', '"+yy', { noremap = true, silent = true })
vim.keymap.set('v', 'y', '"+y', { noremap = true, silent = true })
-- Couper dans le presse-papiers système
vim.keymap.set('n', 'd', '"+d', { noremap = true, silent = true })
vim.keymap.set('n', 'dd', '"+dd', { noremap = true, silent = true })
vim.keymap.set('v', 'd', '"+d', { noremap = true, silent = true })

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Terminal mode: exit to normal mode" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Garder la sélection visuelle après indentation
map("v", ">", ">gv")
map("v", "<", "<gv")

-- Bloc commentaire style 42 en mode visuel (remplace <leader>/ de nvchad)
map("v", "<leader>/", function()
  local s = vim.fn.line "v"
  local e = vim.fn.line "."
  if s > e then s, e = e, s end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
  toggle_42_block_comment(s, e)
end, { desc = "Toggle 42 block comment" })

-- Touche Copilot (Hyprland envoie <F13> via wtype) : rejoue <leader>/ en une
-- seule touche, sans dépendre du timing du leader (espace puis / séparés
-- s'est révélé peu fiable, cf. hyprland.lua).
map("n", "<F13>", "<leader>/", { remap = true, desc = "Toggle comment (touche Copilot)" })
map("v", "<F13>", "<leader>/", { remap = true, desc = "Toggle comment (touche Copilot)" })
