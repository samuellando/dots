local flash = require("flash")

vim.keymap.set({"n", "x", "o"}, "s", flash.jump)
vim.keymap.set({"n", "x", "o"}, "S", flash.treesitter)
