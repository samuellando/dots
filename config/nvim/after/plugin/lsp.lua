
vim.keymap.set("n", "gh", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.lsp.enable("lua_ls")
vim.lsp.enable("pylsp")
vim.lsp.enable("gopls")
