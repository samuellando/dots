let
  nixpkgs = (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/b9c03fbbaf84d85bb28eee530c7e9edc4021ca1b.tar.gz";
      sha256 = "sha256:19wkjfhyidvkp4wjrr7idx83iiql6bskp1x1wrp52y0lc3xx847y";
  });

  pkgs = import nixpkgs { config = {}; overlays = []; };

  dots = ./.;

  packages = with pkgs; [
    python312
    fzf
    tmux
    fish
    zsh
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

  shell = pkgs.mkShellNoCC {
  packages = packages;
  shellHook = ''
    # Symlink all the config files
    mkdir -p ~/.config
    for d in $(ls ${dots}/config); do
        [ -e ~/.config/$d ] || ln -s ${dots}/config/$d ~/.config/$d
    done
    # Symlink all the user scripts
    [ -e ~/bin ] || ln -s ${dots}/bin ~/bin
    [ -e ~/.zshenv ] || ln -s ${dots}/.zshenv ~/.zshenv
    [ -e ~/.fishrc.fish ] || cp ${dots}/.fishrc.fish ~/.fishrc.fish
    # Configure the shell environment
    export SHELL=${pkgs.zsh}/bin/zsh
    if [ -z "$TMUX" ]; then
      tmux
      exit
    else
      exec $SHELL
      exit
    fi
  '';
  };
in
{
  inherit shell packages pkgs;
}
