{ pkgs, ... }: {
  services.soft-serve = {
    enable = true;
    dataDir = "/var/lib/soft-serve"; 
    settings = {
      name = "Galileo Soft-Serve";
      ssh = {
        listen_addr = "localhost:23232";
        initial_admin_keys = [ 
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKVYhehR0SRSffy5rmGlSKIQVYw7aXd5IZbO6s1dscyf shmul95@nixos" 
        ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 23232 ];
}
