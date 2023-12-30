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
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {'nvim-lua/plenary.nvim'}
    },
    {
        'rose-pine/neovim', 
        name = 'rose-pine',
        config = function()
            vim.cmd('colorscheme rose-pine')
        end
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = function()
            require("nvim-treesitter.install").update({ with_sync = true })()
        end,
    },
	'nvim-treesitter/playground',
	'nvim-lua/plenary.nvim',
	'ThePrimeagen/harpoon',
	'mbbill/undotree',
	'tpope/vim-fugitive',
    'kevinhwang91/nvim-bqf',
    "lewis6991/gitsigns.nvim",
    "lukas-reineke/indent-blankline.nvim",
    'windwp/nvim-autopairs',
    "ggandor/leap.nvim",
    "godlygeek/tabular",
    "sindrets/diffview.nvim",
    "tpope/vim-repeat",
    "tpope/vim-surround",
    "numToStr/Comment.nvim",
    {
        'junegunn/fzf', 
        build = function()
            vim.fn['fzf#install']()
        end
    },
    -- LSP ZERO
    {'williamboman/mason.nvim'},
    {'williamboman/mason-lspconfig.nvim'},
    {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
    {'neovim/nvim-lspconfig'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'hrsh7th/nvim-cmp'},
    {'L3MON4D3/LuaSnip'},
})
