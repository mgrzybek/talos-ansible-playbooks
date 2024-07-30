{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    # nativeBuildInputs is usually what you want -- tools you need to run
    nativeBuildInputs = with pkgs.buildPackages; [
      ansible
      cilium-cli
      coreutils-full
      curl
      docker
      git
      helm
      jq
      kubectl
      libvirt

      ## Problems using pip install on `pre-commit run --all`
      #pre-commit
      #python312Packages.pre-commit-hooks
      #python312Packages.pytest
      #python312Packages.mypy
      #python312Packages.twine
      #python312Packages.types-requests
      #python312Packages.types-setuptools

      talosctl
      wget
      which
      yq-go
    ];
}
