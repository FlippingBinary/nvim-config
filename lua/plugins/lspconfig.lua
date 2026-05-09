return {
  {
    "folke/lazydev.nvim",
    ---@module "lazydev"
    ---@type lazydev.Config
    opts = {
      library = {
        { path = "${3rd}/luassert/library", words = { "luassert" } },
        { path = "${3rd}/busted/library", words = { "describe", "before_each", "after_each" } },
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "LazyVim", words = { "LazyVim" } },
        { path = "snacks.nvim", words = { "Snacks" } },
        { path = "lazy.nvim", words = { "LazyVim" } },
        { path = "nvim-lspconfig", words = { "lspconfig.settings" } },
      },
    },
  },
}
