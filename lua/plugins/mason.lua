return {
  {
    "mason-org/mason.nvim",
    optional = true,
    -- Override the default build command because the `:MasonUpdate` fails as
    -- unavailable during installation, but becomes available later.
    build = "",
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
