-- ┌─────────────────────────┐
-- │ Plugins outside of MINI │
-- └─────────────────────────┘
--
-- This file contains installation and configuration of plugins outside of MINI.
-- They significantly improve user experience in a way not yet possible with MINI.
-- These are mostly plugins that provide programming language specific behavior.
--
-- Use this file to install and configure other such plugins.

-- Make concise helpers for installing/adding plugins in two stages
local add = vim.pack.add
local now_if_args, later = Config.now_if_args, Config.later

-- Keep LSP configuration names and Mason Package names paired explicitly.
-- The first value is used by 'vim.lsp.enable()', the second by Mason
local language_servers = {
  -- Neovim
  { lsp = "lua_ls", mason = "lua-language-server" },

  -- Writing
  { lsp = "markdown_oxide", mason = "markdown-oxide" },

  -- Programming languages
  { lsp = "basedpyright", mason = "basedpyright" },
  { lsp = "ruff", mason = "ruff" },

  { lsp = 'bashls', mason = 'bash-language-server' },

  { lsp = 'html', mason = 'html-lsp' },
  { lsp = 'cssls', mason = 'css-lsp' },
  { lsp = 'ts_ls', mason = 'typescript-language-server' },

  -- Structured data and config
  { lsp = 'jsonls', mason = 'json-lsp' },
  { lsp = "yamlls", mason = "yaml-language-server" },
  { lsp = "taplo", mason = "taplo" },

  -- Data and databases
  { lsp = "sqruff", mason = "sqruff" },
}

for _, server in ipairs(language_servers) do
  assert(server.lsp, 'Missing LSP name for Mason package: ' .. server.mason)
  assert(server.mason, 'Missing Mason package for LSP: ' .. server.lsp)
end

local lsp_names = vim.tbl_map(function(server)
  return server.lsp
end, language_servers)

local mason_tools = vim.tbl_map(function(server)
  return server.mason
end, language_servers)

vim.list_extend(mason_tools, {
  -- Standalone formatters and linters
  "prettier",
  "stylua",
  "debugpy",
})

-- Tree-sitter ================================================================

-- Tree-sitter is a tool for fast incremental parsing. It converts text into
-- a hierarchical structure (called tree) that can be used to implement advanced
-- and/or more precise actions: syntax highlighting, textobjects, indent, etc.
--
-- Tree-sitter support is built into Neovim (see `:h treesitter`). However, it
-- requires two extra pieces that don't come with Neovim directly:
-- - Language parsers: programs that convert text into trees. Some are built-in
--   (like for Lua), 'nvim-treesitter' provides many others.
--   NOTE: It requires third party software to build and install parsers.
--   See the link for more info in "Requirements" section of the MiniMax README.
-- - Query files: definitions of how to extract information from trees in
--   a useful manner (see `:h treesitter-query`). 'nvim-treesitter' also provides
--   these, while 'nvim-treesitter-textobjects' provides the ones for Neovim
--   textobjects (see `:h text-objects`, `:h MiniAi.gen_spec.treesitter()`).
--
-- Add these plugins now if file (and not 'mini.starter') is shown after startup.
--
-- Troubleshooting:
-- - Run `:checkhealth vim.treesitter nvim-treesitter` to see potential issues.
-- - In case of errors related to queries for Neovim bundled parsers (like `lua`,
--   `vimdoc`, `markdown`, etc.), manually install them via 'nvim-treesitter'
--   with `:TSInstall <language>`. Be sure to have necessary system dependencies
--   (see MiniMax README section for software requirements).
now_if_args(function()
  -- Define hook to update tree-sitter parsers after plugin is updated
  local ts_update = function()
    vim.cmd("TSUpdate")
  end
  Config.on_packchanged("nvim-treesitter", { "update" }, ts_update, ":TSUpdate")

  add({
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  })

  -- Define languages which will have parsers installed and auto enabled
  -- After changing this, restart Neovim once to install necessary parsers. Wait
  -- for the installation to finish before opening a file for added language(s).
  local languages = {
    --Neovim configuration
    "lua",
    "vim",
    "vimdoc",
    "query",

    -- Writing
    "markdown",
    "markdown_inline",

    -- Programming languages
    "python",
    "c_sharp",

    -- Shell
    "bash",

    -- Web
    "html",
    "css",
    "scss",
    "javascript",
    "typescript",
    "tsx",

    -- Structured data and config
    "json",
    "yaml",
    "toml",

    -- Data and databases
    "csv",
    "tsv",
    "sql",
  }
  local isnt_installed = function(lang)
    return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
  end
  local to_install = vim.tbl_filter(isnt_installed, languages)
  if #to_install > 0 then
    require("nvim-treesitter").install(to_install)
  end

  -- Enable tree-sitter after opening a file for a target language
  local filetypes = {}
  for _, lang in ipairs(languages) do
    for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
      table.insert(filetypes, ft)
    end
  end
  local ts_start = function(ev)
    vim.treesitter.start(ev.buf)
  end
  Config.new_autocmd("FileType", filetypes, ts_start, "Start tree-sitter")
end)

