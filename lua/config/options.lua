-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- First, we identify the current OS, setting global variables that can be used by plugins and other configuration files.
-- This sets some global variables that can adjust the configuration for the environment without
-- having to run environment tests in every file.
--
-- Here are the meanings of the global variables:
-- `vim.g.os_family` - The OS family (windows, mac, or linux)
-- `vim.g.os_platform` - The platform (native, docker, or wsl)
-- `vim.g.session_type` - The session type (local, ssh, or unknown if the test fails or did not take place)
local uname = vim.loop.os_uname()
if uname.sysname == "Windows_NT" then
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

  local handle = io.popen("pstree -s -p $$")
  local result = ""

  if handle then
    result = handle:read("*a")
    handle:close()

    if result:match("%Asshd%A") then
      vim.g.session_type = "ssh"
    else
      vim.g.session_type = "local"
    end
  else
    vim.g.session_type = "unknown"
  end
end

-- This marks the end of the environment identification section.

-- Add any additional options here

-- Disable :checkhealth warning about PERL
vim.g.loaded_perl_provider = 0
-- Disable :checkhealth warning about Ruby
vim.g.loaded_ruby_provider = 0

-- Disable LazyVim auto format
vim.g.autoformat = false

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
