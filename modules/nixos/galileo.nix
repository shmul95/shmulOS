{ pkgs, ... }: {
  # Create the git user
  users.users.git = {
    isSystemUser = true;
    group = "git";
    home = "/var/lib/git";
    createHome = true;
    shell = "${pkgs.git}/bin/git-shell";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3... your_key" 
    ];
  };
  users.groups.git = {};

  # Configure SSH for local access
  services.openssh.enable = true;
  
  # Allow the git user to manage their own folder
  systemd.tmpfiles.rules = [
    "d /var/lib/git 0750 git git -"
  ];
}
