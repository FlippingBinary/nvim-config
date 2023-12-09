-- Surround text with quotes, brackets, etc.
return {
  {
    "tpope/vim-surround",
    -- make sure to change the value of `timeoutlen` if it's not triggering correctly, see https://github.com/tpope/vim-surround/issues/117
    -- setup = function()
    --  vim.o.timeoutlen = 500
    -- end
    keys = {
      { "ds", "<Plug>Dsurround", desc = "Delete by surround" },
      { "ys", "<Plug>Ysurround", desc = "Wrap by surround" },
    },
  },
}
