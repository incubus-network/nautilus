{ pkgs ? import ../../../nix { } }:
let fury = (pkgs.callPackage ../../../. { });
in
fury.overrideAttrs (oldAttrs: {
  patches = oldAttrs.patches or [ ] ++ [
    ./broken-fury.patch
  ];
})
