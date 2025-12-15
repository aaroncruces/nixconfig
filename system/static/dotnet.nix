{ config, lib, pkgs, ... }:

{
  
  # Add dotnet to PATH if needed (systemPackages already adds to PATH, but for clarity)
  environment.extraInit = ''
    export PATH=$PATH:${pkgs.dotnet-sdk_8}/bin
  '';
}
