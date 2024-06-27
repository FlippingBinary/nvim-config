-- Synchronize this directory with the latest changes from the remote repository
local configpath = vim.fn.stdpath("config")
if type(configpath) == "table" then
  configpath = configpath[1]
end
local config_pull_result = vim.fn.system({ "git", "-C", configpath, "pull" })

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Notify the user if the config update failed. This must be done after loading
-- LazyVim to ensure the notification displays normally.
if config_pull_result ~= "Already up to date.\n" then
  if config_pull_result:find("Fast-forward") then
    LazyVim.info("Successfully updated configuration. It's best to restart LazyVim.")
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
