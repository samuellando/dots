{
  description = ''
    Dev environment setup, meant to get everything up and running
    quickly and consistently.

    nvim + tmux

    Trying to include all the tool needed. However the OS package manager
    should be used to install other stuff, such as programming languages.
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
      dotfilesFor = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        pkgs.stdenv.mkDerivation {
          name = "dots";
          src = self;
          installPhase = ''
            mkdir -p $out/share/home
            cp $src/.zshenv $out/share/home/.zshenv
            cp $src/.fishrc.fish $out/share/home/
            cp $src/.crontab $out/share/home/
            cp $src/.anacrontab $out/share/home/
            cp -r $src/config $out/share/home/
            mkdir -p $out/bin
            cp $src/bootstrap_dots $out/bin/bootstrap_dots
            cp $src/bin/* $out/bin
          '';
        });
      packagesFor = forAllSystems (system: with nixpkgsFor.${system}; [
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
                nvim-lint
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
          paths = packagesFor.${system} ++ [ dotfilesFor.${system} ];
        };
      });
    };
}
