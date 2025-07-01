let
  nixpkgs = (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/tarball/nixpkgs-unstable";
      sha256 = "sha256:1qxlkg1py7c91gcf5a8nb72gxsn228ngx4mq9grw01m4jk6qi590";
  });

  pkgs = import nixpkgs { config = {}; overlays = []; };

  dots = pkgs.fetchFromGitHub {
      owner = "samuellando";
      repo = "dots";
      rev = "a138ca7af1c8a23a389d87a8a798acccaa034591";
      sha256 = "sha256-sYc4bbAGMXrizIqkM5IBIMbOUM5pWmqi+Y8F0CvJehc=";
  };
in


pkgs.mkShellNoCC {
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

  shellHook = ''
    # Symlink all the config files
    mkdir -p ~/.config
    for d in $(ls ${dots}/config); do
        [ -e ~/.config/$d ] || ln -s ${dots}/config/$d ~/.config/$d
    done
    # Symlink all the user scripts
    [ -e ~/bin ] || ln -s ${dots}/bin ~/bin
    # Configure the shell environment
    export SHELL=${pkgs.fish}/bin/fish
    if [ -z "$TMUX" ]; then
      tmux
    else
        exec $SHELL
    fi
  '';
}
