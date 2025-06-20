{
  description = "Ryzzen's custom packages";

  outputs =
    { self, ... }:
    {
      # Expect the caller to pass pkgs, so nothing defined here
      # Just expose a function the user will call manually
      lib.importPackages = { pkgs }: import ./default.nix { inherit pkgs; };
    };
}
