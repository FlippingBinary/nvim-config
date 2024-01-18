-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable LazyVim auto format
vim.g.autoformat = false

-- Identify the current OS, setting global variables that can be used by plugins and other configuration files.
local function identify_os()
  local uname = vim.loop.os_uname()
  if uname.sysname == "Windows_NT" then
    vim.g.os_family = "windows"
  elseif uname.sysname == "Darwin" then
    vim.g.os_family = "mac"
  elseif uname.sysname == "Linux" then
    vim.g.os_family = "linux"
  else
    print(
      "A new OS! Awesome! Please identify what os_family '"
        .. uname.sysname
        .. "' belongs to and update ~/.config/nvim/lua/config/options.lua!"
    )
  end

  if os.getenv("WSL_DISTRO_NAME") then
    -- We're running on Windows under WSL, so it's probably Linux, but there may be special changes that have to be made with special circumstances
    vim.g.os_platform = "wsl"
  -- setup_zsh()
  else
    -- If the `/.dockerenv` file exists, we should assume we're running under docker.
    local docker_env = io.open("/.dockerenv")
    if docker_env then
      docker_env:close()
      vim.g.os_platform = "docker"
    else
      vim.g.os_platform = "native"
    end
  end
end
identify_os()

-- Highlight the column containing the cursor
vim.wo.cursorcolumn = true
-- Highlight the 100th column to encourage keeping lines short
vim.wo.colorcolumn = "78,100"

