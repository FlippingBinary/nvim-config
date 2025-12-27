-- First, we identify the current OS, setting global variables that can be used by plugins and other configuration files.
-- This sets some global variables that can adjust the configuration for the environment without
-- having to run environment tests in every file.
--
-- Here are the meanings of the global variables:
-- `vim.g.os_family` - The OS family (windows, mac, or linux)
-- `vim.g.os_platform` - The platform (native, docker, or wsl)
-- `vim.g.session_type` - The session type (local, ssh, or unknown if the test fails or did not take place)
local uname = vim.loop.os_uname()
-- This match for Windows is based on this issue: https://github.com/neovim/neovim/issues/14953
if uname.version:match("Windows") then
  vim.g.os_family = "windows"
elseif uname.sysname == "Darwin" then
  vim.g.os_family = "mac"
elseif uname.sysname == "Linux" then
  vim.g.os_family = "linux"
else
  LazyVim.notify(
    "A new OS! Awesome! Please identify what os_family '"
      .. uname.sysname
      .. "' belongs to and update ~/.config/nvim/lua/config/options.lua!"
  )
end

if vim.g.os_family == "windows" then
  -- If the `C:\\.dockerenv` file exists, we should assume we're running under docker.
  local docker_env = io.open("C:\\.dockerenv")
  if docker_env then
    docker_env:close()
    vim.g.os_platform = "docker"
  else
    vim.g.os_platform = "native"
  end

  -- I haven't looked into ways to test this because I never ssh into my Windows machine,
  -- but I don't want to set this to "local" because I'm not actually testing it.
  vim.g.session_type = "unknown"
else
  -- If the `/.dockerenv` file exists, we should assume we're running under docker.
  local docker_env = io.open("/.dockerenv")
  if docker_env then
    docker_env:close()
    vim.g.os_platform = "docker"
  elseif os.getenv("WSL_DISTRO_NAME") then
    -- Now we know that we're running on Linux in WSL on Windows.
    vim.g.os_platform = "wsl"
  else
    vim.g.os_platform = "native"
  end

  if os.getenv("SSH_CLIENT") or os.getenv("SSH_TTY") then
    vim.g.session_type = "ssh"
  else
    vim.g.session_type = "local"
  end
end

-- Deferred warning messages for slow startup operations.
-- These are displayed after LazyVim is bootstrapped.
---@type string | nil
local startup_warning = nil

-- Utility functions for timing and timeout management during startup.
-- These help identify slow operations without cluttering normal startup output.

--- Measure execution time of a function and warn if it exceeds a threshold.
--- @param name string Description of the operation
--- @param threshold_ms number Time threshold in milliseconds
--- @param fn function The function to run
--- @return any result The return value of fn
local function timed(name, threshold_ms, fn)
  local start = vim.loop.hrtime()
  local result = fn()
  local elapsed_ms = (vim.loop.hrtime() - start) / 1e6
  if elapsed_ms > threshold_ms then
    local msg = string.format("[SLOW] %s took %.0fms (threshold: %dms)", name, elapsed_ms, threshold_ms)
    startup_warning = startup_warning and (startup_warning .. "\n" .. msg) or msg
  end
  return result
end

--- Run an external command with a hard timeout that kills the process if exceeded.
--- This is cross-platform (Windows and Linux) and uses vim.fn.jobstart() internally.
--- @param cmd table Command as a list, e.g., {"git", "fetch"}
--- @param opts table { timeout_ms: number, env?: table, cwd?: string }
--- @return string output The combined stdout/stderr output
--- @return boolean timed_out Whether the command was killed due to timeout
local function run_with_timeout(cmd, opts)
  opts = opts or {}
  local timeout_ms = opts.timeout_ms or 5000
  local output_lines = {}
  local done = false
  local timed_out = false

  local job_id = vim.fn.jobstart(cmd, {
    cwd = opts.cwd,
    env = opts.env,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(output_lines, line)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(output_lines, line)
          end
        end
      end
    end,
    on_exit = function()
      done = true
    end,
  })

  -- Handle job start failure
  if job_id <= 0 then
    return "", false
  end

  -- Set up a timer to kill the job if it exceeds the timeout
  local timer_id = vim.fn.timer_start(timeout_ms, function()
    if not done then
      timed_out = true
      vim.fn.jobstop(job_id)
      local msg = string.format("[TIMEOUT] %s killed after %dms", cmd[1], timeout_ms)
      startup_warning = startup_warning and (startup_warning .. "\n" .. msg) or msg
    end
  end)

  -- Wait for the job to complete (or be killed by the timer)
  -- Add a small buffer to the wait time to allow the timer to fire first if needed
  vim.wait(timeout_ms + 100, function()
    return done
  end, 10)

  -- Clean up the timer if the job finished before the timeout
  vim.fn.timer_stop(timer_id)

  return table.concat(output_lines, "\n"), timed_out
