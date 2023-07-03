{ pkgs
, config
, fury ? (import ../. { inherit pkgs; })
}: rec {
  start-fury = pkgs.writeShellScriptBin "start-fury" ''
    # rely on environment to provide fury
    export PATH=${pkgs.test-env}/bin:$PATH
    ${../scripts/start-fury.sh} ${config.fury-config} ${config.dotenv} $@
  '';
  start-geth = pkgs.writeShellScriptBin "start-geth" ''
    export PATH=${pkgs.test-env}/bin:${pkgs.go-ethereum}/bin:$PATH
    source ${config.dotenv}
    ${../scripts/start-geth.sh} ${config.geth-genesis} $@
  '';
  start-scripts = pkgs.symlinkJoin {
    name = "start-scripts";
    paths = [ start-fury start-geth ];
  };
}
