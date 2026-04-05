{
  lib,
  buildGhidraExtension,
  fetchurl,
}:

buildGhidraExtension {
  pname = "ghidrassist";
  version = "1.26.0";

  src = fetchurl {
    url = "https://github.com/symgraph/GhidrAssist/releases/download/1.26.0/ghidra_12.0_PUBLIC_20260403_GhidrAssist.zip";
    sha256 = "12yyj630p807kwmxyzvj59q6c74d93v56p692853zx3wl6lbny1a";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/ghidra/Ghidra/Extensions
    unzip -d $out/lib/ghidra/Ghidra/Extensions $src
    runHook postInstall
  '';

  meta = {
    description = "LLM extension for Ghidra for AI-assisted reverse engineering";
    homepage = "https://github.com/symgraph/GhidrAssist";
    license = lib.licenses.mit;
  };
}
