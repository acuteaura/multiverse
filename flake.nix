{
  description = "aurelia's stable flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    quadlet.url = "github:SEIAROTg/quadlet-nix";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = inputs @ {nixpkgs, ...}: let
    nixpkgsConfig = import ./nixpkgs-config.nix {
      inherit (nixpkgs.lib) getName;
      extraOverlays = [];
    };
  in
    {
      nixosConfigurations = {
        bootstrap = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            nixpkgsConfig
            inputs.quadlet.nixosModules.quadlet
            ./systems/bootstrap
          ];
        };
      };
    }
    // inputs.flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          inherit (nixpkgsConfig.nixpkgs) config overlays;
        };
      in {
        formatter = pkgs.alejandra;

        apps.lint = {
          type = "app";
          program = "${pkgs.writeShellScript "lint" ''
            ${pkgs.statix}/bin/statix check "$@"
            ${pkgs.deadnix}/bin/deadnix --no-lambda-arg --no-lambda-pattern-names "$@"
          ''}";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            alejandra
            statix
            deadnix
            nixfmt-rfc-style
          ];
        };
      }
    );
}
