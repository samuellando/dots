{
    description = "Dev environment with Neovim some dev tools and some plugins";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    outputs = {self, nixpkgs}:
    let 
      system = builtins.currentSystem;
      pkgs = import nixpkgs { inherit system; };
      packages = with pkgs; [
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
      ];
      containerPackages = packages ++ [
        pkgs.cacert
        pkgs.nix
      ];
    in
    { 
      pkgs = pkgs;
      buildContainer = {extraPackages ? [], extraShellHooks ? ""} : 
          let 
            dots = self;
            shellHook = ''
              ln -s /bin/zsh /bin/sh
              export LANG=en_US.UTF-8
              export SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt
              sh ${dots}/bootstrap.sh ${dots}
              # Make nix use the same lock file as this build.
              cp ${dots}/flake.nix ~/.config/nix
              cp ${dots}/flake.lock ~/.config/nix
              # Configure the shell environment
              export SHELL=${pkgs.zsh}/bin/zsh
              ${extraShellHooks}
              cd ~
              zsh
              exit
            '';
          in
          pkgs.dockerTools.buildLayeredImage {
              name = "devbox";
              fromImage = pkgs.dockerTools.pullImage {
                imageName = "ubuntu";
                imageDigest = "sha256:10b61aabaaf0123f3670112057c3b3ccf27c808ddb892ba5a4e32366bff7f3fe";
                sha256 = "sha256-u1UCCUAkPIDCsEAxLwi3z2szxRGR7/atte319k5QxNM=";
              };
              contents = pkgs.buildEnv {
                  name = "ContainerPackages";
                  paths = containerPackages ++ extraPackages; 
              };
              config = {
                Cmd = [ "${pkgs.bash}/bin/bash" "-c" shellHook ];
              };
          };

      packages.${system} = {
         default = pkgs.buildEnv {
          name = "MyDevEnv";
          paths = packages;
         };
         container = self.outputs.buildContainer {};
    };
    };
}