-- Language servers ===========================================================

-- Language Server Protocol (LSP) is a set of conventions that power creation of
-- language specific tools. It requires two parts:
-- - Server - program that performs language specific computations.
-- - Client - program that asks server for computations and shows results.
--
-- Here Neovim itself is a client (see `:h vim.lsp`). Language servers need to
-- be installed separately based on your OS, CLI tools, and preferences.
-- See note about 'mason.nvim' at the bottom of the file.
--
-- Neovim's team collects commonly used configurations for most language servers
-- inside 'neovim/nvim-lspconfig' plugin.
--
-- Add it now if file (and not 'mini.starter') is shown after startup.
--
-- Troubleshooting:
-- - Run `:checkhealth vim.lsp` to see potential issues.
now_if_args(function()
  add({
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/b0o/SchemaStore.nvim",
  })

  -- Keep JSON and YAML schemas in one maintained catalog. Disable YAML LS's
  -- built-in catalog to avoid duplicate schema registrations.
  local schemastore = require('schemastore')
  vim.lsp.config('jsonls', {
    settings = {
      json = {
        schemas = schemastore.json.schemas(),
        validate = { enable = true },
      },
    },
  })
  vim.lsp.config('yamlls', {
    settings = {
      yaml = {
        schemaStore = { enable = false, url = '' },
        schemas = schemastore.yaml.schemas(),
      },
    },
  })

  -- Use `:h vim.lsp.enable()` to automatically enable language server based on
  -- the rules provided by 'nvim-lspconfig'.
  -- Use `:h vim.lsp.config()` or 'after/lsp/' directory to configure servers.
  vim.lsp.enable(lsp_names)
end)

-- Formatting =================================================================

-- Programs dedicated to text formatting (a.k.a. formatters) are very useful.
-- Neovim has built-in tools for text formatting (see `:h gq` and `:h 'formatprg'`).
-- They can be used to configure external programs, but it might become tedious.
--
-- The 'stevearc/conform.nvim' plugin is a good and maintained solution for easier
-- formatting setup.
later(function()
  add({ "https://github.com/stevearc/conform.nvim" })

  -- See also:
  -- - `:h Conform`
  -- - `:h conform-options`
  -- - `:h conform-formatters`
  local prettier = { "prettier" }
  require("conform").setup({
    default_format_opts = {
      -- Allow formatting from LSP server if no dedicated formatter is available
      lsp_format = "fallback",
    },
    -- Map of filetype to formatters
    -- Make sure that necessary CLI tool is available
    formatters_by_ft = {
      -- Neovim
      lua = { "stylua" },

      -- Writing

      -- Programming languages
      python = { "ruff_format" },

      -- Shell

      -- Web
      html = prettier,
      css = prettier,
      scss = prettier,
      javascript = prettier,
      javascriptreact = prettier,
      typescript = prettier,
      typescriptreact = prettier,

      -- Structured data and config
      json = prettier,
      jsonc = prettier,
      yaml = prettier,
      toml = { "taplo" },

      -- Data and databases
      sql = { "sqruff" },
    },
  })
end)

-- Debugging ==================================================================

-- 'nvim-dap' provides the Debug Adapter Protocol client. The Python extension
-- uses Mason's debugpy installation, while dap-ui and virtual text make a
-- paused debugging session inspectable without leaving Neovim.
later(function()
  add({
    'https://github.com/mfussenegger/nvim-dap',
    'https://github.com/mfussenegger/nvim-dap-python',
    'https://github.com/rcarriga/nvim-dap-ui',
    'https://github.com/nvim-neotest/nvim-nio',
    'https://github.com/theHamsta/nvim-dap-virtual-text',
  })

  local dap = require('dap')
  local dapui = require('dapui')
  local debugpy_root = vim.fs.joinpath(vim.fn.stdpath('data'), 'mason', 'packages', 'debugpy', 'venv')
  local debugpy_python = vim.fs.joinpath(
    debugpy_root,
    vim.fn.has('win32') == 1 and 'Scripts/python.exe' or 'bin/python'
  )

  require('dap-python').setup(debugpy_python)
  dapui.setup()
  require('nvim-dap-virtual-text').setup()

  dap.listeners.after.event_initialized['config'] = dapui.open
  dap.listeners.before.event_terminated['config'] = dapui.close
  dap.listeners.before.event_exited['config'] = dapui.close
end)

