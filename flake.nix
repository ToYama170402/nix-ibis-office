{
  description = "Flake for ibis-office";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "ibis-office";
          version = "0.8.1";
          cargoPatches = [ ./fix-build4linux.patch ];
          doCheck = false;

          src = pkgs.fetchFromGitHub {
            owner = "ibisjp";
            repo = "ibis-office";
            rev = "v0.8.1";
            hash = "sha256-L5WJUZ8pSo2TDZzbBomempLmW5M1zzxMfi9zEe7XRhw=";
            fetchSubmodules = true;
          };

          cargoHash = "sha256-CtOZq7+pJKABIsruuaMAf8r2gFSBD4mZysZiR/1pHm8=";

          nativeBuildInputs = with pkgs; [
            pkg-config
            makeWrapper
          ];

          buildInputs = with pkgs; [
            fontconfig
            libxcb
            libxkbcommon
            wayland
          ];

          postFixup = ''
            for bin in $out/bin/*; do
              wrapProgram "$bin" \
                --prefix LD_LIBRARY_PATH : "${
                  pkgs.lib.makeLibraryPath (
                    with pkgs;
                    [
                      wayland
                      libxkbcommon
                      libglvnd
                      vulkan-loader
                      xorg.libX11
                      xorg.libXcursor
                      xorg.libXi
                      xorg.libxcb
                    ]
                  )
                }"
            done
          '';

        };

        formatter = pkgs.nixfmt;
      }
    );
}
