# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.blacklistedKernelModules = ["nouveau"];

  networking.hostName = "RazerBladeStealth"; # Define your hostname.
  networking.wireless.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    defaultLocale = "ja_JP.UTF-8";
    consoleUseXkbConfig = true;
  };
  i18n.inputMethod = {
    enabled = "fcitx";
    fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
  };

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (import ./st/overlay.nix)
    ];
  };

  environment.systemPackages = with pkgs; [
    bash
    clipmenu
    curl
    emacs26-nox
    enpass
    feh
    fff
    firefox
    fzf
    gcc
    git
    google-chrome
    killall
    lightlocker
    minitube
    neofetch
    pywal
    pulseaudio
    rofi
    rustup
    spotify
    stow
    tmux
    wget
    xorg.xbacklight
    xsel
    (polybar.override {
      pulseSupport = true;
    })
    (st.override {
      conf = (builtins.readFile /etc/nixos/st/config.h);
      patches = [
        (fetchurl {
          url = "https://st.suckless.org/patches/xresources/st-xresources-20190105-3be4cf1.diff";
          sha256 = "112zi7jqzj6601gp54nr4b7si99g29lz61c44rgcpgpfddwmpibi";
        })
      ];
    })
  ];

  fonts = {
    enableDefaultFonts = true;
    enableFontDir = true;
  };
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    roboto-mono
    font-awesome_4
  ];
  fonts.fontconfig = {
    enable = true;
  };
  fonts.fontconfig.defaultFonts = {
    monospace = [
      "Roboto Mono"
    ];
    serif = [
      "Noto Serif"
      "Noto Serif JP"
      "Noto Serif SC"
      "Noto Serif TC"
      "Noto Serif KR"
    ];
    sansSerif = [
      "Noto Sans"
      "Noto Sans JP"
      "Noto Sans TC"
      "Noto Sans SC"
      "Noto Sans KR"
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "ctrl:nocaps";
    autorun = true;
    videoDrivers = ["intel"];
  };
  services.xserver.desktopManager = {
    default = "none";
    xterm.enable = false;
  };
  services.xserver.windowManager = {
    default = "openbox";
    openbox.enable = true;
  };
  services.xserver.displayManager.lightdm = {
    enable = true;
    background = "#333333";
  };
  services.xserver.displayManager.lightdm.greeters = {
    gtk.enable = false;
    mini = {
      enable = true;
      user = "kiluhabe";
      extraConfig = ''
        [greeter]
        show-password-label = false
        [greeter-theme]
        background-image = ""
      '';
    };
  };
  systemd.services.lightlocker = {
    enable = true;
  };
  # Enable touchpad support.
  services.xserver.libinput = {
    enable = true;
    naturalScrolling = true;
    clickMethod = "clickfinger";
    buttonMapping = "1 0 3 4 5 6 7";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kiluhabe = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "docker" "disk" "vboxusers" "audio"];
    createHome = true;
    uid = 1000;
  };
  users.extraGroups.vboxusers.members = ["user-with-access-to-virtualbox"];

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?

}