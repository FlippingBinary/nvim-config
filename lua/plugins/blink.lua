return {
  "saghen/blink.cmp",
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts_extend = {
    "sources.completion.enabled_providers",
    "sources.compat",
    "sources.default",
  },
  opts = {
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
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
