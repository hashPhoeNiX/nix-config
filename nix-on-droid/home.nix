{ config, lib, pkgs, inputs, ... }:
{
  # Read the changelog before changing this value
  home.stateVersion = "23.11";
  imports = [
    ../nixcats
  ];
  # insert home-manager config
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      #strategy = [ "completion" ]; #Error
    };
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -l";
      update = "nix-on-droid switch --flake ~/nix-config/nix-on-droid/flake.nix";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "sorin"; #"robbyrussell";
    };
  };
}

