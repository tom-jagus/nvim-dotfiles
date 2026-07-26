# Keymaps

`<Leader>` is `<Space>`. Leader mappings use a two-key semantic structure:
the first key selects a group and the second selects an action.

Press `<Leader>` and wait for `mini.clue` to show the available groups and
descriptions. This page documents custom workflow mappings; it does not
duplicate every native Vim or automatically generated `mini.nvim` mapping.

## General mappings

| Mode | Mapping | Action |
|---|---|---|
| Normal | `<Esc>` | Clear search highlighting |
| Normal | `[p` | Paste linewise above the current line |
| Normal | `]p` | Paste linewise below the current line |
| Terminal | `<Esc><Esc>` | Enter Terminal-Normal mode |

`mini.basics` also supplies common mappings such as `<C-s>` for saving,
`<C-h/j/k/l>` for window navigation, and backslash-prefixed option toggles.
`mini.bracketed`, `mini.surround`, `mini.ai`, and other modules retain their
documented default mappings.

## Buffer: `<Leader>b`

| Mapping | Action |
|---|---|
| `<Leader>ba` | Switch to the alternate buffer |
| `<Leader>bd` | Delete the current buffer |
| `<Leader>bD` | Force-delete the current buffer |
| `<Leader>bo` | Delete every other listed, unmodified buffer |
| `<Leader>bs` | Create a scratch buffer |
| `<Leader>bw` | Wipe out the current buffer |
| `<Leader>bW` | Force-wipe the current buffer |

`<Leader>bo` intentionally preserves the current buffer, modified buffers, and
unlisted utility buffers. It uses `mini.bufremove` so the window layout remains
usable.

## Explore and edit: `<Leader>e`

| Mapping | Action |
|---|---|
| `<Leader>ed` | Open the working directory in `mini.files` |
| `<Leader>ef` | Open the current file's directory |
| `<Leader>ei` | Edit `init.lua` |
| `<Leader>ek` | Edit `plugin/20_keymaps.lua` |
| `<Leader>em` | Edit `plugin/30_mini.lua` |
| `<Leader>en` | Show notification history |
| `<Leader>eo` | Edit `plugin/10_options.lua` |
| `<Leader>ep` | Edit `plugin/40_plugins.lua` |
| `<Leader>eq` | Toggle the quickfix list |
| `<Leader>eQ` | Toggle the location list |

## Find: `<Leader>f`

| Mapping | Action |
|---|---|
| `<Leader>f/` | Search `/` history |
| `<Leader>f:` | Search command history |
| `<Leader>fa` / `<Leader>fA` | Find staged hunks globally / in the current buffer |
| `<Leader>fb` | Find buffers |
| `<Leader>fc` / `<Leader>fC` | Find commits globally / for the current buffer |
| `<Leader>fd` / `<Leader>fD` | Find diagnostics in the workspace / current buffer |
| `<Leader>ff` | Find files |
| `<Leader>fg` | Live grep |
| `<Leader>fG` | Grep the word under the cursor |
| `<Leader>fh` | Find help tags |
| `<Leader>fH` | Find highlight groups |
| `<Leader>fl` / `<Leader>fL` | Find lines in all buffers / current buffer |
| `<Leader>fm` / `<Leader>fM` | Find modified hunks globally / in the current buffer |
| `<Leader>fr` | Resume the latest picker |
| `<Leader>fR` | Find LSP references |
| `<Leader>fs` / `<Leader>fS` | Find workspace / document symbols |
| `<Leader>fv` / `<Leader>fV` | Find visited paths globally / under the current root |

Most find mappings use `mini.pick`; content search performs best when `rg` is
available.

## Git: `<Leader>g`

| Mapping | Action |
|---|---|
| `<Leader>ga` / `<Leader>gA` | Show staged diff globally / for the current buffer |
| `<Leader>gc` | Commit |
| `<Leader>gC` | Amend the current commit |
| `<Leader>gd` / `<Leader>gD` | Show unstaged diff globally / for the current buffer |
| `<Leader>gg` | Open LazyGit |
| `<Leader>gl` / `<Leader>gL` | Show repository / current-file log |
| `<Leader>go` | Toggle inline diff overlay |
| `<Leader>gs` | Show Git information at the cursor or visual selection |

`<Leader>gg` is available only when the `lazygit` executable is installed.

## Language: `<Leader>l`

| Mapping | Action |
|---|---|
| `<Leader>la` | Code action |
| `<Leader>ld` | Diagnostic popup |
| `<Leader>lf` | Format the buffer or visual selection |
| `<Leader>lh` | Hover information |
| `<Leader>li` | Go to implementation |
| `<Leader>ll` | Run code lens |
| `<Leader>lr` | Rename symbol |
| `<Leader>lR` | List references |
| `<Leader>ls` | Go to definition |
| `<Leader>lt` | Go to type definition |

## Map: `<Leader>m`

| Mapping | Action |
|---|---|
| `<Leader>mf` | Toggle focus on the map |
| `<Leader>mr` | Refresh the map |
| `<Leader>ms` | Move the map to the other side |
| `<Leader>mt` | Toggle the map |

## Notes: `<Leader>n`

| Mapping | Action |
|---|---|
| `<Leader>na` | Add a tag |
| `<Leader>nb` | Show backlinks |
| `<Leader>nd` | Open today's daily note |
| `<Leader>nD` | Browse daily notes |
| `<Leader>nf` | Find a note |
| `<Leader>ng` | Find tags |
| `<Leader>ni` | Insert a tag |
| `<Leader>nl` | Show outgoing links |
| `<Leader>nn` | Open or create a note in `notes/` |
| `<Leader>np` | Paste an image |
| `<Leader>nq` | Open or create a note in `inbox/` |
| `<Leader>nr` | Rename the current note through LSP |
| `<Leader>ns` | Search vault contents |
| `<Leader>nS` | Synchronize the vault manually |
| `<Leader>nt` | Create a note from a template |

Visual-mode note mappings:

| Mapping | Action |
|---|---|
| `<Leader>ne` | Extract the selection into a note |
| `<Leader>nl` | Link the selection |
| `<Leader>nN` | Create a linked note from the selection |

These mappings require the Obsidian integration and, where applicable, a
current file inside the configured vault.

## Other: `<Leader>o`

| Mapping | Action |
|---|---|
| `<Leader>or` | Resize the current window to its editable width |
| `<Leader>ot` | Remove trailing whitespace |
| `<Leader>oz` | Toggle zoom for the current window |

## Sessions: `<Leader>s`

| Mapping | Action |
|---|---|
| `<Leader>sd` | Delete a saved session |
| `<Leader>sn` | Create a named session |
| `<Leader>sr` | Read a saved session |
| `<Leader>sR` | Restart Neovim while preserving the session |
| `<Leader>sw` | Write the current session |

## Terminal: `<Leader>t`

| Mapping | Action |
|---|---|
| `<Leader>tt` | Open a vertical terminal split |
| `<Leader>tT` | Open a horizontal terminal split |

Terminal buffers are unlisted and use `bufhidden=wipe`, so closing the terminal
window removes the associated buffer.

## Visits: `<Leader>v`

| Mapping | Action |
|---|---|
| `<Leader>vc` / `<Leader>vC` | Find `core` visits globally / under the current root |
| `<Leader>vv` | Add the `core` label to the current path |
| `<Leader>vV` | Remove the `core` label |
| `<Leader>vl` | Add a custom visit label |
| `<Leader>vL` | Remove a custom visit label |
