vim.g.mapleader = " "

-- Split windows -- 
vim.keymap.set("n", "<leader>vs", ':vsplit<CR>')
vim.keymap.set("n", "<leader>s", ':split<CR>')

-- Moving between windows --
vim.keymap.set("n", "<leader>l", '<C-w>l')
vim.keymap.set("n", "<leader>h", '<C-w>h')
vim.keymap.set("n", "<leader>j", '<C-w>j')
vim.keymap.set("n", "<leader>k", '<C-w>k')

-- Spelling --
vim.keymap.set("n", "<leader>sp", function()
   vim.opt.spell = not(vim.opt.spell:get())
end)

-- Moving highlighted lines up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
local handle = io.popen('cat /etc/*-release | grep "DISTRIB_ID"')
if handle ~= nil then
    local distrib = handle:read("*a")

    handle:close()
    if string.find(distrib, "Ubuntu") then
        vim.keymap.set({"n", "v"}, "<leader>y", "y:call system('nc -q 0 host.docker.internal 8377', @0)<CR>")
    else
        vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
    end
end
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<leader>fr", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>cp", ":Copilot panel<CR>")
