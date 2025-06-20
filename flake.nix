{
  description = "Ryzzen's custom packages";

  outputs =
    { self, ... }:
    {
      lib.importPackages = { pkgs }: import ./default.nix { inherit pkgs; };
    };
}
