# cad-python — a Python environment for scripted mechanical CAD.
#
# Why this exists: build123d — and the OCP/OCCT binding under it — is NOT in
# nixpkgs. `cadquery` was *removed* from 25.05 ("disabled on all python
# versions since 3.8 and marked as broken") and `build123d` / `ocp` /
# `cadquery-ocp` were never packaged at all. Upstream ships manylinux wheels,
# so the eight missing distributions are vendored below as pinned wheels,
# autoPatchelf'd against the few libs the OCCT binding actually needs.
# Everything else comes from nixpkgs normally, with NO overrides of the shared
# python set — a deliberate constraint; see the build123d pin below.
#
# Lives in pkgsnix (not nix-config/pkgs) so it is reachable bare as
# `cad-python` through the `additions` overlay, from any consumer.
#
# The exposed binary is deliberately named `cadpython`, NOT `python3`: the dev
# profile ships `(lib.hiPrio python3)` and the radio profile a
# `python311.withPackages` env, and a third interpreter claiming `bin/python3`
# would join that collision (see the python3 comment in nix-config's
# home-manager/profiles/dev.nix, which is what installs this).
# `passthru.env` is the unwrapped environment for use in other expressions.
#
# What it is for (BH3_Stage_Automation and future mechanical work):
#   - build123d  : B-rep modelling on OCCT; exact STEP/DXF export, real arcs,
#                  and geometric *interrogation* (distance, interference,
#                  volume) which OpenSCAD cannot do at all
#   - ezdxf      : read the exported DXF back and audit it against the laser
#                  service's rules (min hole diameter >= t/2, sheet envelope)
#   - trimesh +  : fast mesh booleans/proximity — sweeping a moving assembly
#     manifold3d   through its travel envelope and checking interference at
#                  every pose, otherwise a PLA-and-fingers test
#   - numpy/scipy: the sweep maths
#
# Update procedure: bump `version` + `hash` per wheel. Get a hash with
#   nix store prefetch-file --hash-type sha256 <url>
# choosing the cp3xx-manylinux_*_x86_64 wheel for binary packages and the
# py3-none-any wheel otherwise. The cp3xx MUST match `python3` in the base
# channel (25.05 => 3.12) or the OCP wheel will not import.
{ lib
, python3
, fetchurl
, autoPatchelfHook
, stdenv
, libGL
, expat
, xorg
, zlib
, runCommand
}:

