# flake.nix
{
  description = "Nix flake for SignalRGB";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate =
          pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "signalrgb" ];
      };
    in
    {
      packages.${system} = {
        signalrgb = pkgs.callPackage ./default.nix { };
        default = self.packages.${system}.signalrgb;
      };

      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.signalrgb}/bin/signalrgb";
      };

      nixosModules.default =
        { config, lib, pkgs, ... }:
        let
          cfg = config.programs.signalrgb;
          # Built from this flake's own pkgs, so the unfree allowance above
          # applies and the system config doesn't need to know about it.
          pkg = self.packages.${pkgs.stdenv.hostPlatform.system}.signalrgb;
        in
        {
          options.programs.signalrgb = {
            enable = lib.mkEnableOption "SignalRGB";
            i2c.enable = lib.mkEnableOption "I2C/SMBus access (RGB RAM, motherboard headers)";
          };

          config = lib.mkIf cfg.enable {
            environment.systemPackages = [ pkg ];
            services.udev.packages = [ pkg ];

            # The shipped udev rules reference these groups by name.
            users.groups.plugdev = { };
            users.groups.i2c = { };

            hardware.i2c.enable = lib.mkIf cfg.i2c.enable true;
          };
        };
    };
}