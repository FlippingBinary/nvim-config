local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

local function get_vram_total()
  local handle = io.popen("nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits")
  if handle then
    local result = handle:read("*a")
    handle:close()
    return tonumber(result) or 0
  else
    return 0
  end
end

-- Set vim.g.env to one of the following values (probably):
-- - DARWIN
-- - LINUX
-- - WINDOWS
-- - CYGWIN
-- - MINGW
-- - WSL
if not vim.g.env then
    local uname = vim.loop.os_uname()
    if uname.sysname == 'Windows_NT' then
        vim.g.env = 'WINDOWS'
    else
        local system = vim.fn.system('uname')
        system = string.upper(string.gsub(system, '\n', ''))
        if system:match('LINUX') and (vim.fn.has("win32") or vim.fn.has("win64")) then
          vim.g.env = "WSL"
        else
          vim.g.env = system
        end
    end
end

local os_env = vim.g.env
local vram_total = get_vram_total()

-- Helper function to check if a command is available
local function has_command(cmd)
  local cmd_str
  if os_env:match("WINDOWS") then
    cmd_str = "cmd /c where " .. cmd
  else
    cmd_str = "which " .. cmd
  end
  local handle = io.popen(cmd_str)
  if not handle then
    return false
  end
  local exit_code = handle:close()
  return exit_code == 0
end

-- Check for required tools
local has_ansible = has_command("ansible")
local has_cargo = has_command("cargo")
local has_docker = has_command("docker")
local has_go = has_command("go")
local has_latexmk = has_command("latexmk")
local has_nix = has_command("nix")
local has_npm = has_command("npm")
local has_python = has_command("python3") or has_command("python")

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import any extras modules here
    { import = "lazyvim.plugins.extras.editor.mini-diff" },
    { import = "lazyvim.plugins.extras.dap.core" },
    { import = "lazyvim.plugins.extras.lang.ansible", enabled = has_ansible },
    { import = "lazyvim.plugins.extras.lang.clangd" },
    { import = "lazyvim.plugins.extras.lang.docker", enabled = has_docker },
    { import = "lazyvim.plugins.extras.lang.go", enabled = has_go },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    { import = "lazyvim.plugins.extras.lang.nix", enabled = has_nix },
    { import = "lazyvim.plugins.extras.lang.python", enabled = has_python },
    { import = "lazyvim.plugins.extras.lang.rust", enabled = has_cargo },
    { import = "lazyvim.plugins.extras.lang.svelte", enabled = has_npm },
    { import = "lazyvim.plugins.extras.lang.tailwind", enabled = has_npm },
    { import = "lazyvim.plugins.extras.lang.tex", enabled = has_latexmk },
    { import = "lazyvim.plugins.extras.lang.typescript", enabled = has_npm },
    { import = "lazyvim.plugins.extras.lang.yaml" },
    { import = "lazyvim.plugins.extras.linting.eslint", enabled = has_npm },
    { import = "lazyvim.plugins.extras.lsp.none-ls" },
    { import = "lazyvim.plugins.extras.ui.smear-cursor", enabled = vram_total > 8192 },
    { import = "lazyvim.plugins.extras.util.dot" },
    { import = "lazyvim.plugins.extras.util.project" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  ui = {
    -- Round the borders of the popup terminal and clearly separate it from the text
    border = "rounded",
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- automatically check for plugin updates
    frequency = 86400, -- check daily to reduce the frequency of checks
  },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