let
  python = python3.override {
    self = python;
    packageOverrides = final: prev:
      let
        # Pure-python wheels: unpack and go. `dontCheckRuntimeDeps` because
        # nixpkgs' webcolors (24.11.1) sits outside build123d's cosmetic
        # `~=24.8.0` pin. The flag only silences the *metadata* check — where a
        # pin reflects a real API requirement the build still fails loudly at
        # pythonImportsCheck, so keep that on anything load-bearing.
        wheel =
          { pname
          , version
          , url
          , hash
          , deps ? [ ]
          , attrs ? { }
          }:
          final.buildPythonPackage ({
            inherit pname version;
            format = "wheel";
            src = fetchurl { inherit url hash; };
            propagatedBuildInputs = deps;
            doCheck = false;
            dontCheckRuntimeDeps = true;
          } // attrs);
      in
      {
        trianglesolver = wheel {
          pname = "trianglesolver";
          version = "1.2";
          url = "https://files.pythonhosted.org/packages/ff/8e/43d45cf3e18e3f455e4b5ab333a7c27b8e38c4e535f7346b7148ce08eb65/trianglesolver-1.2-py3-none-any.whl";
          hash = "sha256-qgkDw3CLTitJbwbUkMrnLG/2J0sA0e3OQg/Po7K3ZoI=";
          deps = [ final.numpy ];
        };

        # Binary wheel, but only wants libstdc++.
        lib3mf = wheel {
          pname = "lib3mf";
          version = "2.5.0";
          url = "https://files.pythonhosted.org/packages/88/83/8b987ba95ac0ed9cc7e9c407a579bf43eff6349b1792b4a66c992ce4f76b/lib3mf-2.5.0-py3-none-manylinux2014_x86_64.whl";
          hash = "sha256-tMAAM8R8/qyTt9qgaftG6N6kOR1VIrec1un2r3XjMBM=";
          attrs = {
            nativeBuildInputs = [ autoPatchelfHook ];
            buildInputs = [ stdenv.cc.cc.lib ];
          };
        };

        # A small shim the other OCP consumers depend on by name.
        cadquery-ocp-proxy = wheel {
          pname = "cadquery-ocp-proxy";
          version = "7.9.3.1.1";
          url = "https://files.pythonhosted.org/packages/30/c0/04e9363a99fee892de2776820e3dcf04f8825b6edc9580efe3416c9465a7/cadquery_ocp_proxy-7.9.3.1.1-py3-none-any.whl";
          hash = "sha256-ykFk7EtUlW2fw+aMZ9VVtUhsuWPC9x4Y3wBboWuSHJE=";
        };

        # The OCCT binding itself: a ~150 MB .so. On NixOS `ldd` reports
        # exactly five unresolved DT_NEEDED entries — the buildInputs below.
        cadquery-ocp-novtk = wheel {
          pname = "cadquery-ocp-novtk";
          version = "7.9.3.1.1";
          url = "https://files.pythonhosted.org/packages/4d/32/8907aae7ee5c5c968a50a1d382a01854ca3abdc830a486e79dda64a66746/cadquery_ocp_novtk-7.9.3.1.1-cp312-cp312-manylinux_2_31_x86_64.whl";
          hash = "sha256-YEl89CQZ3SAA0yOrdyk39hU58vCl0+8bKIYRsTJUxYc=";
          deps = [ final.cadquery-ocp-proxy ];
          attrs = {
            nativeBuildInputs = [ autoPatchelfHook ];
            buildInputs = [
              stdenv.cc.cc.lib # libstdc++.so.6
              libGL # libGL.so.1
              expat # libexpat.so.1
              xorg.libX11 # libX11.so.6
              zlib # libz.so.1
            ];
            pythonImportsCheck = [ "OCP" ];
          };
        };

        ocpsvg = wheel {
          pname = "ocpsvg";
          version = "0.6.0";
          url = "https://files.pythonhosted.org/packages/a9/d7/27d2c9d5a2645fdda9e502a2a1a1cb5d4c9d137223ef76a43296eb7c152b/ocpsvg-0.6.0-py3-none-any.whl";
          hash = "sha256-XPxt6y9gLe2EVZZAnkH+j14bOJ4U6MxyfbCVXw6I3ns=";
          deps = [ final.cadquery-ocp-proxy final.svgelements ];
        };

        ocp-gordon = wheel {
          pname = "ocp_gordon";
          version = "0.2.2";
          url = "https://files.pythonhosted.org/packages/6c/d1/ee535cdbc502790dda6555e439ea8bcacdd38325859151769d109d307a94/ocp_gordon-0.2.2-py3-none-any.whl";
          hash = "sha256-ZBTpAaEQZaVug5yBtW9BgQC00Lgetaojux+Pcvl/8Jk=";
          deps = [ final.cadquery-ocp-proxy final.numpy final.scipy ];
        };

        svgpathtools = wheel {
          pname = "svgpathtools";
          version = "1.8.0";
          url = "https://files.pythonhosted.org/packages/1e/a3/bc588e2dd19274f715e95a89f5998098d8fb9301349e2545a84b1042df5e/svgpathtools-1.8.0-py2.py3-none-any.whl";
          hash = "sha256-eD9tMrN+HWCQ+zHVbmklkJaCsk7VDDYRGacy0aLGRvI=";
          deps = [ final.numpy final.svgwrite final.scipy ];
        };

        # Pinned to 0.11.x deliberately: 0.12+ hard-pins typing_extensions
        # >= 4.16 (for `sentinel`), which 25.05 does not have, and overriding
        # it rebuilds scikit-learn/shapely/manifold3d and friends on every
        # nixpkgs bump. 0.11 also predates the bd_materials/threejs-materials
        # dependency — 87 MB of PBR textures irrelevant to headless modelling.
        # Revisit when the base channel ships typing-extensions >= 4.16.
        build123d = wheel {
          pname = "build123d";
          version = "0.11.0";
          url = "https://files.pythonhosted.org/packages/f3/57/2c2910ca2fbe913b5cdea8ab50d5ef2d59bbe7c71400a965c442a9d9a506/build123d-0.11.0-py3-none-any.whl";
          hash = "sha256-IrzKpM8svcyRDxdOSfo1nX+1pUbPJFsMJuNU3VzC618=";
          deps = with final; [
            cadquery-ocp-novtk
            typing-extensions
            numpy
            svgpathtools
            anytree
            ezdxf
            ipython
            ocpsvg
            ocp-gordon
            trianglesolver
            sympy
            scipy
            scikit-learn
            webcolors
            requests
            lib3mf
          ];
          attrs.pythonImportsCheck = [ "build123d" ];
        };

      };
  };

  env = python.withPackages (ps: with ps; [
    # --- authoring: B-rep on OCCT -----------------------------------------
    build123d

    # --- verification ------------------------------------------------------
    ezdxf # DXF read-back / manufacturability audit
    trimesh # mesh booleans + proximity for swept-collision checks
    manifold3d # fast, robust boolean backend for trimesh
    rtree # spatial index trimesh uses for proximity queries
    networkx # trimesh graph ops (connected components, adjacency)
    shapely # 2D profile predicates
    numpy
    scipy

    # --- odds and ends -----------------------------------------------------
    pillow
    matplotlib
  ]);

in
runCommand "cad-python"
{
  inherit (python) version;
  passthru = { inherit env python; };
  meta = with lib; {
    description = "Python environment for scripted mechanical CAD (build123d/OCCT, ezdxf, trimesh)";
    longDescription = ''
      Exposes a single `cadpython` interpreter carrying build123d (OCCT B-rep
      modelling, STEP/DXF export, geometric interrogation) plus a verification
      stack (ezdxf, trimesh, manifold3d). Named `cadpython` rather than
      `python3` so it cannot collide with the dev profile's hiPrio python3 or
      the radio profile's python311 environment.
    '';
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
} ''
  mkdir -p $out/bin
  ln -s ${env}/bin/python3 $out/bin/cadpython
''
