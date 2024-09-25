-- Synchronize this directory with the latest changes from the remote repository
local configpath = vim.fn.stdpath("config")
if type(configpath) == "table" then
  configpath = configpath[1]
end
-- Windows handles environment variables differently than Linux, so this function attempts to
-- handle those differences.
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

-- It is not critical to update the config every time, so this will timeout after 5 seconds.
-- This protects against an unreasonable delay when using NeoVim while offline.
-- However, it requires environment variables to configure git this way temporarily.
local config_pull_result = run_cmd_anywhere("git -C " .. configpath .. " pull", {
  GIT_HTTP_LOW_SPEED_LIMIT = "1000",
  GIT_HTTP_LOW_SPEED_TIME = "5",
})

if os.getenv("SAFEMODE") then
  -- load safemode instead of LazyVim
  require("safemode")
else
  -- bootstrap lazy.nvim, LazyVim and your plugins
  require("config.lazy")

  -- Notify the user if the config update failed. This must be done after loading
  -- LazyVim to ensure the notification displays normally.
  if config_pull_result ~= "Already up to date.\n" then
    if config_pull_result:find("Fast%-forward") then
      LazyVim.info("Successfully updated configuration. It's best to restart LazyVim.")
    elseif config_pull_result:find("Operation too slow") then
      LazyVim.warn(
        "User config was not synchronized because the network is too slow right now:\n" .. config_pull_result,
        { title = "LazyVim Config Update" }
      )
    elseif config_pull_result:find("fatal") then
      LazyVim.error(
        "The local repository needs to be repaired before remote changes can be pulled:\n" .. config_pull_result,
        { title = "LazyVim Config Update" }
      )
    else
      LazyVim.info(
        "Attempted to pull new changes to the user configuration:\n" .. config_pull_result,
        { title = "LazyVim Config Update" }
      )
    end
  end
end
