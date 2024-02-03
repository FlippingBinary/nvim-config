-- Synchronize this directory with the latest changes from the remote repository
local configpath = vim.fn.stdpath("config")
local config_pull_result = vim.fn.system({ "git", "-C", configpath, "pull" })
if config_pull_result ~= "Already up to date.\n" then
  print("Checking for config updates: '" .. config_pull_result .. "'")
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
