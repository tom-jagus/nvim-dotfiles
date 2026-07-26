# Design decisions

This page preserves decisions that are not obvious from individual Lua lines.
The source code remains authoritative for exact values.

## D001: Own the configuration after MiniMax generation

**Status:** Accepted

MiniMax is a generator and reference configuration, not a distribution that
updates an existing setup automatically. This repository owns its resulting
configuration, reviews upstream MiniMax changes manually, and adopts only
changes that still fit the local architecture.

**Consequence:** Updating MiniMax does not mean regenerating over the repository.

## D002: Prefer `mini.nvim` before adding plugins

**Status:** Accepted

`mini.nvim` provides compatible conventions across editing, UI, navigation,
completion, Git, sessions, and utilities. A new plugin must provide a meaningful
capability that the existing modules or native Neovim do not cover.

**Consequence:** Plugin count is not a goal. Capability ownership must remain
clear.

## D003: Separate concerns into numbered plugin files

**Status:** Accepted

Options, mappings, `mini.nvim`, and third-party integrations evolve for
different reasons. Keeping them in `10_`, `20_`, `30_`, and `40_` layers makes
their ownership and startup order visible.

**Consequence:** Complex custom implementations belong in `lua/custom/`, not in
the numbered integration file.

## D004: Schedule by startup need

**Status:** Accepted

Immediate, argument-sensitive, and delayed initialization are used to minimize
time to first draw without breaking files opened from the command line.

**Consequence:** Loading policy is an implementation concern, not a reason to
make features intermittently unavailable.

## D005: Pair Mason packages with native LSP names

**Status:** Accepted

The name used by `vim.lsp.enable()` is not always the Mason registry package
name. They are stored as explicit pairs and validated before generating the two
lists.

**Consequence:** A typo fails close to configuration startup instead of silently
installing or enabling the wrong tool.

## D006: Keep formatting explicit

**Status:** Accepted

Formatting runs through `<Leader>lf` rather than on every save. Conform owns
formatter selection and uses LSP only as a fallback.

**Consequence:** Saving never causes an unexpected whole-file rewrite.

## D007: Split normal Markdown and vault ownership

**Status:** Accepted

Markdown Oxide owns normal Markdown projects. obsidian.nvim owns files inside
the configured vault. The Markdown Oxide root resolver explicitly excludes the
vault.

**Consequence:** Two semantic Markdown engines do not compete for links,
renames, or workspace behavior in the same buffer.

## D008: Use timestamped note IDs without duplicating human titles

**Status:** Accepted

Regular notes use filesystem-safe timestamped identifiers while their human
title is preserved as title and alias. Daily notes retain date-only IDs.
Creation commands search the complete vault for an exact reference before
creating a new file.

**Consequence:** Filenames remain machine-readable and sortable while repeated
creation attempts reopen the existing concept. Existing ambiguous duplicates
require an explicit selection.

## D009: Keep vault synchronization conservative

**Status:** Accepted

A custom module was chosen because the safety model is more important than
minimizing code:

- the vault must be the repository root;
- unfinished operations and conflicts stop synchronization;
- automatic sync never writes modified buffers;
- manual sync may save vault buffers explicitly;
- pull uses rebase;
- failures suspend automation until a successful manual recovery.

**Consequence:** Synchronization prefers a visible stop over guessing through
an unsafe repository state.

## D010: Preserve unsaved buffers during bulk cleanup

**Status:** Accepted

`<Leader>bo` deletes other listed, unmodified buffers and reports modified
buffers that were kept.

**Consequence:** Bulk cleanup is convenient without becoming an accidental data
loss shortcut. No forced "delete all others" mapping is provided.

## D011: Layer Git tools by scope

**Status:** Accepted

`mini.diff`, `mini.git`, and LazyGit are complementary:

- inline change work uses `mini.diff`;
- editor-native Git inspection uses `mini.git`;
- full repository operations use LazyGit.

**Consequence:** The presence of several Git interfaces is justified by
different interaction scopes, not duplicated functionality.

## D012: Treat Windows as a supported design target

**Status:** Accepted

Paths are normalized, PowerShell selection is explicit, terminal commands avoid
interactive profiles, tmux is guarded, and optional executables are detected.
Core Windows workflows are exercised rather than documented as a theoretical
port.

Vault synchronization retains the same intended behavior on both platforms,
while credentials, remotes, and vault location remain environment-owned.

**Consequence:** New platform-specific behavior must remain isolated and must
not hard-code a personal path.

## D013: Keep documentation above implementation detail

**Status:** Accepted

Documentation covers architecture, behavior, dependencies, maintenance, and
non-obvious decisions. It does not mirror every option or plugin setup line.

**Consequence:** Change the relevant documentation when behavior or ownership
changes; ordinary tuning remains documented beside the Lua source.
