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
                /* tools */
                telescope-nvim
                harpoon2
                oil-nvim
                codecompanion-nvim
                vim-fugitive
                undotree
                flash-nvim
                diffview-nvim
                nvim-autopairs
                comment-nvim
                quickfix-reflector-vim
                tabular
                /* lsp stuff */
                nvim-lspconfig
                nvim-lint
                /* Code completions */
                blink-cmp
                /* Code naviagation */
                flash-nvim
                /* Visual */
                gruvbox-material
                nvim-treesitter.withAllGrammars
                lualine-nvim
                indent-blankline-nvim
                nui-nvim
                gitsigns-nvim
                /* Dependencies */
                vim-repeat
                vim-sensible
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
