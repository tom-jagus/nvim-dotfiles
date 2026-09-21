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
- Language support for Lua, Python, C#, Bash, web languages, structured data
  with JSON/YAML schemas, Markdown, and SQL.
- Git primitives through `mini.git` and `mini.diff`, plus an optional floating
  LazyGit interface.
- Python debugging through `nvim-dap`, `nvim-dap-python`, and Mason-managed
  `debugpy`; interactive database work through Dadbod UI.
- Markdown-specific prose defaults, rendered Markdown, and editable pipe
  tables.
- Obsidian integration with vault-wide open-or-create note commands.
- Conservative, debounced synchronization for a Git-backed vault.
- Explicit platform behavior, including automatic PowerShell selection on Windows
  and Herdr-based split and pane navigation.

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
- [Herdr](https://github.com/lmilojevicc/herdr) for split and pane navigation
- PowerShell 7 (`pwsh`) on Windows; Windows PowerShell is used as a fallback

Mason installs the configured language servers and formatters inside Neovim's
data directory. Run `:checkhealth mason` if it reports missing platform tools.

## Installation

Clone this repository anywhere outside Neovim's configuration directory, then
link its `nvim/` directory into the active configuration location:

```bash
git clone https://github.com/tom-jagus/nvim ~/src/nvim
cd ~/src/nvim
./install.sh
```

The installer creates `${XDG_CONFIG_HOME:-$HOME/.config}/nvim` as a symlink to
this repository's `nvim/` directory. It refuses to replace an existing config;
use `./install.sh --backup` to move that config to a timestamped backup first.

The installer currently targets Bash environments. Native Windows users can use
Git Bash or create the equivalent directory symlink manually.

On the first start:

1. Confirm the plugins requested by `vim.pack`.
2. Allow Mason and Tree-sitter to finish installing their configured tools.
3. Restart Neovim.
4. Run the health checks from [maintenance](docs/maintenance.md).

## Vault configuration

The documentation uses this intentionally generic example:

```text
~/valuts/default/
```

Configure the vault once in `nvim/lua/custom/settings.lua`. The Obsidian
workspace, Markdown Oxide exclusion, and vault-sync module all consume that
value.

The vault must be the root of its own Git repository and the current branch
must have an upstream before synchronization can run.

## Structure

```text
.
├── nvim/                  # Symlinked to ~/.config/nvim by install.sh
│   ├── init.lua
│   ├── after/
│   ├── lua/
│   ├── plugin/
│   ├── snippets/
│   └── nvim-pack-lock.json
├── docs/
├── install.sh
├── LICENSE
└── README.md
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
- Herdr owns split and pane navigation through `<C-h/j/k/l>` and pane resizing
  through `<M-h/j/k/l>`.
- external programs are detected before optional integrations are enabled.
- vault paths are expanded, normalized, and canonicalized before comparisons.

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
