{ 
    base ? import ./env.nix,
}:
let
    dots = ./.;
    shellHook = ''
      ln -s /bin/zsh /bin/sh
      useradd -m sam
      su sam -c "
          export LANG=en_US.UTF-8
          export SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt
          sh ${dots}/bootstrap.sh ${dots}
          # Configure the shell environment
          export SHELL=${base.pkgs.zsh}/bin/zsh
          cd ~
          zsh
          exit
      "
    '';
in
base.pkgs.dockerTools.buildLayeredImage {
  name = "devbox";
  fromImage = base.pkgs.dockerTools.pullImage {
    imageName = "ubuntu";
    imageDigest = "sha256:10b61aabaaf0123f3670112057c3b3ccf27c808ddb892ba5a4e32366bff7f3fe";
    sha256 = "sha256-u1UCCUAkPIDCsEAxLwi3z2szxRGR7/atte319k5QxNM=";
  };
  contents = base.pkgs.buildEnv {
      name = "DevEnv";
      paths = base.packages ++ [
        base.pkgs.cacert
        base.pkgs.nix
      ];
  };
  config = {
    Cmd = [ "${base.pkgs.bash}/bin/bash" "-c" shellHook ];
  };
}
