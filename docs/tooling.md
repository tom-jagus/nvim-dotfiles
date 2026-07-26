# Tooling

## Tool-management model

The configuration separates three dependency layers:

1. `vim.pack` installs and updates Neovim plugins.
2. Mason installs editor-local language servers and formatters.
3. System package managers install core executables and runtimes such as
   Neovim, Git, ripgrep, LazyGit, a compiler, and PowerShell.

Mason package names and native LSP configuration names are paired explicitly in
`plugin/40_plugins.lua`. Assertions reject incomplete entries rather than
silently producing a sparse tool list.

## Language servers

| Area | File types | Native LSP name | Mason package |
|---|---|---|---|
| Neovim/Lua | Lua | `lua_ls` | `lua-language-server` |
| Writing | Markdown outside the vault | `markdown_oxide` | `markdown-oxide` |
| Python | Python types and navigation | `basedpyright` | `basedpyright` |
| Python | Diagnostics and code actions | `ruff` | `ruff` |
| Shell | Bash/sh | `bashls` | `bash-language-server` |
| Web | HTML | `html` | `html-lsp` |
| Web | CSS | `cssls` | `css-lsp` |
| Web | JavaScript/TypeScript | `ts_ls` | `typescript-language-server` |
| Structured data | JSON/JSONC | `jsonls` | `json-lsp` |
| Structured data | YAML | `yamlls` | `yaml-language-server` |
| Structured data | TOML | `taplo` | `taplo` |
| Data | SQL | `sqruff` | `sqruff` |

Server-specific behavior lives under `after/lsp/`:

- `lua_ls.lua` models Neovim's LuaJIT runtime and runtime library.
- `basedpyright.lua` leaves import organization to Ruff.
- `ruff.lua` disables Ruff hover so BasedPyright remains the single hover
  provider.
- `markdown_oxide.lua` refuses to attach inside the Obsidian vault.

## Formatting

Formatting is explicit through `<Leader>lf`; it is not automatically applied
on save.

| File type | Formatter |
|---|---|
| Lua | StyLua |
| Python | Ruff formatter |
| HTML, CSS, SCSS | Prettier |
| JavaScript and JSX | Prettier |
| TypeScript and TSX | Prettier |
| JSON and JSONC | Prettier |
| YAML | Prettier |
| TOML | Taplo |
| SQL | Sqruff |

Conform falls back to an attached LSP only when no dedicated formatter is
configured. Use `:ConformInfo` to inspect the formatter selected for the
current buffer.

## Tree-sitter

Parsers are installed and enabled for:

| Category | Parsers |
|---|---|
| Neovim | `lua`, `vim`, `vimdoc`, `query` |
| Writing | `markdown`, `markdown_inline` |
| Programming | `python`, `c_sharp` |
| Shell | `bash` |
| Web | `html`, `css`, `scss`, `javascript`, `typescript`, `tsx` |
| Structured data | `json`, `yaml`, `toml` |
| Data | `csv`, `tsv`, `sql` |

Tree-sitter is started from `FileType` autocmds for the filetypes mapped to
these parsers. Missing parsers are installed after the configured language list
changes.

## `mini.nvim` modules

The configuration enables a broad but cohesive subset of `mini.nvim`:

| Area | Modules |
|---|---|
| Foundation/UI | `mini.basics`, `mini.icons`, `mini.notify`, `mini.statusline`, `mini.tabline`, `mini.starter`, `mini.clue`, `mini.input`, `mini.cmdline` |
| Files/navigation | `mini.files`, `mini.pick`, `mini.extra`, `mini.visits`, `mini.jump`, `mini.jump2d`, `mini.bracketed`, `mini.map` |
| Editing | `mini.ai`, `mini.align`, `mini.bufremove`, `mini.indentscope`, `mini.keymap`, `mini.move`, `mini.pairs`, `mini.splitjoin`, `mini.surround`, `mini.trailspace` |
| Language support | `mini.completion`, `mini.snippets` |
| Git | `mini.git`, `mini.diff` |
| State/utilities | `mini.sessions`, `mini.misc`, `mini.hipatterns` |

Several available modules remain intentionally disabled when their behavior is
not needed or is already covered by native Neovim.

## Selective third-party plugins

| Plugin | Purpose |
|---|---|
| nvim-treesitter | Parser installation and query files |
| nvim-treesitter-textobjects | Structural textobject queries |
| nvim-lspconfig | Native LSP configuration definitions |
| mason.nvim | Editor-local external tool management |
| mason-tool-installer.nvim | Declarative tool installation |
| conform.nvim | Formatter orchestration |
| friendly-snippets | Community snippet collection |
| catppuccin.nvim | Catppuccin Mocha theme |
| nvim-tmux-navigation | Seamless Neovim/tmux pane navigation |
| csvview.nvim | On-demand CSV/TSV tabular view |
| obsidian.nvim | Vault-aware Markdown and note operations |
| render-markdown.nvim | Rendered Markdown presentation |
| markdown-table-mode.nvim | Source-level Markdown table alignment |

LazyGit is an external executable opened in a custom floating terminal; it is
not installed as a Neovim plugin.

## CSV workflow

CSVView remains opt-in to avoid automatically parsing very large delimited
files. Use:

```vim
:CsvViewToggle
```

or the plugin's explicit enable and disable commands when a structured view is
useful.

## Intentionally absent

There is no separate linter framework, DAP client, test runner, database client,
or domain-specific Power Query/DAX/TMDL integration in version 1. Installed
tools should have an active consumer; otherwise they should not be added merely
for completeness.
