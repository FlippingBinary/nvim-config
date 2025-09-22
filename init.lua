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

-- Check for common tools in the environment
vim.g.apps = {
  ansible = vim.fn.executable("ansible") == 1,
  cargo = vim.fn.executable("cargo") == 1,
  docker = vim.fn.executable("docker") == 1,
  git = vim.fn.executable("git") == 1,
  go = vim.fn.executable("go") == 1,
  latexmk = vim.fn.executable("latexmk") == 1,
  nix = vim.fn.executable("nix") == 1,
  npm = vim.fn.executable("npm") == 1,
  nvim = true,
  python = vim.fn.executable("python3") == 1 or vim.fn.executable("python") == 1,
  terraform = vim.fn.executable("terraform") == 1,
}

if not vim.g.vram_total then
  local handle = io.popen("nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits")
  if handle then
    local result = handle:read("*a")
    handle:close()
    vim.g.vram_total = tonumber(result) or 0
  else
    vim.g.vram_total = 0
  end
end

-- This marks the end of the environment identification section.

-- Synchronize this directory with the latest changes from the remote repository
local configpath = vim.fn.stdpath("config")
if type(configpath) == "table" then
  configpath = configpath[1]
end

-- Run a command with environment variables set appropriately for the platform.
---@param command string
---@param env_vars table<string, string>
local function run_cmd_anywhere(command, env_vars)
  local env_str = ""
  for k, v in pairs(env_vars) do
    -- Escape any double quotes in the environment variable value
    v = v:gsub('"', '\\"')
    env_str = env_str .. k .. '="' .. v .. '" '
  end

  if vim.loop.os_uname().sysname == "Windows_NT" then
    -- For Windows, use 'set' command to set environment variables
    return vim.fn.system("set " .. env_str .. "&& " .. command)
  else
    -- For Linux and other Unix-like systems
    return vim.fn.system(env_str .. command)
  end
end

---@type string | nil
local config_sync_info = nil
---@type string | nil
local config_sync_error = nil

-- It is not critical to update the config every time, so this will timeout quickly.
-- The timeout protects against an unreasonable delay when using NeoVim while offline.
local low_speed_opts = {
  -- Speeds lower than this (in bps) are considered low
  GIT_HTTP_LOW_SPEED_LIMIT = "5000",
  -- Low speeds for longer than this many seconds will cause git to abort
  GIT_HTTP_LOW_SPEED_TIME = "2",
}
local config_fetch_result = run_cmd_anywhere("git -C " .. configpath .. " fetch", low_speed_opts)
if config_fetch_result ~= "" then
  local config_merge_result = run_cmd_anywhere("git -C " .. configpath .. " merge --ff-only", low_speed_opts)
  local config_pull_result = config_fetch_result .. "\n" .. config_merge_result

  -- Notify the user if the config update failed. This must be done after loading
  -- LazyVim to ensure the notification displays normally.
  if config_merge_result ~= "Already up to date.\n" then
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

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

if config_sync_error ~= nil then
  LazyVim.error(config_sync_error, { title = "LazyVim Config Update" })
end
if config_sync_info ~= nil then
  LazyVim.info(config_sync_info, { title = "LazyVim Config Update" })
end
