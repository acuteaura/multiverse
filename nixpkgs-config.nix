{
  getName,
  extraOverlays ? [],
}: {
  nixpkgs.config = {
    allowUnfree = false;
    allowUnfreePredicate = pkg:
      builtins.elem (getName pkg) [
      ];
    allowInsecurePredicate = pkg:
      builtins.elem (getName pkg) [
      ];
  };
  nixpkgs.overlays =
    extraOverlays;
}
