date := `date -u +"%Y-%m-%d %H:%M:%S%z"`
hostname := `hostname`
substituters := ''

default:
    @just --list

push:
    git add .
    git commit -m "update from {{ hostname }}@{{ date }}" || true
    git push origin HEAD

build HOSTNAME *FLAGS:
    #!/usr/bin/env bash
    set -euo pipefail
    nix build .#nixosConfigurations.{{ HOSTNAME }}.config.system.build.toplevel --log-format internal-json {{ FLAGS }} |& nom --json
    if command -v attic >/dev/null 2>&1 && attic cache info aurelia >/dev/null 2>&1; then
        echo "Pushing to attic cache..."
        attic push aurelia ./result
    else
        echo "Skipping attic push (attic not configured or cache 'aurelia' not found)"
    fi

install HOSTNAME *FLAGS:
    nixos-install --flake .#{{ HOSTNAME }} {{ substituters }} {{ FLAGS }}

switch *FLAGS:
    @just rebuild switch {{ FLAGS }}

boot *FLAGS:
    @just rebuild boot {{ FLAGS }}

update-dependencies:
    nix flake update nixpkgs quadlet
    nix flake archive

lint:
    nix run .#lint -- {{ justfile_directory() }}

format:
    nix fmt {{ justfile_directory() }}

check:
    nix flake check --no-build
