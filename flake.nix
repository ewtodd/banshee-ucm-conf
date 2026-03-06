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

          banshee-ucm-conf = pkgs.alsa-ucm-conf.overrideAttrs {
            unpackPhase = ''
              runHook preUnpack
              tar xf "$src"
              runHook postUnpack
            '';
            installPhase = ''
              runHook preInstall
              mkdir -p $out/share/alsa
              cp -r alsa-ucm*/{ucm,ucm2} $out/share/alsa
              chmod -R u+w $out/share/alsa

              cp -r ${self}/common $out/share/alsa/ucm2
              cp -r ${self}/codecs/* $out/share/alsa/ucm2/codecs/
              cp -r ${self}/platforms/* $out/share/alsa/ucm2/platforms/

              rm -rf $out/share/alsa/ucm2/conf.d/sof-rt5682
              cp -r ${self}/sof-rt5682 $out/share/alsa/ucm2/conf.d/sof-rt5682

              runHook postInstall
            '';
          };
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
                        device.description = "Audio"
                        device.nick = ""
                      }
                    }
                  }
                  {
                    matches = [
                      {
                        node.name = "~alsa_output.*adl_rt5682*Speaker*"
                      }
                    ]
                    actions = {
                      update-props = {
                        node.description = "Speaker"
                        node.nick = "Speaker"
                      }
                    }
                  }
                  {
                    matches = [
                      {
                        node.name = "~alsa_output.*adl_rt5682*Headphones*"
                      }
                    ]
                    actions = {
                      update-props = {
                        node.description = "Headphones"
                        node.nick = "Headphones"
                      }
                    }
                  }
                  {
                    matches = [
                      {
                        node.name = "~alsa_input.*adl_rt5682*Headset*"
                      }
                    ]
                    actions = {
                      update-props = {
                        node.description = "Headset Microphone"
                        node.nick = "Headset Mic"
                      }
                    }
                  }
                  {
                    matches = [
                      {
                        node.name = "~alsa_input.*adl_rt5682*Mic*"
                      }
                    ]
                    actions = {
                      update-props = {
                        node.description = "Internal Microphone"
                        node.nick = "Internal Mic"
                      }
                    }
                  }
                  {
                    matches = [
                      {
                        node.name = "~alsa_output.*adl_rt5682*HDMI1*"
                      }
                    ]
                    actions = {
                      update-props = {
                        node.description = "HDMI / DisplayPort 1"
                        node.nick = "HDMI 1"
                      }
                    }
                  }
                  {
                    matches = [
                      {
                        node.name = "~alsa_output.*adl_rt5682*HDMI2*"
                      }
                    ]
                    actions = {
                      update-props = {
                        node.description = "HDMI / DisplayPort 2"
                        node.nick = "HDMI 2"
                      }
                    }
                  }
                  {
                    matches = [
                      {
                        node.name = "~alsa_output.*adl_rt5682*HDMI3*"
                      }
                    ]
                    actions = {
                      update-props = {
                        node.description = "HDMI / DisplayPort 3"
                        node.nick = "HDMI 3"
                      }
                    }
                  }
                  {
                    matches = [
                      {
                        node.name = "~alsa_output.*adl_rt5682*HDMI4*"
                      }
                    ]
                    actions = {
                      update-props = {
                        node.description = "HDMI / DisplayPort 4"
                        node.nick = "HDMI 4"
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
