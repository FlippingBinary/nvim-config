-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- Add any additional options here

-- Disable all animations (alternatively, scroll animations could be disabled)
vim.g.snacks_animate = false
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

-- Prioritize git repositories over LSP workspaces
vim.g.root_spec = { { ".git" }, "lsp", "cwd" }
