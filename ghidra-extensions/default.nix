{ callPackage
, symlinkJoin
, ghidra
, makeWrapper
}:

	let 
		plugins = [
			(callPackage ./find-crypt-ghidra {})
		];
	in symlinkJoin {
		name = "ghidra-extensions";
		paths = [ ghidra ] ++ plugins;

		nativeBuildInputs = [ makeWrapper ];

		postBuild = ''
			wrapProgram $out/lib/ghidra/ghidraRun --set GHIDRA_HOME "$out/lib/ghidra"
		'';
	}
