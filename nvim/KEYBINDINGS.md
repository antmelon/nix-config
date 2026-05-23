# Keybindings Reference

Leader key: `<Space>`

## General

| Key | Action |
|-----|--------|
| `<leader>w` | Save file |
| `<leader>q` | Quit |
| `<leader>p` (visual) | Paste without yanking replaced text |
| `<leader>d` | Delete without yanking |
| `<C-d>` / `<C-u>` | Half-page down/up (cursor stays centred) |
| `n` / `N` | Next/prev search result (cursor stays centred) |
| `J` / `K` (visual) | Move selected lines down/up |

## Windows & Splits

| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Navigate between splits |
| `<leader>sv` | Split vertically |
| `<leader>sh` | Split horizontally |
| `<leader>sc` | Close current split |

## Harpoon (file marks)

| Key | Action |
|-----|--------|
| `<leader>a` | Add current file to harpoon list |
| `<C-e>` | Open harpoon quick menu |
| `<leader>1` | Jump to harpoon file 1 |
| `<leader>2` | Jump to harpoon file 2 |
| `<leader>3` | Jump to harpoon file 3 |
| `<leader>4` | Jump to harpoon file 4 |

## Snacks Picker (fuzzy find)

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep (search text across project) |
| `<leader>fb` | Find open buffers |
| `<leader>fr` | Recent files |
| `<leader>fd` | Project diagnostics |
| `<leader>ft` | Find TODOs / FIXMEs |
| `<leader>fh` | Search help tags |
| `<leader>fc` | Command history |
| `<leader>fn` | Notification history |

## LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | List references |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `<leader>ca` | Code action |
| `<leader>rn` | Rename symbol |
| `<leader>e` | Show line diagnostics (float) |
| `[d` / `]d` | Previous / next diagnostic |

## Formatting

| Key | Action |
|-----|--------|
| `<leader>cf` | Format current file (async) |

Format on save is also enabled automatically.

## Git (Neogit / Gitsigns / Diffview)

| Key | Action |
|-----|--------|
| `<leader>gs` | Open Neogit (git status / commit / push) |
| `<leader>gd` | Open Diffview (side-by-side diff) |
| `<leader>gh` | File history in Diffview |
| `<leader>gx` | Close Diffview |
| `<leader>gb` | Blame current line |
| `<leader>ghs` | Stage hunk under cursor |
| `<leader>ghr` | Reset hunk under cursor |
| `]g` / `[g` | Next / prev git hunk |

## Terminal

| Key | Action |
|-----|--------|
| `<leader>tt` | Toggle floating terminal |

Works in both normal and terminal mode — press `<leader>tt` again to hide it.
To exit terminal insert mode without closing: `<C-\><C-n>`
