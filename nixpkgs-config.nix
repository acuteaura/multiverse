{
  getName,
  extraOverlays ? [],
}: {
  nixpkgs.config = {
    allowUnfree = false;
    allowUnfreePredicate = pkg:
      builtins.elem (getName pkg) [
        "1password-cli"
      ];
    allowInsecurePredicate = pkg:
      builtins.elem (getName pkg) [
      ];
  };
  nixpkgs.overlays =
    []
    ++ extraOverlays;
}
