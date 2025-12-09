return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      ignore_warnings = true,
      adapters = {
        http = {
          qwen3 = function()
            return require("codecompanion.adapters").extend("ollama", {
              name = "qwen3", -- Give this adapter a different name to differentiate it from the default ollama adapter
              env = {
                url = "https://ollama",
              },
              opts = {
                vision = true,
                stream = true,
              },
              schema = {
                model = {
                  default = "qwen3:latest",
                },
                num_ctx = {
                  default = 16384,
                },
                think = {
                  default = false,
                },
                keep_alive = {
                  default = "5m",
                },
              },
            })
          end,
          ollama = function()
            return require("codecompanion.adapters").extend("ollama", {
              env = {
                url = "https://ollama",
              },
              parameters = {
                sync = true,
              },
            })
          end,
        },
      },
      strategies = {
        chat = {
          adapter = "ollama",
        },
        inline = { adapter = "ollama" },
        agent = {
          adapter = "ollama",
        },
      },
    },
  },
  {
    "saghen/blink.cmp",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      sources = {
        default = { "codecompanion" },
        providers = {
          codecompanion = {
            name = "CodeCompanion",
            module = "codecompanion.providers.completion.blink",
            enabled = true,
          },
        },
        per_filetype = {
          codecompanion = { "codecompanion" },
        },
      },
    },
  },
}
