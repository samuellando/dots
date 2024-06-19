-- This file can be loaded by calling `lua require('plugins')` from your init.vim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    'nvim-lua/plenary.nvim', -- Better lua programming
    -- YOU KNOW
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" }
    },
    'samuellando/tmux-commander',
    'mbbill/undotree', -- See my undoos
    -- File manager
    {
        'stevearc/oil.nvim',
        dependencies = { "nvim-tree/nvim-web-devicons" }
    },
    'stefandtw/quickfix-reflector.vim',    -- Quick fix list editing.
    -- 'kevinhwang91/nvim-bqf',            -- A nice quickfix list plugin, with preview window. Conficts with previous
    "lewis6991/gitsigns.nvim",             -- add git difs in side bar
    "lukas-reineke/indent-blankline.nvim", -- shows indent guides
    'windwp/nvim-autopairs',               -- auto add pairs
    "ggandor/leap.nvim",                   -- for leaping around, with s and S as the additional motion.
    "godlygeek/tabular",                   -- For fixing my gherkin tables
    "sindrets/diffview.nvim",              -- For easy git diffs
    "tpope/vim-repeat",                    -- Allows repeats for plugin keybindings
    "tpope/vim-surround",                  -- Surronding stuff easy
    "tpope/vim-fugitive",                  -- git wrapper
    "numToStr/Comment.nvim",               -- Commenting stuff easy
    'MunifTanjim/nui.nvim',                -- For some menus
    -- Tree sitter stuff
    {
        "nvim-treesitter/nvim-treesitter",
        build = function()
            require("nvim-treesitter.install").update({ with_sync = true })()
        end,
    },
    'nvim-treesitter/playground',
    -- Telescope stuff
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
        'junegunn/fzf',
        build = function()
            vim.fn['fzf#install']()
        end
    },
    -- My theme
    {
        "sainnhe/gruvbox-material",
        lazy = false,
        config = function()
            vim.g.gruvbox_material_enable_italic = true
            vim.cmd.colorscheme('gruvbox-material')
        end
    },
    'nvim-lualine/lualine.nvim',
    -- LSP ZERO
    { 'williamboman/mason.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },
    { 'mhartington/formatter.nvim' },
    { 'VonHeikemen/lsp-zero.nvim',        branch = 'v3.x' },
    { 'neovim/nvim-lspconfig' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/nvim-cmp' },
    { 'L3MON4D3/LuaSnip' },
    -- NEORG
    {
        "vhyrro/luarocks.nvim",
        priority = 1000,
        config = true,
    },
    {
        "nvim-neorg/neorg",
        dependencies = { "luarocks.nvim" },
        version = "*",
        config = function()
            require("neorg").setup {
                load = {
                    ["core.defaults"] = {},
                    ["core.journal"] = {
                        config = {
                            strategy = "flat",
                            workspace = "notes"
                        }
                    },
                    ["core.concealer"] = {},
                    ["core.dirman"] = {
                        config = {
                            workspaces = {
                                notes = "~/Documents/brain",
                            },
                            default_workspace = "notes",
                        },
                    },
                },
            }
        end,
    }
})
