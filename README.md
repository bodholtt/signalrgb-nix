# signalrgb

Nix flake for SignalRGB linux beta

This flake was made with free claude. 
Use at your own risk, and expect it to break at any time

`flake.nix`:
```nix
inputs.
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    signalrgb = {
        url = "github:bodholtt/signalrgb-nix";
        inputs.nixpkgs.follows = "nixpkgs";
    }
  };

  outputs = { nixpkgs, signalrgb, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        signalrgb.nixosModules.default
      ];
    };
  };
}
```

`configuration.nix`:
```nix
imports = [ signalrgb.nixosModules.default ];
programs.signalrgb = {
    enable = true;

    # Optional: I2C/SMBus access for RGB RAM and motherboard headers
    i2c.enable = true;
}
```