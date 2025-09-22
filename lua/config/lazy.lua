local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import any extras modules here
    { import = "lazyvim.plugins.extras.editor.mini-diff" },
    { import = "lazyvim.plugins.extras.dap.core" },
    { import = "lazyvim.plugins.extras.lang.ansible", enabled = vim.g.apps.ansible },
    { import = "lazyvim.plugins.extras.lang.clangd" },
    { import = "lazyvim.plugins.extras.lang.docker", enabled = vim.g.apps.docker },
    { import = "lazyvim.plugins.extras.lang.go", enabled = vim.g.apps.go },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    { import = "lazyvim.plugins.extras.lang.nix", enabled = vim.g.apps.nix },
    { import = "lazyvim.plugins.extras.lang.python", enabled = vim.g.apps.python },
    { import = "lazyvim.plugins.extras.lang.rust", enabled = vim.g.apps.cargo },
    { import = "lazyvim.plugins.extras.lang.svelte", enabled = vim.g.apps.npm },
    { import = "lazyvim.plugins.extras.lang.tailwind", enabled = vim.g.apps.npm },
    { import = "lazyvim.plugins.extras.lang.tex", enabled = vim.g.apps.latexmk },
    { import = "lazyvim.plugins.extras.lang.toml" },
    { import = "lazyvim.plugins.extras.lang.typescript", enabled = vim.g.apps.npm },
    { import = "lazyvim.plugins.extras.lang.yaml" },
    { import = "lazyvim.plugins.extras.linting.eslint", enabled = vim.g.apps.npm },
    { import = "lazyvim.plugins.extras.lsp.none-ls" },
    { import = "lazyvim.plugins.extras.ui.smear-cursor", enabled = vim.g.vram_total > 8192 },
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
