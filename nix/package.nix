{
  bun,
  bun2nix,
  lib,
  makeWrapper,
  ...
}: let
  packageJson = lib.importJSON ../package.json;
in
  bun2nix.mkDerivation {
    pname = "hunkdiff";
    version = packageJson.version;

    src = ../.;

    bunDeps = bun2nix.fetchBunDeps {
      bunNix = ./bun.lock.nix;
    };

    nativeBuildInputs = [
      bun
      makeWrapper
    ];

    buildPhase = ''
      runHook preBuild
      bun run build:npm
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/$pname $out/bin
      cp -r ./dist/npm $out/share/$pname/dist
      cp -r ./skills $out/share/$pname/
      cp -p ./README.md $out/share/$pname/
      cp -p ./LICENSE $out/share/$pname/

      makeWrapper ${bun}/bin/bun $out/bin/hunk \
        --add-flags "$out/share/$pname/dist/main.js"

      runHook postInstall
    '';

    # Keep the installed command as a thin wrapper so the package does not
    # embed Bun into the resulting bin/hunk artifact.
    dontFixup = true;
    dontStrip = true;
    dontRunLifecycleScripts = true;

    meta = with lib; {
      description = "Terminal diff viewer for agentic changesets";
      homepage = "https://github.com/modem-dev/hunk";
      license = licenses.mit;
      mainProgram = "hunk";
      platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    };
  }
