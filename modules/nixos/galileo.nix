{ pkgs, ... }: {
  # 1. Create the git user
  users.users.git = {
    isSystemUser = true;
    group = "git";
    home = "/var/lib/git";
    createHome = true;
    shell = "${pkgs.git}/bin/git-shell";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKVYhehR0SRSffy5rmGlSKIQVYw7aXd5IZbO6s1dscyf shmul95@nixos" 
    ];
  };
  users.groups.git = {};

  # 2. Configure SSH for local access
  services.openssh.enable = true;
  
  # 3. Allow the git user to manage their own folder
  systemd.tmpfiles.rules = [
    "d /var/lib/git 0750 git git -"
  ];

  # 4. Global Git settings for the whole system (Fixes the 'master' issue)
  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      safe.directory = "/var/lib/git/*"; # Useful if you ever browse the bare repos
    };
  };
}
