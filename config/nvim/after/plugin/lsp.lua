local lsp_zero = require('lsp-zero')

vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
vim.keymap.set("n", "<leader>gh", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition)
vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references)
vim.keymap.set("n", "<leader>grn", vim.lsp.buf.rename)

-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
require("formatter").setup({
    filetype = {
        -- Formatter configurations for filetype "lua" go here
        -- and will be executed in order
        xml = {
            -- "formatter.filetypes.lua" defines default configurations for the
            -- "lua" filetype
            require("formatter.filetypes.xml").xmlformat
        }
    }
})

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = { "lua_ls", "pylsp", "marksman" },
    handlers = {
        lsp_zero.default_setup,
        lua_ls = function()
            local lua_opts = lsp_zero.nvim_lua_ls()
            require('lspconfig').lua_ls.setup(lua_opts)
        end,
        pylsp = function()
            local py_opts = {
                settings = {
                    autopep8 = {
                        enabled = false
                    },
                    pylsp = {
                        plugins = {
                            pycodestyle = {
                                enabled = true,
                                ignore = { 'E501', 'E231' },
                                maxLineLength = 240
                            }
                        }
                    }
                }
            }
            require('lspconfig').pylsp.setup(py_opts)
        end,
    }
})
