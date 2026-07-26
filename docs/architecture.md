# Architecture

## Design goal

The configuration is a maintained personal system rather than a Neovim
distribution. It uses MiniMax as a readable foundation, keeps `mini.nvim` as
the default implementation layer, and adds third-party plugins only where they
provide a capability that the foundation does not cover well.

The main architectural constraints are:

- one clear owner for each capability;
- predictable startup behavior;
- explicit external dependencies;
- platform-specific behavior behind narrow guards;
- custom code only for workflows with project-specific safety requirements.

## Configuration layers

| Layer | Responsibility |
|---|---|
| `init.lua` | Bootstraps the configuration, `mini.nvim`, shared `Config` helpers, and native package management. |
| `plugin/10_options.lua` | Built-in Neovim behavior, diagnostics, terminal buffers, and Windows shell selection. |
| `plugin/20_keymaps.lua` | General mappings, semantic Leader groups, and small mapping helpers. |
| `plugin/30_mini.lua` | All enabled `mini.nvim` modules and their integration. |
| `plugin/40_plugins.lua` | Tree-sitter, LSP, Mason, formatting, visual theme, Markdown/Obsidian features, and other selective plugins. |
| `after/lsp/*.lua` | Server-specific configuration loaded by native LSP. |
| `after/ftplugin/markdown.lua` | Buffer-local prose and Markdown editing defaults. |
| `lua/custom/vault_sync.lua` | Stateful, safety-oriented Git synchronization for the configured vault. |

The numbered files are ordered by concern, not by plugin category alone.
Options and mappings remain readable independently from plugin setup, while
custom modules are placed on the normal Lua runtime path.

## Startup phases

MiniMax supplies three scheduling helpers used throughout the configuration.

| Helper | Use |
|---|---|
| `Config.now()` | Initialize behavior required during startup or before the first screen draw. |
| `Config.now_if_args()` | Initialize immediately when startup opens a file or directory; otherwise defer until after the first draw. |
| `Config.later()` | Initialize behavior that can safely wait until after the first draw. |

Examples:

- theme, statusline, sessions, Mason, and foundational mappings load
  immediately;
- Tree-sitter, LSP, completion, files, Obsidian, and rendered Markdown must be
  available for files opened at startup;
- heavier convenience modules and optional integrations load later.

This is performance scheduling, not feature gating. A deferred feature remains
available after startup.

## Capability ownership

| Capability | Owner | Supporting component |
|---|---|---|
| General editing/navigation | Neovim + `mini.nvim` | Tree-sitter for structural context |
| File explorer | `mini.files` | `mini.icons` |
| Fuzzy finding | `mini.pick` | `mini.extra`, ripgrep |
| Completion | `mini.completion` | native LSP, `mini.snippets`, friendly-snippets |
| Language intelligence | native `vim.lsp` | nvim-lspconfig, Mason |
| Formatting | Conform | LSP fallback |
| Git primitives | `mini.git` + `mini.diff` | Git executable |
| Full Git interface | LazyGit | custom floating terminal |
| Sessions | `mini.sessions` | Neovim session files |
| Markdown language intelligence outside the vault | Markdown Oxide | native LSP |
| Vault-aware Markdown behavior | obsidian.nvim | `mini.pick` |
| Markdown presentation | render-markdown.nvim | Tree-sitter |
| Markdown table source alignment | markdown-table-mode.nvim | buffer-local Markdown behavior |
| Vault synchronization | `lua/custom/vault_sync.lua` | Git executable |

The apparent overlaps are intentional:

- `mini.git` and `mini.diff` provide editor-native primitives; LazyGit provides
  the complete interactive Git UI.
- render-markdown changes presentation; table mode changes the source text.
- Markdown Oxide owns normal Markdown workspaces; obsidian.nvim owns the vault.
- ShaDa, persistent undo, sessions, and visits preserve different kinds of
  state.

## Platform boundaries

Platform-specific logic stays local:

- `10_options.lua` selects `pwsh`, then Windows PowerShell, only on Windows.
- terminal buffers are unlisted and wiped when hidden on all platforms.
- tmux navigation is skipped on Windows and only replaces split navigation
  while `$TMUX` exists.
- LazyGit is registered only when its executable is available.
- vault paths are expanded, normalized, and canonicalized before comparisons.

No documentation or configuration should embed a workstation-specific absolute
path. Use an expandable home-relative path such as:

```text
~/vault/second-brain/
```

## Custom-module boundary

`vault_sync.lua` is a module rather than an inline block because it owns:

- mutable state;
- asynchronous subprocesses;
- a debounce timer;
- Git safety checks;
- failure recovery;
- autocmd and user-command registration.

Keeping this in `lua/custom/` prevents `40_plugins.lua` from becoming the
implementation of a complex subsystem. The setup call remains at top level so
the `:VaultSync` command and autocmds exist regardless of how Neovim was
started.

## Source-of-truth rule

The Lua source is authoritative for exact option values, plugin settings, and
dependency names. Documentation explains why the system is structured this way
and how its workflows behave. Do not duplicate line-by-line configuration in
the docs.
