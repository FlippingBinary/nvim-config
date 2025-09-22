return {
  {
    "conform.nvim",
    ---@param opts ConformOpts
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      if vim.g.apps.nix then
        opts.formatters_by_ft.nix = { "nixfmt" }
      end
      if vim.g.apps.cargo then
        opts.formatters_by_ft.rust = { "rustfmt" }
      end
      if vim.g.apps.latexmk then
        opts.formatters_by_ft.tex = { "tex-fmt" }
      end
    end,
  },
}
