{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
	pname = "find-crypt-ghidra";
	version = "1.5";

	src = fetchFromGitHub {
		owner = "d3v1l401";
		repo = "FindCrypt-Ghidra";
		rev = version;
		hash = "sha256-krePh79CgngLT36DZEr3cUgC5Qe5cZtxuj0u5WDSKc4=";
	};

	dontUnpack = true;

	buildPhase = ''
	'';
	
	installPhase = ''
		ghidraScripts="$out/lib/ghidra/Ghidra/Features/BytePatterns/ghidra_scripts"
		
		mkdir -p "$ghidraScripts"
	
		cp "$src/FindCrypt.java" "$out/lib/ghidra/Ghidra/Features/BytePatterns/ghidra_scripts"
  	'';
}
