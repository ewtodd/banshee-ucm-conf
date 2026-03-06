{
  description = "Banshee (Framework Chromebook) UCM audio configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, ... }:
    {
      nixosModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.hardware.banshee-audio;

          banshee-ucm-conf = pkgs.alsa-ucm-conf.overrideAttrs (old: {
            installPhase = ''
              runHook preInstall
              mkdir -p $out/share/alsa

              # Install upstream UCM2 configs
              cp -r ucm2 $out/share/alsa/
              chmod -R u+w $out/share/alsa/ucm2

              # Overlay banshee-specific configs
              rm -rf $out/share/alsa/ucm2/sof-rt5682
              cp -r ${self}/sof-rt5682 $out/share/alsa/ucm2/sof-rt5682
              cp -r ${self}/codecs/* $out/share/alsa/ucm2/codecs/
              cp -r ${self}/common/* $out/share/alsa/ucm2/common/
              cp -r ${self}/platforms/* $out/share/alsa/ucm2/platforms/

              runHook postInstall
            '';
          });
        in
        {
          options.hardware.banshee-audio = {
            enable = lib.mkEnableOption "Banshee (Framework Chromebook) audio support";
          };

          config = lib.mkIf cfg.enable {
            environment = {
              systemPackages = [ pkgs.sof-firmware ];
              sessionVariables.ALSA_CONFIG_UCM2 = "${banshee-ucm-conf}/share/alsa/ucm2";
            };

            system.replaceDependencies.replacements = [
              {
                original = pkgs.alsa-ucm-conf;
                replacement = banshee-ucm-conf;
              }
            ];

            # Rename the card from "Alder Lake PCH-P High Definition Audio Controller"
            services.pipewire.wireplumber.configPackages = [
              (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/51-banshee-audio.conf" ''
                monitor.alsa.rules = [
                  {
                    matches = [
                      {
                        device.name = "~alsa_card.*adl_rt5682*"
                      }
                    ]
                    actions = {
                      update-props = {
                        device.description = ""
                      }
                    }
                  }
                ]
              '')
            ];
          };
        };
    };
}
