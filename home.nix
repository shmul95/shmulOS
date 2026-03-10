# home.nix
{ config, pkgs, lib, inputs, ... }:

{
  imports = [ ./modules/claude.nix ];
 
  sops = {
    age.keyFile = "/home/shmul95/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets/secrets.yaml;

    secrets.obsidian_api_key = {};
  };

  home = {
    # home have all the var and packages installation

    username = "shmul95";
    homeDirectory = "/home/shmul95";
    stateVersion = "25.05";

    packages = with pkgs; [
      gcc gnumake nodejs
      kitty discord firefox
      sops age

      inputs.zshmul.packages.${pkgs.system}.default
      inputs.tshmux.packages.${pkgs.system}.default
      inputs.shmulvim.packages.${pkgs.system}.default

      nerd-fonts.jetbrains-mono
    ];

    sessionVariables = {
      EDITOR = "nvim"; # later on shmulvim
    };

    # linked to the gtk config
    pointerCursor = {
      gtk.enable = true;
      package = pkgs.phinger-cursors;
      name = "phinger-cursors-light";
      size = 24;
    };

    file.".claude/CLAUDE.md".text = /* markdown */ ''
# Memory Instructions

You have access to an Obsidian vault at `/home/shmul95/.claude-memory`.
This is your persistent memory across sessions. Use it proactively.

---

## On every session start
1. Read `index.md` to get a general map of what you know
2. Search the vault using keywords from the user's first message
3. Read any matching notes before responding

---

## Writing notes
Write to Obsidian when you learn something reusable:
- A user preference or habit ("I prefer X", "always do Y")
- A non-obvious solution or workaround you found
- A project decision or its reasoning
- Any fact about the user's environment or setup

### Note format
Every note must follow this structure:
```
---
tags: [keyword1, keyword2, keyword3]
related: []
updated: YYYY-MM-DD
---

# Title

content here
```

### Tag rules (important)
Tags replace folders — they are the only structure. Be generous with them.
- Must be **short, searchable, atomic** — one concept per tag
- Always include: the domain (`nix`, `zsh`, `git`, `python`...), the type (`preference`, `fix`, `decision`, `pattern`, `fact`), and any specific topic
- Bad tags: `programming`, `stuff`, `misc`
- Good tags: `nix`, `home-manager`, `flake`, `preference`, `mcp`, `obsidian`, `fix`

### File naming
Since everything lives flat in the vault root, use clear descriptive names:
- `preferences-coding.md`, `preferences-tools.md`
- `facts-environment.md`
- `project-<name>.md`
- `fix-<topic>.md`
- `index.md`

---

## Searching for connections
Every time you write or update a note:
1. Search the vault for notes sharing at least one tag with the new note
2. For each match that is meaningfully related, add it to the `related: []` frontmatter of both notes
3. If two notes cover the same topic and could be merged, suggest it to the user

When answering a question:
1. Don't just fetch the most obvious note — search 2-3 variations of the topic
2. If multiple notes are relevant, reason over all of them together before responding
3. If you notice a connection the user hasn't seen, mention it

---

## On session end (when asked to wrap up)
- Write a short summary to `session-YYYY-MM-DD.md` with tags matching what was worked on
- Update `related:` fields if new connections were found during the session
- Update `index.md`
  '';
  };

  programs = {
    # basic setup of some of the application

    zsh = {
      enable = true;
      initContent = /* sh */ ''
        if [[ $- == *i* ]]; then
          exec zshmul
        fi
      '';
    };

    git = {
      enable = true;
      settings = {
        user.name = "shmul95";
        user.email = "samuel.gross@epitech.eu";
      };
    };

    kitty = {
      enable = true;
      settings = {
        font_family = "JetBrainsMono Nerd Font";
        disable_ligatures = "never";
        "font_features JetBrainsMono Nerd Font" = "+liga +calt";
      };
    };

    claude = {
      enable = true;
      mcp.obsidian = {
        enable = true;
        apiKey = config.sops.secrets.obsidian_api_key.path;
        vaultPath = "/home/shmul95/.claude-memory";
      };
    };

    home-manager.enable = true;
  };

  # cursor configuration
  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.phinger-cursors;
      name = "phinger-cursors-light";
    };
  };

}
