{
  lib,
  cmake,
  idris2Packages,
  llvmPackages_22,
}:

let
  llvm = llvmPackages_22.llvm;

  package = idris2Packages.buildIdris {
    ipkgName = "idris2-llvm-c";
    version = "0.1.0";
    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./llvm-c.ipkg
        ./README.md
        ./src
        ./support/CMakeLists.txt
        ./support/build.sh
        ./support/clean.sh
        ./support/include
        ./support/install.sh
        ./support/src
        ./support/tests
      ];
    };
    idrisLibraries = [ ];

    nativeBuildInputs = [ cmake ];
    buildInputs = [
      llvm
      llvm.dev
    ];

    LLVM_CONFIG = "${llvm.dev}/bin/llvm-config";
    LLVM_DIR = "${llvm.dev}/lib/cmake/llvm";

    # The ipkg prebuild hook configures the shim in support/build itself.
    dontUseCmakeConfigure = true;

    # Idris loads %foreign libraries at runtime instead of linking them into
    # downstream executables. Use the exported package's absolute shim path so
    # those executables retain the package in their Nix closure and can run
    # without setting LD_LIBRARY_PATH or DYLD_LIBRARY_PATH themselves.
    postPatch = ''
      grep -rlZ ',libidris2_llvm"' src | while IFS= read -r -d "" source_file; do
        substituteInPlace "$source_file" \
          --replace-fail ',libidris2_llvm"' ",$out/lib/libidris2_llvm\""
      done
    '';
  };
in
(package.library { withSource = true; }).overrideAttrs (oldAttrs: {
  postInstall = (oldAttrs.postInstall or "") + ''
    package_dir="$(idris2 --dump-installdir llvm-c.ipkg)"
    mkdir -p "$out/include" "$package_dir/lib"

    install -m 0755 lib/libidris2_llvm "$out/lib/"
    for shared_library in lib/libidris2_llvm.so lib/libidris2_llvm.dylib; do
      if [ -f "$shared_library" ]; then
        install -m 0755 "$shared_library" "$out/lib/"
      fi
    done
    install -m 0644 include/idris2_llvm.h "$out/include/"

    ln -s "$out/lib/libidris2_llvm" "$package_dir/lib/"
    for shared_library in "$out/lib/libidris2_llvm.so" "$out/lib/libidris2_llvm.dylib"; do
      if [ -f "$shared_library" ]; then
        ln -s "$shared_library" "$package_dir/lib/"
      fi
    done
    ln -s "$out/include/idris2_llvm.h" "$package_dir/lib/"
  '';

  meta = {
    description = "Idris 2 bindings for the LLVM 22 C API";
    license = lib.licenses.WITH lib.licenses.asl20 lib.licenses.llvm-exception;
    platforms = lib.platforms.unix;
  };
})
