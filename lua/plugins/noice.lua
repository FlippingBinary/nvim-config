return {
  "folke/noice.nvim",
  opts = {
    lsp = {
      hover = {
        silent = true, -- Silence the "No information available" messages
      },
    },
    presets = {
      lsp_doc_border = true,
    },
  },
}
