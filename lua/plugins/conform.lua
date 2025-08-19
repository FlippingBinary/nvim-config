return {
  {
    "conform.nvim",
    ---@param opts ConformOpts
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.tex = { "tex-fmt" }
      opts.formatters_by_ft.rust = { "rustfmt" }
    end,
  },
}
