{
  description = "Development environment for the Idris 2 LLVM C bindings";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

  outputs = { nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          llvm = pkgs.llvmPackages_22.llvm;
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.cmake
              pkgs.idris2
              pkgs.idris2Packages.pack
              llvm
              llvm.dev
            ];

            LLVM_CONFIG = "${llvm.dev}/bin/llvm-config";
            LLVM_DIR = "${llvm.dev}/lib/cmake/llvm";
          };
        });
    };
}
