return {
  "saghen/blink.cmp",
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    sources = {
      default = { "lsp", "path", "snippets", "buffer", "codecompanion" },
      providers = {
        codecompanion = {
          name = "CodeCompanion",
          module = "codecompanion.providers.completion.blink",
          enabled = true,
        },
      },
    },
    keymap = {
      preset = "super-tab",
      ["<CR>"] = {
        "accept",
        "fallback",
      },
    },

    completion = {
      list = {
        selection = {
          auto_insert = true,
        },
      },
    },
  },
}
