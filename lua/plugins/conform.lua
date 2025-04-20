return {
  "stevearc/conform.nvim",
  opts = function()
    ---@type conform.setupOpts
    local opts = {
      formatters_by_ft = {
        tex = { "tex-fmt" },
      },
    }
    return opts
  end,
}
