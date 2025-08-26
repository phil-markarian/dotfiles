# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> {
    config.allowUnfree = true;
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";



  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  
  ###################
  ## Font Settings ##
  ###################

  # Enable fonts to use on your system.  You should make sure to add at least
  # one English font (like dejavu_fonts), as well as Japanese fonts like
  # "ipafont" and "kochi-substitute".
  fonts.packages = with pkgs; [
    carlito
    dejavu_fonts
    ipafont
    kochi-substitute
    source-code-pro
    ttf_bitstream_vera
  ];
  
  
    # These settings enable default fonts for your system.  This setting is very
  # important.  It lets fontconfig know that you want to fall back to a Japanese
  # font (for example "IPAGothic") if an application tries to show fonts with
  # Japanese.  For instance, this is important if you are using a terminal
  # emulator and you `cat` some Japanese text to the screen. If you don't have
  # "defaultFonts" configured, fontconfig will pick a random Japanese font to
  # use.  If you have this "defaultFonts" setting configured, fontconfig will
  # pick the font you have selected.  This makes sure Japanese fonts look nice.
  fonts.fontconfig.defaultFonts = {
    monospace = [
      "DejaVu Sans Mono"
      "IPAGothic"
    ];
    sansSerif = [
      "DejaVu Sans"
      "IPAPGothic"
    ];
    serif = [
      "DejaVu Serif"
      "IPAPMincho"
    ];
  };
  
  ###############################
  ## Input Method Editor (IME) ##
  ###############################

  # This enables "fcitx5" as your IME.
	i18n.inputMethod = {
	  enabled = "fcitx5";
	  fcitx5 = {
	    # Assuming `mozc` is directly available under `pkgs`
	    addons = with pkgs; [ fcitx5-mozc ];
	    # Add other configurations or addons as needed
	  };
	};


  
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.eternity = {
    isNormalUser = true;
    description = "Phil";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      thunderbird
      git
      discord
      fcitx5  
    ];
  };
  
  nixpkgs.config = {
      allowUnfree = true;
      permittedInsecurePackages = [
             "electron-25.9.0"
      ];
  };

  environment.sessionVariables = {
    KAGI_TOKEN = "xFqbPH-oePolmJ6q6VWaYLxqYcEckLkxpXVQ4lDaRew.uDRqWR83QZ4uS9Tr8-bsaemXdjfVmBG4HCXI6qRI2TE";
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = (with pkgs; [
    vim
    wget
    alejandra
    libnotify
    plex-media-player
    blesh
    gparted
    obsidian
   (pkgs.writeShellScriptBin "kagi" ''
      #!/usr/bin/env bash
      # Die if the token is missing
      : ''\${KAGI_TOKEN:?Set KAGI_TOKEN in your env}

      curl -fsSL -G \
        --data-urlencode "q=$*" \
        -d "api_key=$KAGI_TOKEN" \
        https://kagi.com/api/v0/search |
        jq .
    '')  
]) ++ [
    unstable.brave
  ];

environment.interactiveShellInit = ''
    # Load ble.sh only for interactive Bash
    if [[ $- == *i* ]] && [[ -f ${pkgs.blesh}/share/blesh/ble.sh ]]; then
      source ${pkgs.blesh}/share/blesh/ble.sh
    fi
  '';

  environment.shellAliases = {
   refresh-gnome = "/bin/refresh-gnome.sh";
   config = "sudo vim /etc/nixos/configuration.nix";
   switch = "sudo nixos-rebuild switch";
   refresh = "exec $SHELL"; 
 };
 
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}

