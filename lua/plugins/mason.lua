return {
  {
    "mason-org/mason.nvim",
    optional = true,
    -- Override the default build command because the `:MasonUpdate` fails as
    -- unavailable during installation, but becomes available later.
    build = "",
    opts = function(_, opts)
      opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, {
        "codelldb",
        "verible",
      })
      if vim.g.apps.latexmk then
        vim.list_extend(opts.ensure_installed, {
          "tex-fmt",
        })
      end
      if vim.g.apps.python then
        vim.list_extend(opts.ensure_installed, {
          "tombi",
        })
      end
      opts.automatic_installation = {
        exclude = { "rust_analyzer" },
      }
      opts.ui = {
        -- Put a border around the Mason window, separating it from the text behind it.
        border = "rounded",
      }
      return opts
    end,
  },
}
