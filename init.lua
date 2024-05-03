-- Synchronize this directory with the latest changes from the remote repository
local configpath = vim.fn.stdpath("config")
local config_pull_result = vim.fn.system({ "git", "-C", configpath, "pull" })

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Notify the user if the config update failed. This must be done after loading
-- LazyVim to ensure the notification displays normally.
if config_pull_result ~= "Already up to date.\n" then
  vim.notify(
    "Failed to pull updates: '" .. config_pull_result .. "'",
    vim.log.levels.ERROR,
    { title = "LazyVim Config Update" }
  )
end
