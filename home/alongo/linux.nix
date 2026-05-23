{ ... }:

{
  home = {
    username      = "alongo";
    homeDirectory = "/home/alongo";
  };

  programs.fish.loginShellInit = ''
    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
      exec startx -- -keeptty
    end
  '';
}
