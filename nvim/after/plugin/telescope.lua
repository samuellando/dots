local builtin = require('telescope.builtin')

function getVisualSelection()
	vim.cmd('noau normal! "vy"')
	local text = vim.fn.getreg('v')
	vim.fn.setreg('v', {})

	text = string.gsub(text, "\n", "")
	if #text > 0 then
		return text
	else
		return ''
	end
end

vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>pl', builtin.live_grep, {})
vim.keymap.set('v', '<leader>pl', function() 
	builtin.live_grep({ default_text = getVisualSelection() })
end)