end

-- Check for common tools in the environment
timed("Checking tools", 200, function()
  vim.g.apps = {
    ansible = vim.fn.executable("ansible") == 1,
    cargo = vim.fn.executable("cargo") == 1,
    docker = vim.fn.executable("docker") == 1,
    git = vim.fn.executable("git") == 1,
    go = vim.fn.executable("go") == 1,
    latexmk = vim.fn.executable("latexmk") == 1,
    nix = vim.fn.executable("nix") == 1,
    npm = vim.fn.executable("npm") == 1,
    nvidia = vim.fn.executable("nvidia-smi") == 1,
    nvim = true,
    python = vim.fn.executable("python3") == 1 or vim.fn.executable("python") == 1,
    terraform = vim.fn.executable("terraform") == 1,
  }
end)

if vim.g.apps.nvidia and not vim.g.vram_total then
  local result, timed_out = run_with_timeout(
    { "nvidia-smi", "--query-gpu=memory.total", "--format=csv,noheader,nounits" },
    { timeout_ms = 1000 }
  )
  if timed_out then
    vim.g.vram_total = 0
  else
    vim.g.vram_total = tonumber(result) or 0
  end
else
  vim.g.vram_total = 0
end

-- This marks the end of the environment identification section.

-- Synchronize this directory with the latest changes from the remote repository
local configpath = vim.fn.stdpath("config")
if type(configpath) == "table" then
  configpath = configpath[1]
end

---@type string | nil
local config_sync_info = nil
---@type string | nil
local config_sync_error = nil

-- It is not critical to update the config every time, so this will timeout quickly.
-- The timeout protects against an unreasonable delay when using NeoVim while offline.
-- These environment variables encourage git to give up quickly on slow connections.
local low_speed_opts = {
  -- Speeds lower than this (in bps) are considered low
  GIT_HTTP_LOW_SPEED_LIMIT = "4000",
  -- Low speeds for longer than this many seconds will cause git to abort
  GIT_HTTP_LOW_SPEED_TIME = "1",
}

local config_fetch_result, fetch_timed_out = run_with_timeout(
  { "git", "-C", configpath, "fetch" },
  { timeout_ms = 2000, env = low_speed_opts }
)

if not fetch_timed_out and config_fetch_result ~= "" then
  local config_merge_result, merge_timed_out = run_with_timeout(
    { "git", "-C", configpath, "merge", "--ff-only" },
    { timeout_ms = 1000, env = low_speed_opts }
  )

  if not merge_timed_out then
    local config_pull_result = config_fetch_result .. "\n" .. config_merge_result

    -- Notify the user if the config update failed. This must be done after loading
    -- LazyVim to ensure the notification displays normally.
    if config_merge_result ~= "Already up to date." then
      if config_merge_result:find("Fast%-forward") then
        config_sync_info = "Successfully updated configuration. It's best to restart LazyVim."
      elseif config_merge_result:find("Operation too slow") then
        config_sync_info = "User config was not synchronized because of network congestion."
      elseif config_merge_result:find("Could not resolve host") then
        config_sync_info = "User config was not synchronized because we're offline right now."
      elseif config_merge_result:find("fatal") then
        config_sync_error = "The local repository needs to be repaired before remote changes can be pulled:\n"
          .. config_pull_result
      else
        config_sync_info = "Attempted to pull new changes to the user configuration:\n" .. config_pull_result
      end
    end
  end
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

if config_sync_error ~= nil then
  LazyVim.error(config_sync_error, { title = "LazyVim Config Update" })
end
if config_sync_info ~= nil then
  LazyVim.info(config_sync_info, { title = "LazyVim Config Update" })
end
if startup_warning ~= nil then
  LazyVim.warn(startup_warning, { title = "Startup Performance" })
end
