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
      talosctl
      wget
      which
      yq-go
    ];
}
