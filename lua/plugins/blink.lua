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
      preset = "enter",
    },

    completion = {
      list = {
        selection = {
          preselect = false,
          auto_insert = false,
        },
      },
    },
  },
}
