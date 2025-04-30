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
    "rest-nvim/rest.nvim",   -- Postman for nvim
    'nvim-lua/plenary.nvim', -- Better lua programming
    -- YOU KNOW
    {
        "rusnasonov/harpoon",
        branch = "harpoon2",
        commit = "bfd6493", -- fixes key issue
        dependencies = { "nvim-lua/plenary.nvim" },
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
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        ---@type Flash.Config
        opts = {},
        -- stylua: ignore
        keys = {
            { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
            { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
            { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
            { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
            { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
        },
    },
    "godlygeek/tabular",      -- For fixing my gherkin tables
    "sindrets/diffview.nvim", -- For easy git diffs
    "tpope/vim-repeat",       -- Allows repeats for plugin keybindings
    "tpope/vim-surround",     -- Surronding stuff easy
    "tpope/vim-fugitive",     -- git wrapper
    "numToStr/Comment.nvim",  -- Commenting stuff easy
    'MunifTanjim/nui.nvim',   -- For some menus
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
    { 'L3MON4D3/LuaSnip' },
    -- Completion
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lua',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            -- Snippets
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
        }
    },
    -- AI
    {
        "olimorris/codecompanion.nvim",
        opts = {},
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
    },
})
