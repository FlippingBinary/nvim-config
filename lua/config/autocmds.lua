-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Or if you want to be more aggressive:
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  callback = function()
    local root = require("lazyvim.util").root.get()
    if root and vim.fn.getcwd() ~= root then
      vim.cmd.cd(root)
    end
  end,
})
