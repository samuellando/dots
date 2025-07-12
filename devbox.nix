{ 
    base ? import ./env.nix,
}:
let
    dots = ./.;
    shellHook = ''
      export LANG=en_US.UTF-8
      sh ${dots}/bootstrap.sh ${dots}
      # Configure the shell environment
      export SHELL=${base.pkgs.zsh}/bin/zsh
      zsh
      exit
    '';
in


base.pkgs.dockerTools.buildImage {
  name = "devbox";
  fromImage = base.pkgs.dockerTools.pullImage {
    imageName = "ubuntu";
    imageDigest = "sha256:10b61aabaaf0123f3670112057c3b3ccf27c808ddb892ba5a4e32366bff7f3fe";
    sha256 = "sha256-u1UCCUAkPIDCsEAxLwi3z2szxRGR7/atte319k5QxNM=";
  };
  copyToRoot = base.DevEnv;
  runAsRoot = ''
    ${base.pkgs.dockerTools.shadowSetup}
    ln -s /bin/zsh /bin/sh
    useradd -m sam
  '';
  config = {
    user = "sam";
    WorkingDir = "/home/sam";
    Cmd = [ "${base.pkgs.bash}/bin/bash" "-c" shellHook ];
  };
}
