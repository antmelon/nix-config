{ ... }:

{
  services.glance = {
    enable = true;
    settings = {
      server = {
        host = "0.0.0.0";
        port = 8080;
      };
      theme = {
        background-color = "240 8 9";
        primary-color = "43 50 70";
        contrast-multiplier = 1.1;
      };
      pages = [{
        name = "Home";
        columns = [
          {
            size = "small";
            widgets = [
              { type = "calendar"; }
              {
                type = "weather";
                location = "New York City, United States";
                units = "imperial";
              }
            ];
          }
          {
            size = "full";
            widgets = [
              {
                type = "releases";
                repositories = [
                  "NixOS/nixpkgs"
                  "nix-community/home-manager"
                  "glanceapp/glance"
                ];
              }
              {
                type = "rss";
                title = "NixOS News";
                feeds = [
                  { url = "https://nixos.org/blog/announcements-rss.xml"; }
                  { url = "https://discourse.nixos.org/c/announcements/8.rss"; }
                ];
              }
            ];
          }
          {
            size = "small";
            widgets = [
              {
                type = "server-stats";
                servers = [{
                  type = "local";
                  name = "melchior";
                }];
              }
              {
                type = "bookmarks";
                groups = [{
                  title = "Quick Links";
                  links = [
                    { title = "GitHub"; url = "https://github.com"; }
                    { title = "NixOS Search"; url = "https://search.nixos.org"; }
                  ];
                }];
              }
            ];
          }
        ];
      }];
    };
  };
}
