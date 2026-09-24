{ ... }:
{
  networking = {
    useDHCP = false;
    useNetworkd = false;

    wireless.iwd = {
      enable = true;
      settings = {
        General = {
          EnableNetworkConfiguration = true;
        };

        Network = {
          EnableIPv6 = true;
        };

        Scan = {
          DisablePeriodicScan = false;
          RoamThreshold = -88;
          RoamThreshold5G = -88;
        };
      };
    };
	nameservers = [
	  "223.5.5.5"
	  "119.29.29.29"
	  "180.76.76.76"
 	 "1.1.1.1"
	];
  };

  systemd.services.iwd = {
    serviceConfig = {
      Restart = "always";
      RestartSec = "1s";
    };

    unitConfig.StartLimitIntervalSec = "0";
  };
}
