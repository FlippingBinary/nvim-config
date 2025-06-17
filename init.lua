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

  if vim.fn.has("win32") == 1 then
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
  GIT_HTTP_LOW_SPEED_LIMIT = "1000",
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
      config_sync_info =
        "User config was not synchronized because of network congestion."
    elseif config_merge_result:find("Could not resolve host") then
      config_sync_info =
        "User config was not synchronized because we're offline right now."
    elseif config_merge_result:find("fatal") then
      config_sync_error =
        "The local repository needs to be repaired before remote changes can be pulled:\n" .. config_pull_result
    else
      config_sync_info =
        "Attempted to pull new changes to the user configuration:\n" .. config_pull_result
    end
  end
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

if config_sync_error ~= nil then
  LazyVim.error(config_sync_error, { title = "LazyVim Config Update"})
end
if config_sync_info ~= nil then
  LazyVim.info(config_sync_info, { title = "LazyVim Config Update"})
end
