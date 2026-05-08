{
  description = "Flyscrape: A command-line web scraping tool";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        version = "0.9.0";

        # Map Nix systems to flyscrape architecture strings
        osMap = {
          "x86_64-linux" = "linux_amd64";
          "aarch64-linux" = "linux_arm64";
          "x86_64-darwin" = "darwin_amd64";
          "aarch64-darwin" = "darwin_arm64";
        };

        hashMap = {
          "x86_64-linux" = "3e37460af537c57c00976de9068d0af0235f0139aa3efcd331cb8ba83f65ff04";
          "aarch64-linux" = "95cfd0da8f5ba233f26fdeb5e6864861d92dffcdb9ab3310154076aa6f94373a";
          "x86_64-darwin" = "edba18094d0b4daed899b5f196e7af2b13abb941ec75f846663f2a77bb68019d";
          "aarch64-darwin" = "8b03765f3cc5687c5d686c7142873ae6cc3d14361e70cfc6c2e7566d28502ba1";
        };

        target = osMap.${system} or (throw "Unsupported system: ${system}");
        sha256 = hashMap.${system} or (throw "Unsupported system: ${system}");

        url = "https://github.com/philippta/flyscrape/releases/download/v${version}/flyscrape_${version}_${target}.tar.gz";
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "flyscrape";
          inherit version;

          src = pkgs.fetchurl {
            inherit url sha256;
          };

          sourceRoot = ".";

          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin
            cp flyscrape $out/bin/
            chmod +x $out/bin/flyscrape
            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "Flyscrape is a command-line web scraping tool designed for those without advanced programming skills.";
            homepage = "https://flyscrape.com";
            license = licenses.mpl20;
            maintainers = [ ];
          };
        };
      }
    );
}
