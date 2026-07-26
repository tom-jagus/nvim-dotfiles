# Changelog

All notable changes to this configuration are recorded here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and releases follow [Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-07-27

### Added

- MiniMax-derived, `mini.nvim`-first configuration architecture.
- Native `vim.pack` plugin management and package lockfile support.
- Numbered configuration layers for options, keymaps, `mini.nvim`, and
  selectively added plugins.
- Catppuccin Mocha theme with transparent editor background and readable
  floating windows.
- File navigation, fuzzy finding, completion, snippets, sessions, visits,
  buffer management, statusline, tabline, and editing operators through
  `mini.nvim`.
- Tree-sitter parsing for programming, web, data, configuration, and Markdown
  file types.
- Native LSP with Mason-managed language servers for Lua, Markdown, Python,
  Bash, HTML, CSS, TypeScript, JSON, YAML, TOML, and SQL.
- Conform-based explicit formatting with LSP fallback.
- Git workflows through `mini.git`, `mini.diff`, and an optional floating
  LazyGit terminal.
- Linux/tmux navigation and Windows PowerShell integration.
- Markdown prose defaults, rendered Markdown, table alignment, and spell
  checking.
- Obsidian workspace integration, daily notes, templates, attachments,
  vault-wide search, and exact open-or-create note behavior.
- Conservative manual and debounced Git synchronization for an Obsidian vault.
- Safe "delete other buffers" mapping that preserves modified buffers.
- Architecture, workflow, tooling, keymap, decision, and maintenance
  documentation.
- MIT license.
