{ config, lib, pkgs, ... }:

{
    config = lib.mkIf (config.networking.hostName == "nixdev") {
        # Mount NTFS partition at /winfs
        fileSystems."/winfs" = lib.mkForce {
          device = "/dev/disk/by-uuid/72563F3E563F0281";
          fsType = "ntfs";
          options = [ "defaults" "nofail" "uid=1000" "gid=100" "dmask=022" "fmask=133" ]; # User-readable, aaron access
        };

        fileSystems."/vm" = {
          device = "/dev/disk/by-uuid/4ac05c37-3661-489d-bb85-2697bff25cc2";
          fsType = "btrfs";
          options = [ 
            "nofail"           # Don't fail boot if mount fails
            "subvol=vm"        # Mount the vm subvolume
            "nodatacow"        # Disable copy-on-write for better VM performance
            "compress=lzo"     # Fast compression algorithm
            "space_cache=v2"   # Efficient space cache for performance
            "noatime"          # Don't update file access times
            "discard=async"    # Async SSD TRIM for better performance
          ];
        };

    };
}