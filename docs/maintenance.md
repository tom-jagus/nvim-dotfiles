# Maintenance

## Update policy

Updates are deliberate and reviewed in layers. Do not update every dependency,
Mason tool, Tree-sitter parser, and configuration file simultaneously; that
makes regressions needlessly difficult to isolate.

### Plugins

Inspect and update packages managed by native `vim.pack`:

```vim
:lua vim.pack.update()
```

Review the proposed changes before applying them. Restart Neovim afterward.

### Mason tools

Open Mason's interface:

```vim
:Mason
```

Install missing declared tools on startup. Apply deliberate upgrades with:

```vim
:MasonToolsUpdate
```

Mason tools are editor-local. System runtimes such as Neovim, Git, a compiler,
and PowerShell remain the responsibility of the operating system's package
management.

### Tree-sitter parsers

```vim
:TSUpdate
```

The configuration also runs `:TSUpdate` after the nvim-treesitter package is
updated.

### MiniMax upstream

MiniMax does not automatically update this repository. Periodically inspect its
[changelog](https://github.com/nvim-mini/MiniMax/blob/main/CHANGELOG.md) and the
reference configuration matching the Neovim version. Port useful changes
manually; do not regenerate over local customizations.

## Health checks

Run after installation, a major update, or a toolchain change:

```vim
:checkhealth
:checkhealth vim.lsp
:checkhealth vim.treesitter nvim-treesitter
:checkhealth mason
:LspInfo
:ConformInfo
```

Also inspect:

```vim
:Mason
:messages
```

Health warnings are not automatically defects. Evaluate whether the reported
capability is part of this configuration's active workflow.

## Release smoke test

### Startup modes

Run each from a shell:

```bash
nvim
nvim .
nvim path/to/file.lua
nvim ~/vault/second-brain/notes/example.md
```

Verify:

- the starter appears only for an argument-free start;
- file-oriented plugins are ready when a file is opened directly;
- directory startup opens a usable project context;
- vault commands and rendering are available for a directly opened vault note;
- entering the vault later also initializes the same behavior.

### Language acceptance test

Use one representative project file for every active workflow:

| Area | Verify |
|---|---|
| Lua | Tree-sitter, `lua_ls`, completion, diagnostics, StyLua |
| Python | BasedPyright + Ruff attachment, single hover owner, Ruff formatting |
| Bash | Tree-sitter, Bash LSP, diagnostics |
| C# | Tree-sitter parsing and highlighting |
| HTML/CSS/TypeScript | Correct LSP, completion, Prettier |
| JSON/YAML/TOML | Correct LSP, diagnostics, formatter |
| SQL | Sqruff diagnostics and formatting |
| CSV/TSV | Tree-sitter and manual CSVView activation |
| Markdown outside vault | Markdown Oxide attached |
| Markdown inside vault | Obsidian active and Markdown Oxide absent |

For LSP-backed files, verify:

- the expected client attaches;
- diagnostics appear;
- hover and navigation work;
- rename or references work where supported;
- completion works;
- `<Leader>lf` selects the intended formatter;
- the project root is correct.

### Vault acceptance test

Use a disposable Git remote or a temporary branch when testing synchronization.

1. Open an existing note through `VaultNewNote`.
2. Create a new note through `VaultNewNote`.
3. Create or reopen an inbox note through `VaultQuickNote`.
4. Confirm an existing title is opened across different sessions.
5. Confirm duplicate exact references prompt for selection.
6. Save a note and verify one debounced automatic commit/pull/push sequence.
7. Modify a vault buffer without saving and confirm automatic sync does not
   write it.
8. Run `:VaultSync` and confirm the buffer is saved explicitly.
9. Create a controlled Git conflict and confirm synchronization suspends rather
   than attempting to resolve it.
10. Resolve the conflict and confirm a successful manual sync resumes
    automation.

Do not test destructive Git states against the primary vault without a verified
backup.

## Clean-machine validation

Before a tagged release:

1. Install only the documented system requirements.
2. Clone the repository into the platform's Neovim configuration directory.
3. Start Neovim and allow native packages, Mason tools, and parsers to install.
4. Run the health checks.
5. Complete the startup and language smoke tests.
6. Validate external executables such as `rg`, `lazygit`, and Git credentials.
7. Validate platform-specific terminal behavior.
8. Record any new prerequisite in `README.md` and `docs/tooling.md`.

Linux and Windows should follow the same acceptance criteria, with tmux tested
only where it is applicable.

## Troubleshooting

### An LSP does not attach

1. Run `:LspInfo`.
2. Check the corresponding tool in `:Mason`.
3. Confirm the current filetype with `:set filetype?`.
4. Confirm the detected root.
5. Check the server's `after/lsp/` file.
6. For Markdown, confirm whether the file is intentionally inside the excluded
   vault path.

### Formatting does not run

Run:

```vim
:ConformInfo
```

Confirm the buffer filetype and that the configured formatter is installed.
Remember that formatting is manual and some filetypes intentionally rely on
LSP fallback.

### Tree-sitter highlighting fails

Run:

```vim
:checkhealth vim.treesitter nvim-treesitter
:TSUpdate
```

Confirm that a supported compiler is available and retry installation for the
specific parser.

### LazyGit does not open

The `:LazyGit` command is registered only when `lazygit` is executable. Confirm:

```vim
:echo executable('lazygit')
```

Install LazyGit through the operating system and restart Neovim.

### Vault commands are unavailable

Confirm:

- the Obsidian plugin installed successfully;
- the workspace path is correct;
- the current file is inside the strict workspace;
- the same normalized vault path is used by Obsidian, Markdown Oxide, and the
  sync module.

### Vault synchronization is suspended

From the vault repository, inspect:

```bash
git status
git branch --show-current
git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}'
git pull --rebase
git push
```

Resolve or abort any unfinished Git operation. Confirm non-interactive
credentials work, then run:

```vim
:VaultSync
```

Do not bypass the repository-root, conflict, or upstream checks.

## Documentation maintenance

Update documentation when:

- a keymap is added, removed, or changes behavior;
- a tool, server, formatter, or parser is added or removed;
- capability ownership changes;
- platform behavior changes;
- vault safety behavior changes;
- an intentional exclusion becomes implemented.

Ordinary option tuning belongs beside the Lua source unless it changes a
documented workflow or design decision.

## Release checklist

- [ ] Static Lua review passes.
- [ ] Health checks contain no unexplained active-workflow failures.
- [ ] Startup modes pass.
- [ ] Language acceptance tests pass.
- [ ] Markdown ownership is correct inside and outside the vault.
- [ ] Vault synchronization safety tests pass when changed.
- [ ] Documentation matches behavior.
- [ ] `CHANGELOG.md` contains the release.
- [ ] Working tree is clean.
- [ ] Version tag is created from the release commit.
