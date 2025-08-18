{ config, lib, pkgs, ... }:

{
    config = lib.mkIf (config.networking.hostName == "nixdev") {
        # Mount NTFS partition at /winfs
        fileSystems."/winfs" = lib.mkForce {
          device = "/dev/disk/by-uuid/72563F3E563F0281";
          fsType = "ntfs";
          options = [ "defaults" "nofail" "uid=1000" "gid=100" "dmask=022" "fmask=133" ]; # User-readable, aaron access
        };

    };
}