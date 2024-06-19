local harpoon = require("harpoon")

harpoon:setup({
    settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
        -- key = function()
        --     return string.gsub(
        --         vim.loop.cwd() .. "/" .. vim.fn.system("git branch --show-current"),
        --         "\n",
        --         ""
        --     )
        -- end,
    }
})

vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<leader>e", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<C-j>", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<C-k>", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<C-l>", function() harpoon:list():select(4) end)
