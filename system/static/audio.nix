{ config, lib, pkgs, ... }:

{
  # Enable PipeWire as the audio server
  services.pipewire = {
    enable = true;
    alsa.enable = true; # Enable ALSA support
    alsa.support32Bit = true; # Support 32-bit ALSA applications
    pulse.enable = true; # Enable PulseAudio compatibility
    wireplumber.enable = true; # Enable WirePlumber session manager
  };

  # Install PulseMixer for audio control
  environment.systemPackages = with pkgs; [ pulsemixer ];

  # Optional: Ensure audio hardware is enabled
  # hardware.pulseaudio.enable = false; # Disable PulseAudio server (using PipeWire-Pulse instead)
  services.pulseaudio.enable =
    false; # Disable PulseAudio server (using PipeWire-Pulse instead)
}
