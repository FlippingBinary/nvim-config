return {
  {
    "mason-org/mason.nvim",
    optional = true,
    opts = {
      ensure_installed = { "codelldb", "tex-fmt", "verible" },
      automatic_installation = {
        exclude = { "rust_analyzer" },
      },
      ui = {
        -- Put a border around the Mason window, separating it from the text behind it.
        border = "rounded",
      },
    },
  },
}
