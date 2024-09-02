with import <nixpkgs> {};

(
	let	
		pythonPackages = python311;
		
		enum_tools = callPackage ./enum_tools.nix {
			pythonPackages = pythonPackages.pkgs;
		};

		quokka-project = callPackage ./quokka_project.nix {
			pythonPackages = pythonPackages.pkgs;
		};

		PyQBDI = callPackage ./pyQBDI.nix {
			pythonPackages = pythonPackages.pkgs;
			enum_tools = pythonPackages.withPackages (ps: [ enum_tools ]);
			quokka_project = pythonPackages.withPackages (ps: [ quokka-project ]);
		};

		triton-library = callPackage ./triton-library.nix {
			pythonPackages = pythonPackages.pkgs;
		};

		tritondse = callPackage ./tritondse.nix {
			pythonPackages = pythonPackages.pkgs;
			enum_tools = pythonPackages.withPackages (ps: [ enum_tools ]);
			quokka_project = pythonPackages.withPackages (ps: [ quokka-project ]);
			PyQBDI = pythonPackages.withPackages (ps: [ PyQBDI ]);
			triton-library = pythonPackages.withPackages (ps: [ triton-library ]);
		};

	in pythonPackages.withPackages (ps: [
		tritondse
		enum_tools
		triton-library
		quokka-project
	])
).env