-- Database ===================================================================

-- Dadbod provides database connections and query execution; Dadbod UI supplies
-- an interactive connection and result browser. Configure connections through
-- `:DBUIAddConnection` instead of storing credentials in this repository.
later(function()
  add({
    'https://github.com/tpope/vim-dadbod',
    'https://github.com/kristijanhusak/vim-dadbod-ui',
  })
end)

-- Snippets ===================================================================

-- Although 'mini.snippets' provides functionality to manage snippet files, it
-- deliberately doesn't come with those.
--
-- The 'rafamadriz/friendly-snippets' is currently the largest collection of
-- snippet files. They are organized in 'snippets/' directory (mostly) per language.
-- 'mini.snippets' is designed to work with it as seamlessly as possible.
-- See `:h MiniSnippets.gen_loader.from_lang()`.
later(function()
  add({ "https://github.com/rafamadriz/friendly-snippets" })
end)

-- Honorable mentions =========================================================

-- 'mason-org/mason.nvim' (a.k.a. "Mason") is a great tool (package manager) for
-- installing external language servers, formatters, and linters. It provides
-- a unified interface for installing, updating, and deleting such programs.
--
-- The caveat is that these programs will be set up to be mostly used inside Neovim.
-- If you need them to work elsewhere, consider using other package managers.
--
-- You can use it like so:
-- now_if_args(function()
--   add({ 'https://github.com/mason-org/mason.nvim' })
--   require('mason').setup()
-- end)

-- Beautiful, usable, well maintained color schemes outside of 'mini.nvim' and
-- have full support of its highlight groups. Use if you don't like 'miniwinter'
-- enabled in 'plugin/30_mini.lua' or other suggested 'mini.hues' based ones.
-- Config.now(function()
--  -- Install only those that you need
--  add({
--    'https://github.com/sainnhe/everforest',
--    'https://github.com/Shatur/neovim-ayu',
--    'https://github.com/ellisonleao/gruvbox.nvim',
--  })
--
--   -- Enable only one
--   vim.cmd('color everforest')
-- end)

-- My plugins =================================================================
--
-- This section contains personal integrations beyond the MiniMax baseline.
-- Each subsection briefly states its role; setup details remain with the code.

-- Tool installation ==========================================================
-- Mason installs the language servers, formatters, and debug tools listed above.
Config.now(function()
  add({
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  })
  require("mason").setup()

  require("mason-tool-installer").setup({
    ensure_installed = mason_tools,

    -- Install missing tools on startup, but update only when requested
    -- through `:MasonToolsUpdate` so tool changes remain deliberate.
    run_on_start = true,
    auto_update = false,
    start_delay = 1000,

    -- Every item above uses an exact Mason reqistry package name.
    integrations = {
      ["mason-lspconfig"] = false,
      ["mason-null-ls"] = false,
      ["mason-nvim-dap"] = false,
    },
  })
end)

-- Colorscheme ================================================================
-- Catppuccin provides the configured theme and Mini integration.
Config.now(function()
  add({
    {
      src = "https://github.com/catppuccin/nvim",
      name = "catppuccin",
    },
  })

  require("catppuccin").setup({
    flavour = "mocha",
    transparent_background = true,

    -- Keep floating windows readable over a transparent terminal.
    float = {
      transparent = false,
      solid = false,
    },

    -- Usefull for :terminal buffers.
    term_colors = true,

    -- Keep integrations explicit.
    default_integrations = false,
    integrations = {
      mini = {
        enabled = true,
        indentscope_color = "lavender",
      },
    },

    -- Customized highlights
    custom_highlights = function(colors)
      return {
        LineNr = {
          fg = colors.subtext1,
        },
        CursorLineNr = {
          fg = colors.lavender,
          style = { "bold" },
        },
        EndOfBuffer = {
          fg = colors.subtext1,
        },
      }
    end,
  })

  vim.cmd.colorscheme("catppuccin-mocha")
end)

