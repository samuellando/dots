vim.api.nvim_create_autocmd("BufEnter", {
    callback = function ()
        pcall(vim.treesitter.start)
    end
})
