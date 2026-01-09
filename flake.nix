{
    description = "Dev environment with Neovim some dev tools and some plugins";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    outputs = {self, nixpkgs}:
    let 
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      packagesFor = forAllSystems (system: with nixpkgsFor.${system}; [
            (python312.withPackages (python-pkgs: [
              python-pkgs.requests
            ]))
            fzf
            tmux
            curl
            wget
            ripgrep
            unzip
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
                    cmp-nvim-lua
                    cmp-nvim-lsp
                    cmp-buffer
                    cmp-path
                    cmp-cmdline
                    luasnip
                    cmp_luasnip
                    harpoon2
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
          ]);
        in
        {
          packages = forAllSystems (system: {
             default = nixpkgsFor.${system}.buildEnv {
              name = "MyDevEnv";
              paths = packagesFor.${system};
             };
        });
    };
}
