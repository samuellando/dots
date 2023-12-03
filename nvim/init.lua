require("sam")

require('telescope').setup {
    pickers = {
      find_files = {
        follow = true
      }
    }
}

--[====[
vim.filetype.add({
    extension = {
        rave = "rave"
    }
})
--]====]
--[====[
local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.rave = {
    install_info = {
        url = "~/Documents/tree-sitter-rave", -- local path or git repo
        files = {"src/parser.c"}, -- note that some parsers also require src/scanner.c or src/scanner.cc
        generate_requires_npm = false, -- if stand-alone parser without npm dependencies
        requires_generate_from_grammar = true, -- if folder contains pre-generated src/parser.c
        filetype = "rave"
    }
}

--]====]
