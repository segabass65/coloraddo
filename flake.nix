{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    systems.url = "github:nix-systems/default-linux";

    config-generator = {
      # url = "github:segabass65/config-generator";
      url = "path:/repos/segabass65/config-generator";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, config-generator, nixpkgs, utils, systems, ... }: let
    package = pkgs: pkgs.callPackage ./. { inherit pkgs; };

  in
    utils.lib.eachSystem (import systems) (system: let
      pkgs = import nixpkgs { inherit system; };

    in {
      apps.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/coloraddod";
      };
      
      devShells.default = import ./shell.nix { inherit pkgs; };
      packages.default = package pkgs;
    }) // {
      homeModules = rec {
        coloraddo = { config, lib, pkgs, ... }: let
          cfg = config.services.coloraddod;

        in { 
          options.services.coloraddod = {
            enable = lib.mkEnableOption "Whether to enable Coloraddo daemon.";

            package = lib.mkOption {
              type = lib.types.package;
              default = package pkgs;
              description = "The coloraddo package to use.";
            };

            settings = lib.mkOption {
              type = lib.types.attrsOf lib.types.anything;
              default = { };
              description = "General settings given to coloraddoctl config.";
            };

            extraConfig = lib.mkOption {
              type = lib.types.str;
              default = "";
              description =
                "Additional shell commands to be run "
                "at the end of the config file.";
            };
          };

          config = lib.mkIf cfg.enable {
            home.packages = [ cfg.package ];

            systemd.user.services.coloraddod = {
              Unit = {
                Description = "Coloraddo daemon";
                After = [ "graphical-session.target" ];
                PartOf = [ "graphical-session.target" ];
              };

              Service = {
                ExecStart = "${cfg.package}/bin/coloraddod";
                Restart = "always";
                RestartSec = 3;
              };

              Install = {
                WantedBy = [ "graphical-session.target" ];
              };
            };

            xsession.windowManager.bspwm.extraConfig =
              config-generator.lib.toColoraddod {
                inherit (cfg) settings extraConfig;
              };
          };
        };

        default = coloraddo;
      };
    };
}
