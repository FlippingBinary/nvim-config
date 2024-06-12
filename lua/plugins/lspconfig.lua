return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Mason installs a version of rust-analyzer that may not match the version installed
        -- with the Rust toolchain, so this disables the mason version.
        -- rust_analyzer = {
        --   mason = false,
        -- },
        taplo = {
          keys = {
            {
              "K",
              function()
                if vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
                  require("crates").show_popup()
                else
                  vim.lsp.buf.hover()
                end
              end,
              desc = "Show Crate Documentation",
            },
          },
        },
      },
    },
  },
}
