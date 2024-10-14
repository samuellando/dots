local open = false
vim.keymap.set('n', '<leader>d', function()
    if open then
        open = false
        vim.cmd("DiffviewClose")
    else
        open = true
        vim.cmd("DiffviewOpen")
    end
end)

vim.keymap.set('n', '<leader>dm', function()
    if open then
        open = false
        vim.cmd("DiffviewClose")
    else
        open = true
        vim.cmd("DiffviewOpen origin/master")
    end
end)
