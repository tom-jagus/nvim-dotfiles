# My personal Neovim configuration

A maintainable, `mini.nvim`-first Neovim configuration for software
development, data work, Markdown writing, and Git-backed Obsidian notes.

The configuration started from
[MiniMax](https://github.com/nvim-mini/MiniMax) and was deliberately extended
instead of turned into a general-purpose Neovim distribution. It favors native
Neovim capabilities, cohesive `mini.nvim` modules, explicit dependencies, and
small custom workflows over overlapping plugins.

## Highlights

- Native Neovim package management through `vim.pack`.
- Cohesive editing, navigation, completion, sessions, Git, files, and picker
  workflows built primarily with `mini.nvim`.
- Tree-sitter, native LSP, Mason-managed tools, and Conform formatting.
- Language support for Lua, Python, C#, Bash, web languages, structured data,
  Markdown, and SQL.
- Git primitives through `mini.git` and `mini.diff`, plus an optional floating
  LazyGit interface.
- Markdown-specific prose defaults, rendered Markdown, and editable pipe
  tables.
- Obsidian integration with vault-wide open-or-create note commands.
- Conservative, debounced synchronization for a Git-backed vault.
- Explicit Linux and Windows behavior, including automatic PowerShell
  selection on Windows and guarded tmux integration on non-Windows systems.

## Requirements

### Required

- [Neovim 0.12 or newer](https://neovim.io/)
- [Git](https://git-scm.com/)
- Internet access during initial plugin and tool installation
- A C compiler or another compiler supported by
  [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

### Recommended

- [ripgrep](https://github.com/BurntSushi/ripgrep) for fast file-content
  searching
- A terminal with true-color and Nerd Font symbol support
- [LazyGit](https://github.com/jesseduffield/lazygit) for the floating Git UI
- [tmux](https://github.com/tmux/tmux) when cross-pane navigation is wanted on
  Linux or another non-Windows system
- PowerShell 7 (`pwsh`) on Windows; Windows PowerShell is used as a fallback

Mason installs the configured language servers and formatters inside Neovim's
data directory. Run `:checkhealth mason` if it reports missing platform tools.

## Installation

Back up or move an existing Neovim configuration before cloning this one.

### Linux and other Unix-like systems

```bash
config_root="${XDG_CONFIG_HOME:-$HOME/.config}"
mv "$config_root/nvim" "$config_root/nvim.backup"
git clone https://github.com/tom-jagus/nvim "$config_root/nvim"
nvim
```

Skip the `mv` command when no existing configuration is present.

### Windows PowerShell

```powershell
$configRoot = if ($env:XDG_CONFIG_HOME) {
  $env:XDG_CONFIG_HOME
} else {
  $env:LOCALAPPDATA
}

$target = Join-Path $configRoot "nvim"

if (Test-Path $target) {
  Move-Item $target "$target.backup"
}

git clone https://github.com/tom-jagus/nvim $target
nvim
```

On the first start:

1. Confirm the plugins requested by `vim.pack`.
2. Allow Mason and Tree-sitter to finish installing their configured tools.
3. Restart Neovim.
4. Run the health checks from [maintenance](docs/maintenance.md).

## Vault configuration

The documentation uses this intentionally generic example:

```text
~/vault/second-brain/
```

Use the same resolved path for:

- the Obsidian workspace in `plugin/40_plugins.lua`;
- the Markdown Oxide exclusion in `after/lsp/markdown_oxide.lua`;
- the vault-sync setup in `plugin/40_plugins.lua`;
- the default in `lua/custom/vault_sync.lua`, if that default is retained.

The vault must be the root of its own Git repository and the current branch
must have an upstream before synchronization can run.

## Structure

```text
.
├── init.lua
├── plugin/
│   ├── 10_options.lua
│   ├── 20_keymaps.lua
│   ├── 30_mini.lua
│   └── 40_plugins.lua
├── lua/
│   └── custom/
│       └── vault_sync.lua
├── after/
│   ├── ftplugin/
│   │   └── markdown.lua
│   └── lsp/
│       ├── basedpyright.lua
│       ├── lua_ls.lua
│       ├── markdown_oxide.lua
│       └── ruff.lua
└── docs/
```

See [architecture](docs/architecture.md) for the responsibility and loading
rules of each layer.

## Quick start

`<Leader>` is `<Space>`.

| Mapping | Action |
|---|---|
| `<Leader>ff` | Find files |
| `<Leader>fg` | Search inside files |
| `<Leader>ed` | Open the file explorer |
| `<Leader>bd` | Delete the current buffer |
| `<Leader>bo` | Delete other unmodified listed buffers |
| `<Leader>gg` | Open LazyGit |
| `<Leader>lf` | Format the current buffer or selection |
| `<Leader>sn` | Create a session |
| `<Leader>sr` | Restore a session |
| `<Leader>nn` | Open or create a vault note |
| `<Leader>nq` | Open or create a quick note |
| `<Leader>nS` | Synchronize the vault manually |

Press `<Leader>` and wait for `mini.clue` to show the available groups. The full
custom mapping reference is in [keymaps](docs/keymaps.md).

## Documentation

- [Architecture](docs/architecture.md)
- [Keymaps](docs/keymaps.md)
- [Tooling](docs/tooling.md)
- [Workflows](docs/workflows.md)
- [Design decisions](docs/decisions.md)
- [Maintenance and troubleshooting](docs/maintenance.md)
- [Changelog](CHANGELOG.md)

## Platform scope

Linux and Windows are supported design targets. Core editing, navigation,
plugins, language tooling, formatting, Git, and terminal behavior are designed
to work on both. Platform-specific behavior is isolated:

- PowerShell is selected only on Windows.
- tmux integration is skipped on Windows and activates only inside tmux.
- external programs are detected before optional integrations are enabled.
- paths are normalized before vault membership and repository-root checks.

Vault synchronization intentionally depends on each environment's Git
credentials, remote, and upstream configuration rather than embedding any
machine-specific assumptions.

## Acknowledgements

This configuration was generated from and substantially developed from
[MiniMax](https://github.com/nvim-mini/MiniMax) by Evgeni Chasnovski. MiniMax
and `mini.nvim` are distributed under the MIT license. Third-party plugins
retain their respective licenses.

## License

The configuration-specific code and documentation in this repository are
available under the [MIT License](LICENSE).
