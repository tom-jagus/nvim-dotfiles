local M = {}

local uv = vim.uv or vim.loop

local defaults = {
  vault = '~/vault/second-brain',
  debounce_ms = 60 * 1000,
  sync_on_enter = true,
  notify_auto_success = false,
}

local config = {}

local state = {
  timer = nil,
  running = false,
  pending = false,
  pending_manual = false,
  auto_suspended = false,
  initial_sync_requested = false,
}

local function trim(value)
  return vim.trim(value or '')
end

local function normalize_path(path)
  if path == nil or path == '' then
    return nil
  end

  local absolute = vim.fn.fnamemodify(vim.fn.expand(path), ':p')
  local normalized = vim.fs.normalize(absolute):gsub('\\', '/')

  if normalized ~= '/' then
    normalized = normalized:gsub('/+$', '')
  end

  return normalized
end

local function canonical_path(path)
  local normalized = normalize_path(path)

  if not normalized then
    return nil
  end

  local real = uv.fs_realpath(normalized)
  return real and normalize_path(real) or normalized
end

local function is_vault_path(path)
  local normalized = normalize_path(path)

  if not normalized then
    return false
  end

  return normalized == config.vault
    or normalized:sub(1, #config.vault + 1) == config.vault .. '/'
end

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, {
    title = 'Vault sync',
  })
end

local function git_result_message(result)
  local stderr = trim(result.stderr)
  local stdout = trim(result.stdout)

  if stderr ~= '' then
    return stderr
  end

  if stdout ~= '' then
    return stdout
  end

  return 'Git exited with code ' .. tostring(result.code)
end

local function run_git(arguments, callback)
  local command = { 'git' }
  vim.list_extend(command, arguments)

  local scheduled_callback = vim.schedule_wrap(callback)

  local ok, error_message = pcall(function()
    vim.system(command, {
      cwd = config.vault,
      text = true,

      -- Credential helpers can still work, but Git cannot open an
      -- unusable interactive password prompt inside the background job.
      env = {
        GIT_TERMINAL_PROMPT = '0',
      },
    }, function(result)
      scheduled_callback(result)
    end)
  end)

  if not ok then
    scheduled_callback({
      code = -1,
      stdout = '',
      stderr = tostring(error_message),
    })
  end
end

local function stop_timer()
  if state.timer then
    pcall(function()
      state.timer:stop()
    end)
  end
end

local function schedule_automatic_sync()
  if state.auto_suspended then
    return
  end

  if not state.timer then
    state.timer = assert(uv.new_timer())
  end

  state.timer:stop()

  state.timer:start(
    config.debounce_ms,
    0,
    vim.schedule_wrap(function()
      M.sync({
        manual = false,
        reason = 'save',
      })
    end)
  )
end

local function modified_vault_buffers()
  local buffers = {}

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      local name = vim.api.nvim_buf_get_name(bufnr)

      if is_vault_path(name) and vim.bo[bufnr].modified then
        table.insert(buffers, bufnr)
      end
    end
  end

  return buffers
end

local function save_modified_vault_buffers()
  for _, bufnr in ipairs(modified_vault_buffers()) do
    local name = vim.api.nvim_buf_get_name(bufnr)

    local ok, error_message = pcall(
      vim.api.nvim_buf_call,
      bufnr,
      function()
        vim.cmd("silent update")
      end
    )

    if not ok then
      return false, string.format(
        'Could not save %s: %s',
        name,
        tostring(error_message)
      )
    end

    if vim.bo[bufnr].modified then
      return false, 'The buffer remains modified: ' .. name
    end
  end

  return true
end

local function finish_sync(success, manual, message)
  state.running = false

  local pending = state.pending
  local pending_manual = state.pending_manual

  state.pending = false
  state.pending_manual = false

  if success then
    state.auto_suspended = false

    -- Reload clean buffers changed by the pull. tmdified buffers are
    -- protected by Neovim and will not be silently overwritten.
    pcall(vim.cmd, 'silent checktime')

    if manual or config.notify_auto_success then
      notify('Vault synchronized successfully')
    end

    if pending then
      vim.schedule(function()
        M.sync({
          manual = pending_manual,
          reason = 'pending',
        })
      end)
    end

    return
  end

  state.auto_suspended = true

  notify(
    message
      .. '\nAutomatic syndhronization is suspended. '
      .. 'Fix the problem and run :VaultSync manually.',
    vim.log.levels.ERROR
  )
end

