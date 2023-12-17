{
  description = "Game Design Document for 'Maze Shift Mayhem'";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;
    flake-utils.url = github:numtide/flake-utils;
  };
  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib; eachSystem allSystems (system:
    let
      pkgs = import nixpkgs { inherit system; };
      latex = pkgs.texlive.combine {
        # https://tug.org/svn/texlive/trunk/Master/tlpkg/tlpsrc/
        inherit (pkgs.texlive) scheme-medium 
        collection-fontsextra
        collection-fontsrecommended
        collection-fontutils
        collection-latex
        collection-latexextra
        collection-latexrecommended
        collection-xetex;
      };
      pkgName = "maze-shift-mayhem-design-doc";
      document = "design-doc";
    in rec {
      packages = {
        default = pkgs.stdenv.mkDerivation rec {
          name = pkgName;
          src = self;
          buildInputs = with pkgs; [
            coreutils fontconfig gawk ncurses
          ] ++ [ latex ];
          phases = [ "unpackPhase" "buildPhase" "installPhase" ];
          buildPhase = ''
            export PATH="${pkgs.lib.makeBinPath buildInputs}";
            mkdir -p .cache/texmf-var

            # Why? https://stackoverflow.com/questions/77331227/fontconfig-error-no-writable-cache-directories
            export HOME="$(pwd)";
            export TEXMFHOME=".cache";
            export TEXMFVAR=".cache/texmf";
            export SOURCE_DATE_EPOCH="${toString self.lastModified}";

            LTX_FLAGS=("-interaction=nonstopmode" "-shell-escape" "-cd" "-pdf" "-xelatex")

            latexmk ''${LTX_FLAGS[@]} ${document}.tex
          '';
          installPhase = ''
            mkdir -p $out
            cp ${document}.{pdf,log} $out/
          '';
        };
      };
      devShell = pkgs.mkShell {
        inputsFrom = builtins.attrValues self.packages.${system};
      };
    });
}