-- Split and pane navigation =================================================
-- Herdr is the primary split and pane navigation provider. It owns Normal-mode
-- `<C-hjkl>` for navigation and `<M-hjkl>` for resizing. Configure it eagerly:
-- setup writes the matching Herdr-side key configuration.
Config.now(function()
  add({ 'https://github.com/lmilojevicc/herdr-splits.nvim' })

  local navigation = require('herdr-splits')
  navigation.setup({
    auto_sync_herdr = true,
  })

  local map = vim.keymap.set
  map('n', '<C-h>', navigation.move_cursor_left,  { desc = 'Navigate left', silent = true })
  map('n', '<C-j>', navigation.move_cursor_down,  { desc = 'Navigate down', silent = true })
  map('n', '<C-k>', navigation.move_cursor_up,    { desc = 'Navigate up', silent = true })
  map('n', '<C-l>', navigation.move_cursor_right, { desc = 'Navigate right', silent = true })
  map('n', '<M-h>', navigation.resize_left,       { desc = 'Resize left', silent = true })
  map('n', '<M-j>', navigation.resize_down,       { desc = 'Resize down', silent = true })
  map('n', '<M-k>', navigation.resize_up,         { desc = 'Resize up', silent = true })
  map('n', '<M-l>', navigation.resize_right,      { desc = 'Resize right', silent = true })
end)

-- LazyGit ====================================================================
-- Optional floating terminal UI; registered only when the executable exists.
Config.later(function()
  if vim.fn.executable("lazygit") ~= 1 then
    return
  end

  vim.api.nvim_create_user_command("LazyGit", function()
    local width = math.floor(vim.o.columns * 0.9)
    local height = math.floor(vim.o.lines * 0.9)

    local buf = vim.api.nvim_create_buf(false, true)

    local normal_float = vim.api.nvim_get_hl(0, {
      name = "NormalFloat",
      link = false,
    })

    if normal_float.bg then
      vim.b[buf].terminal_color_0 = string.format("#%06x", normal_float.bg)
    end

    local win = vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      style = "minimal",
      border = "single",
      title = " LazyGit ",
      title_pos = "center",
      width = width,
      height = height,
      col = math.floor((vim.o.columns - width) / 2),
      row = math.floor((vim.o.lines - height) / 2),
    })

    vim.wo[win].winhighlight = "Normal:NormalFloat"

    vim.wo[win].winblend = 8

    local function cleanup()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end

      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end

    local job = vim.fn.jobstart({ "lazygit" }, {
      term = true,
      cwd = vim.fn.getcwd(),

      on_exit = function()
        vim.schedule(cleanup)
      end,
    })

    if job <= 0 then
      cleanup()
      vim.notify("Could not start LazyGit", vim.log.levels.ERROR)
      return
    end

    vim.cmd.startinsert()
  end, {
    desc = "Open LazyGit in a floating terminal",
  })
end)

-- Pi bridge ==================================================================
-- Send editor context to an existing Pi session in another terminal pane.
-- The matching Pi extension must also be installed; mappings live in 20_keymaps.lua.
later(function()
  add({ 'https://github.com/carderne/pi-nvim' })
  require('pi-nvim').setup({ set_default_keymaps = false })
end)

-- CSV ========================================================================
-- CSVView adds table-oriented navigation and display for CSV buffers.
Config.later(function()
  add({
    { src = "https://github.com/hat0uma/csvview.nvim" },
  })
  require("csvview").setup()
end)

