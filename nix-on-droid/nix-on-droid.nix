{ config, lib, pkgs, inputs, ... }:

{
  # Simply install just the packages
  environment.packages = with pkgs; [
    # User-facing stuff that you really really want to have
    vim # or some other editor, e.g. nano or neovim
    git
    #neovim
    zsh
    oh-my-zsh
    zsh-powerlevel10k
    zsh-autosuggestions
    zsh-syntax-highlighting
    neofetch
    fastfetch
    fish
    # Some common stuff that people expect to have
    sudo
    diffutils
    findutils
    utillinux
    tzdata
    hostname
    man
    gnugrep
    gnupg
    gnused
    gnutar
    bzip2
    gzip
    xz
    zip
    unzip
    ncurses
    curl
    
    helix
    which
    emacs
    ranger
    openssh

    # home manager
    home-manager
  ];

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "23.11";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';  

  #programs.zsh = {
  #    enable = true;
  # }
  terminal.font = "${pkgs.jetbrains-mono}/share/fonts/truetype/JetbrainsMonoTTF.ttf";

  user.shell = "${pkgs.fish}/bin/fish";
  # Set your time zone
  #time.timeZone = "Europe/Berlin";

  # After installing home-manager channel like
  #   nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz home-manager
  #   nix-channel --update
  # you can configure home-manager in here like
  home-manager = {
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
  
    config = import ./home.nix;
    extraSpecialArgs = {
      inherit inputs;
     };
      #{ config, lib, pkgs, ... }:
      #{
      #  # Read the changelog before changing this value
      #  home.stateVersion = "23.11";
  
      #  # insert home-manager config
      #  programs.zsh = {
      #    enable = true;
      #    enableCompletion = true;
      #    autosuggestion = {
      #      enable = true;
      #      #strategy = [ "completion" ]; #Error
      #    };
      #    syntaxHighlighting.enable = true;
      #    shellAliases = {
      #      ll = "ls -l";
      #      update = "nix-on-droid switch --flake ~/nix-config/nix-on-droid/flake.nix";
      #    };
      #    oh-my-zsh = {
      #      enable = true;
      #      plugins = [ "git" ];
      #      theme = "sorin"; #"robbyrussell";
      #    };
      #  };
      #};
  };
}

# vim: ft=nix
