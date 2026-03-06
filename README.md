# banshee-ucm-conf
<!---->
UCM (Use Case Manager) audio configuration for the Banshee (Framework Chromebook), which uses the `sof-rt5682` sound card with a Max98360A speaker amp on Intel Alderlake.
<!---->
Based on [chromebook-ucm-conf](https://github.com/WeirdTreeThing/chromebook-ucm-conf), stripped down to only what banshee needs.
<!---->
## NixOS Usage
<!---->
Add this flake as an input and enable the module:
<!---->
```nix
# flake.nix
inputs.banshee-ucm-conf.url = "github:ewtodd/banshee-ucm-conf";
#
# configuration.nix
{ inputs, ... }: {
  imports = [ inputs.banshee-ucm-conf.nixosModules.default ];
  hardware.banshee-audio.enable = true;
}
```
