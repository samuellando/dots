let 
  nixpkgs = (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/b9c03fbbaf84d85bb28eee530c7e9edc4021ca1b.tar.gz";
      sha256 = "sha256:19wkjfhyidvkp4wjrr7idx83iiql6bskp1x1wrp52y0lc3xx847y";
  });
  pkgs = import nixpkgs { config = {}; overlays = []; };
in
{ 
  pkgs = pkgs;
  DevEnv = let
  packages = with pkgs; [
    python312
    fzf
    tmux
    fish
    zsh
    git
    (neovim.override {
      vimAlias = true;
      viAlias = true;
      configure = {
        customLuaRC = ''
            require("sam")
            vim.g.gruvbox_material_enable_italic = true
            vim.cmd.colorscheme('gruvbox-material')
        '';
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [ 
            telescope-nvim
            codecompanion-nvim
            nvim-cmp
            harpoon2
            luasnip
            oil-nvim
            lualine-nvim
            lsp-zero-nvim
            vim-sensible
            formatter-nvim
            indent-blankline-nvim
            mason-nvim
            nui-nvim
            nvim-treesitter.withAllGrammars
            mason-lspconfig-nvim
            gitsigns-nvim
            nvim-autopairs
            comment-nvim
            vim-fugitive
            rest-nvim
            undotree
            flash-nvim
            tabular
            diffview-nvim
            vim-repeat
            vim-surround
            gruvbox-material
            quickfix-reflector-vim
          ];
        };
      };
    })
  ];
in
  pkgs.buildEnv {
      name = "DevEnv";
      paths = packages;
  };
}
