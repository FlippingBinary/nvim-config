return {
  {
    "mason-org/mason.nvim",
    -- temporary workaround https://github.com/LazyVim/LazyVim/issues/6039
    version = "1.11.0",
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
  -- temporary workaround https://github.com/LazyVim/LazyVim/issues/6039
  { "mason-org/mason-lspconfig.nvim", version = "1.32.0" },
}
