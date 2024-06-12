-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable :checkhealth warning about PERL
vim.g.loaded_perl_provider = 0
-- Disable :checkhealth warning about Ruby
vim.g.loaded_ruby_provider = 0

-- Disable LazyVim auto format
vim.g.autoformat = false

-- Identify the current OS, setting global variables that can be used by plugins and other configuration files.
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

-- Highlight the column containing the cursor
vim.wo.cursorcolumn = true
-- Highlight the 100th column to encourage keeping lines short
vim.wo.colorcolumn = "78,100"
-- Increase the keymap timeout so that `gcc` is a little easier to use
vim.o.timeoutlen = 500

-- Configure PowerShell if on Windows
if vim.g.os_family == "windows" then
  -- Check if 'pwsh' is executable and set the shell accordingly
  if vim.fn.executable("pwsh") == 1 then
    vim.o.shell = "pwsh"
  else
    vim.o.shell = "powershell"
  end

  -- Setting shell command flags
  vim.o.shellcmdflag =
    "-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';Remove-Alias -Force -ErrorAction SilentlyContinue tee;"

  -- Setting shell redirection
  vim.o.shellredir = '2>&1 | %{ "$_" } | Out-File %s; exit $LastExitCode'

  -- Setting shell pipe
  vim.o.shellpipe = '2>&1 | %{ "$_" } | Tee-Object %s; exit $LastExitCode'

  -- Setting shell quote options
  vim.o.shellquote = ""
  vim.o.shellxquote = ""
end
