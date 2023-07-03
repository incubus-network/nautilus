{ pkgs ? import ../../../nix { } }:
let nautid = (pkgs.callPackage ../../../. { });
in
nautid.overrideAttrs (oldAttrs: {
  patches = oldAttrs.patches or [ ] ++ [
    ./broken-nautid.patch
  ];
})
