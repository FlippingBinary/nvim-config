local OllamaState = {
  ANTICIPATING_REASONING = 1,
  REASONING = 2,
  ANTICIPATING_OUTPUTTING = 3,
  OUTPUTTING = 4,
}
---@type integer
local _ollama_state

return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      -- adapters = {
      --   ollama = function()
      --     local ollama = require("codecompanion.adapters.ollama")
      --
      --     return require("codecompanion.adapters").extend("ollama", {
      --       env = {
      --         url = "https://ai.goobygob.com:11435",
      --       },
      --       headers = {
      --         ["Content-Type"] = "application/json",
      --       },
      --       parameters = {
      --         sync = true,
      --       },
      --       schema = {
      --         model = {
      --           default = "gemma3:27b-it-qat",
      --         },
      --       },
      --       ---Check for a token before starting the request
      --       ---@param self CodeCompanion.Adapter
      --       ---@return boolean
      --       setup = function(self)
      --         _ollama_state = OllamaState.ANTICIPATING_OUTPUTTING
      --         return true
      --       end,
      --       handlers = {
      --         chat_output = function(self, data)
      --           local inner = ollama.handlers.chat_output(self, data)
      --
      --           if inner == nil then
      --             return inner
      --           end
      --
      --           if inner.status ~= "success" or inner.output == nil or type(inner.output.content) ~= "string" then
      --             return inner
      --           end
      --
      --           if string.find(inner.output.content, "<think>") ~= nil then
      --             _ollama_state = OllamaState.ANTICIPATING_REASONING
      --             inner.output.content = inner.output.content:gsub("%s*<think>%s*", "")
      --           elseif string.find(inner.output.content, "</think>") ~= nil then
      --             _ollama_state = OllamaState.ANTICIPATING_OUTPUTTING
      --             inner.output.content = inner.output.content:gsub("%s*</think>%s*", "")
      --           elseif inner.output.content:match("^%s*$") ~= nil then
      --             inner.output.content = ""
      --           elseif _ollama_state == OllamaState.ANTICIPATING_OUTPUTTING then
      --             _ollama_state = OllamaState.OUTPUTTING
      --           elseif _ollama_state == OllamaState.ANTICIPATING_REASONING then
      --             _ollama_state = OllamaState.REASONING
      --           end
      --
      --           if _ollama_state == OllamaState.ANTICIPATING_REASONING or _ollama_state == OllamaState.REASONING then
      --             inner.output.reasoning = inner.output.content
      --             inner.output.content = nil
      --           end
      --
      --           return inner
      --         end,
      --       },
      --     })
      --   end,
      -- },
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
          codecompanion = { "codecompanion"},
        }
      },
    },
  }
}
