require("sam")

vim.api.nvim_create_autocmd({"BufEnter"}, {
  pattern = {"*.feature"},
  command = "filetype detect",
})

-- Rave language syntax highlighting
vim.filetype.add({
    extension = {
        rave = "rave"
    }
})
vim.filetype.add {
  pattern = {
    ['.*'] = {
      priority = -math.huge,
      function(path, bufnr)
        local content = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ''
        if vim.regex("crc"):match_str(content) ~= nil then
          return 'rave'
        end
      end,
    },
  },
}

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