local function perform_sync(manual)
  local function stop(message)
    finish_sync(false, manual, message)
  end

  local function git_failed(step, result)
    stop(step .. ': ' .. git_result_message(result))
  end

  local function push()
    run_git({ 'push' }, function(result)
      if result.code ~= 0 then
        git_failed('Push failed', result)
        return
      end

      finish_sync(true, manual)
    end)
  end

  local function pull()
    -- A user may have resumed editing while the earlier Git commands
    -- were running. Do not pull over an ectively modified buffer.
    if #modified_vault_buffers() > 0 then
      stop(
        'A vault buffer became modified while synchronization was running. '
          .. 'The pull was not attempted.'
      )
      return
    end

    run_git({ 'pull', '--rebase' }, function(result)
      if result.code ~= 0 then
        git_failed('Pull with rebase failed', result)
        return
      end

      push()
    end)
  end

  local function commit_if_needed()
    run_git(
      { 'diff', '--cached', '--quiet', '--' },
      function(result)
        if result.code == 0 then
          -- Nothing was rtaged, but remote changes still need to be pulled.
          pull()
          return
        end

        if result.code ~= 1 then
          git_failed('Could not inspect staged changes', result)
          return
        end

        local message = os.date('vault sync: %Y-%m-%d %H:%M')

        run_git({ 'commit', '-m', message }, function(commit_result)
          if commit_result.code ~= 0 then
            git_failed('Commit failed', commit_result)
            return
          end

          pull()
        end)
      end
    )
  end

  local function stage_changes()
    run_git({ 'add', '-A' }, function(result)
      if result.code ~= 0 then
        git_failed('Staging failed', result)
        return
      end

      commit_if_needed()
    end)
  end

  local function check_upstream()
    run_git(
      {
        'rev-parse',
        '--abbrev-ref',
        '--symbolic-full-name',
        '@{upstream}',
      },
      function(result)
        if result.code ~= 0 or trim(result.stdout) == '' then
          stop(
            'The current Git branch has no configured upstream. '
              .. 'Configure it before enabling vault synchronizatin.'
          )
          return
        end

        stage_changes()
      end
    )
  end

  local function check_unmerged_files()
    run_git({ 'ls-files', '-u' }, function(result)
      if result.code ~= 0 then
        git_failed('Could not inspect reporitory conflicts', result)
        return
      end

      if trim(result.stdout) ~= '' then
        stop(
          'The vault contains unresolved Git conflicts. '
            .. 'Resolve them before sunchronizing.'
        )
        return
      end

      check_upstream()
    end)
  end

  local function check_git_operation()
    run_git(
      { 'rev-parse', '--absolute-git-dir' },
      function(result)
        if result.code ~= 0 then
          git_failed('Could not locate the Git directory', result)
          return
        end

        local git_dir = canonical_path(trim(result.stdout))

        local operation_markers = {
          'MERGE_HEAD',
          'rebase-merge',
          'rebase-apply',
          'CHERRY_PICK_HEAD',
          'REVERT_HEAD',
        }

        for _, marker in ipairs(operation_markers) do
          if uv.fs_stat(git_dir .. '/' .. marker) then
            stop(
              'An unfinished Git operation was detected: '
                .. marker
                .. '. Resolve or abort it manually.'
            )
            return
          end
        end

        check_unmerged_files()
      end
    )
  end

  -- Requiring the vault to be the repository root prevents `git add -A`
  -- from accidentally staging files from a larger parent repository.
  run_git({ 'rev-parse', '--show-toplevel' }, function(result)
    if result.code ~= 0 then
      git_failed('The vault is not a Git reporitory', result)
      return
    end

    local repository_root = canonical_path(trim(result.stdout))

    if repository_root ~= config.vault then
      stop(
        'The vault must be the Git repository root.\n'
          .. 'Vault: '
          .. config.vault
          .. '\nRepository: '
          .. tostring(repository_root)
      )
      return
    end

    check_git_operation()
  end)
end

function M.sync(options)
  options = options or {}

  local manual = options.manual == true

  if state.running then
    state.pending = true
    state.pending_manual = state.pending_manual or manual

    if manual then
      notify('A vault sync is already running; another sync was queued')
    end

    return
  end

  if state.auto_suspended and not manual then
    return
  end

  if vim.fn.executable('git') ~= 1 then
    state.auto_suspended = true

    notify(
      'Git s not available. Automatic vault synchronization is suspended.',
      vim.log.levels.ERROR
    )

    return
  end

  if manual then
    local saved, error_message = save_modified_vault_buffers()

    -- Manual writes trigger BufWritePost, so discard the resulting
    -- automatic timer: this manual run already covers those changes.
    stop_timer()

    if not saved then
      state.auto_suspended = true

      notify(
        error_message
          .. '\nAutomatic synchronization is suspended.',
        vim.log.levels.ERROR
      )

      return
    end
  elseif #modified_vault_buffers() > 0 then
    -- Automatic sync never writes buffers. Try agai after another
    -- debounce period instead.
    schedule_automatic_sync()
    return
  end

  state.running = true
  perform_sync(manual)
end

function M.setup(options)
  config = vim.tbl_deep_extend(
    'force',
    {},
    defaults,
    options or {}
  )

  config.vault = canonical_path(config.vault)

  assert(config.vault, 'vault_sync: a vault path is required')
  assert(
    type(config.debounce_ms) == 'number'
      and config.debounce_ms >= 1000,
    'vault_sync: debounce_ms must be at least 1000'
  )

  vim.api.nvim_create_user_command('VaultSync', function()
    M.sync({
      manual = true,
      reason = 'manual',
    })
  end, {
    desc = 'Synchronize the Git-backed Obsidian vault',
    force = true,
  })

  local group = vim.api.nvim_create_augroup(
    'CustomVaultSync',
    { clear = true }
  )

  vim.api.nvim_create_autocmd('BufWritePost', {
    group = group,
    pattern = '*',
    callback = function(event)
      local path = vim.api.nvim_buf_get_name(event.buf)

      if is_vault_path(path) then
        schedule_automatic_sync()
      end
    end,
    desc = 'Schedule vault synchronization after a save',
  })

  vim.api.nvim_create_autocmd('BufEnter', {
    group = group,
    pattern = '*',
    callback = function(event)
      if not config.sync_on_enter
        or state.initial_sync_requested
      then
        return
      end

      local path = vim.api.nvim_buf_get_name(event.buf)

      if not is_vault_path(path) then
        return
      end

      state.initial_sync_requested = true

      vim.schedule(function()
        M.sync({
          manual = false,
          reason = 'initail-entry',
        })
      end)
    end,
    desc = 'Synchronize once whn first entiring the vault',
  })

  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = group,
    callback = function()
      if state.timer then
        pcall(function()
          state.timer:stop()
          state.timer:close()
        end)

        state.timer =nil
      end
    end,
    desc = 'Close the vault synchronization timer',
  })
end

return M
