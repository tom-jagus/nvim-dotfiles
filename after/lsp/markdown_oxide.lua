local function normalize(path)
  return vim.fs.normalize(path):gsub('\\', '/')
end

local vault = normalize(vim.fn.expand('~/vault/second-brain'))

local function is_in_vault(path)
  path = normalize(path)
  return path == vault or vim.startswith(path, vault .. '/')
end

---@type vim.lsp.Config
return {
  root_dir = function(bufnr, on_dir)
    local path = vim.api.nvim_buf_get_name(bufnr)

    -- obsidian.nvim owns PKM features inside the vault.
    if path == '' or is_in_vault(path) then
      return
    end

    on_dir(vim.fs.root(bufnr, { '.git', '.obsidian', '.moxide.toml' }))
  end,

  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  },
}
