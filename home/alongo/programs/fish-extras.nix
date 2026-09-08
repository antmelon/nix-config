{ ... }:

{
  programs.fish.functions = {
    # Quiet NERV mark on every new interactive shell.
    fish_greeting = ''
      set_color ff6b1a
      echo '  █▄ █ █▀▀ █▀▄ █ █'
      echo '  █ ▀█ ██▄ █▀▄ █ █'
      echo '  █  █ █▄▄ █ █  █'
      set_color normal
    '';

    # Rename current dir to {name}_COMPLETED and cd out
    finish = ''
      set original_directory (pwd)
      cd ..
      mv $original_directory {$original_directory}_COMPLETED
    '';

    # Top 10 processes by memory
    psmem10 = ''
      ps auxf | sort -nr -k 4 | head -10
    '';
  };
}
