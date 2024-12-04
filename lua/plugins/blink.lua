return {
  "saghen/blink.cmp",
  version = "*",
  opts_extend = { "sources.completion.enabled_providers" },
  dependencies = {
    "rafamadriz/friendly-snippets",
    -- add blink.compat to dependencies
    -- { "saghen/blink.compat", opts = {} },
  },
  event = "InsertEnter",

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    highlight = {
      -- sets the fallback highlight groups to nvim-cmp's highlight groups
      -- useful for when your theme doesn't support blink.cmp
      -- will be removed in a future release, assuming themes add support
      use_nvim_cmp_as_default = false,
    },
    -- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    -- adjusts spacing to ensure icons are aligned
    nerd_font_variant = "mono",
    windows = {
      autocomplete = {
        selection = "manual",
        -- draw = "reversed",
        winblend = vim.o.pumblend,
      },
      documentation = {
        auto_show = true,
      },
      ghost_text = {
        enabled = true,
      },
    },

    -- experimental auto-brackets support
    accept = { auto_brackets = { enabled = true } },

    -- experimental signature help support
    -- trigger = { signature_help = { enabled = true } }
    sources = {
      completion = {
        -- remember to enable your providers here
        enabled_providers = { "lsp", "path", "snippets", "buffer" },
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
        selection = "auto_insert",
      },
    },
  },
}