-- Obsidian ===================================================================
-- Vault notes, custom open-or-create commands, and Git synchronization.
now_if_args(function()
  add({
    {
      src = "https://github.com/obsidian-nvim/obsidian.nvim",
      version = vim.version.range("*"),
    },
  })

  local vault = require('custom.settings').vault
  local vault_name = vault.name
  local vault_path = vault.path
  local inbox_path = vault.inbox_dir
  local daily_path = vault.daily_dir
  local notes_path = vault.notes_dir
  local attachments_path = vault.attachments_dir
  local templates_path = vault.templates_dir

  local function slugify(title)
    local slug = vim.trim(title or 'untitled'):lower()

    slug = slug:gsub('[%c<>:"/\\|?*]+', '-')
    slug = slug:gsub('[%s_]+', '-')
    slug = slug:gsub('%-+', '-')
    slug = slug:gsub('^[%.%- ]+', ''):gsub('[%.%- ]+$', '')

    return slug ~= '' and slug or 'untitled'
  end

  local function note_id(title, path)
    local note_dir = vim.fs.normalize(tostring(path)):gsub('\\', '/')

    -- Daily notes retain their date-only ID so repeated calls open the
    -- existing note instead of generating another timestamped file.
    if note_dir:match('/daily$') then
      return assert(title)
    end

    local base = os.date('%Y-%m-%d-%H%M%S-') .. slugify(title)
    local id = base
    local suffix = 2

    while vim.uv.fs_stat(vim.fs.joinpath(tostring(path), id .. '.md')) do
      id = base .. '-' .. suffix
      suffix = suffix + 1
    end

    return id
  end

  require('obsidian').setup({
    legacy_commands = false,

    workspaces = {
      {
        name = vault_name,
        path = vault_path,
        strict = true,
      },
    },

    notes_subdir = notes_path,
    new_notes_location = 'notes_subdir',
    note_id_func = note_id,

    daily_notes = {
      folder = daily_path,
      date_format = '%Y-%m-%d',
      workdays_only = false,
    },

    templates = {
      folder = templates_path,
      date_format = '%Y-%m-%d',
      time_format = '%H:%M',
    },

    attachments = {
      folder = attachments_path,
    },

    picker = {
      name = 'mini.pick'
    },

    link = {
      style = 'wiki',
      format = 'shortest',
      auto_update = false,
    },
    ui = { enable = false },
  })

  local Note = require('obsidian.note')
  local search = require('obsidian.search')
  local function normalize_reference(value)
    value = vim.trim(tostring(value or ''))
    return vim.fn.tolower(value)
  end

  local function is_exact_match(note, title)
    local expected = normalize_reference(title)

    for _, reference in ipairs(note:reference_ids()) do
      if normalize_reference(reference) == expected then
        return true
      end
    end

    return false
  end

  local function create_note(title, dir)
    local note = Note.create({
      id = title,
      title = title,
      aliases = { title },
      dir = dir,
    })

    note:write()
    note:open({ sync = true })
  end

  local function select_existing_note(matches)
    if #matches == 1 then
      matches[1]:open({ sync = true })
      return
    end

    vim.ui.select(matches, {
      prompt = 'Multiple notes use this title:',
      format_item = function(note)
        return tostring(note.path)
      end,
    }, function(note)
      if note then
        note:open({ sync = true })
      end
    end)
  end

  local function open_or_create_note(title, dir)
    title = vim.trim(title or '')

    if title == '' then
      return
    end

    search.resolve_note_async(title, function(results)
      -- The resolver may return fuzzy results if it finds no exact result.
      -- Do not treat those as the requested note.
      local exact_matches = vim.tbl_filter(function(note)
        return is_exact_match(note, title)
      end, results)

      if #exact_matches == 0 then
        create_note(title, dir)
        return
      end

      select_existing_note(exact_matches)
    end)
  end

  local function prompt_for_note(prompt, dir)
    vim.ui.input({
      prompt = prompt,
    }, function(title)
      open_or_create_note(title, dir)
    end)
  end

  vim.api.nvim_create_user_command('VaultQuickNote', function()
    prompt_for_note('Quick note title: ', inbox_path)
  end, {
    desc = 'Open or create a vault inbox note',
  })

  vim.api.nvim_create_user_command('VaultNewNote', function()
    prompt_for_note('New note title: ', notes_path)
  end, {
    desc = 'Open or create a vault note',
  })

  -- Keep synchronization setup alongside the vault configuration it uses.
  require('custom.vault_sync').setup({
    vault = vault_path,
    debounce_ms = 60 * 1000,
    sync_on_enter = true,
    notify_auto_success = false,
  })
end)

-- Markdown rendering =========================================================
now_if_args(function()
  add({
    {
      src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim',
      version = vim.version.range('*'),
    },
  })

  require('render-markdown').setup({
    file_types = { 'markdown' },

    -- Render while reading; expose raw Markdown while editing.
    render_modes = { 'n', 'c', 't' },

    pipe_table = {
      enabled = true,
      preset = 'round',
      cell = 'padded',
    },

    latex = { enabled = false },
  })
end)

-- Markdown table editing =====================================================
now_if_args(function()
  add({
    {
      src = 'https://github.com/Kicamon/markdown-table-mode.nvim',
      -- version = vim.version.range('*'),
    },
  })

  require('markdown-table-mode').setup({
    filetype = {
      '*.md',
    },

    options = {
      -- Realign while entering pipe separators.
      insert = true,

      -- Perform a final realignment when leaving insert mode.
      insert_leave = true,

      -- Produce: | --- | rather than |---|.
      pad_separator_line = true,

      -- Preserve alignment markers from the separator row.
      align_style = 'default',
    },
  })
  vim.cmd('Mtm')
end)
