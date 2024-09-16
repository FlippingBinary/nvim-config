return {
  {
    "gsuuon/model.nvim",
    cmd = { "M", "Model", "Mchat" },
    init = function()
      vim.filetype.add({
        extension = {
          mchat = "mchat",
        },
      })
    end,
    ft = "mchat",
    config = function()
      local ollama = require("model.providers.ollama")
      local mode = require("model").mode
      require("model").setup({
        chats = {
          ["review"] = {
            provider = ollama,
            options = {
              url = "https://ai.goobygob.com:11435",
            },
            system = "You are an expert programmer that gives constructive feedback. Review the changes in the user's git diff.",
            params = {
              model = "mistral-nemo",
            },
            create = function()
              local git_diff = vim.fn.system({ "git", "diff", "--staged" })
              ---@cast git_diff string

              if not git_diff:match("^diff") then
                error("Git error:\n" .. git_diff)
              end

              return git_diff
            end,
            run = function(messages, config)
              if config.system then
                table.insert(messages, 1, {
                  role = "system",
                  content = config.system,
                })
              end

              return { messages = messages }
            end,
          },
        },
        prompts = {
          ["ollama:starling"] = {
            provider = ollama,
            options = {
              url = "https://ai.goobygob.com:11435",
            },
            params = {
              model = "starling-lm",
            },
            builder = function(input)
              return {
                prompt = "GPT4 Correct User: " .. input .. "<|end_of_turn|>GPT4 Correct Assistant: ",
              }
            end,
          },
        },
      })
      require('model.util.curl')._is_debugging = true
    end,
    keys = {
      { "<C-m>d", ":Mdelete<cr>", mode = "n" },
      { "<C-m>s", ":Mselect<cr>", mode = "n" },
      { "<C-m><space>", ":Mchat<cr>", mode = "n" },
    },
  },
  {
    "David-Kunz/gen.nvim",
    opts = {
      model = "mistral-nemo", -- The default model to use.
      quit_map = "q", -- set keymap for close the response window
      retry_map = "<C-r>", -- set keymap to re-send the current prompt
      accept_map = "<C-CR>", -- set keymap to replace the previous selection with the last result
      host = "ai.goobygob.com", -- The host running the Ollama service.
      port = "11434", -- The port on which the Ollama service is listening.
      display_mode = "float", -- The display mode. Can be "float" or "split" or "horizontal-split".
      show_prompt = false, -- Shows the prompt submitted to Ollama.
      show_model = false, -- Displays which model you are using at the beginning of your chat session.
      no_auto_close = false, -- Never closes the window automatically.
      hidden = false, -- Hide the generation window (if true, will implicitly set `prompt.replace = true`), requires Neovim >= 0.10
      init = function(options) end,
      -- Function to initialize Ollama
      command = function(options)
        local body = { model = options.model, stream = true }
        return "curl --silent --no-buffer -X POST https://"
          .. options.host
          .. ":"
          .. options.port
          .. "/api/chat -d $body"
      end,
      list_models = function(options)
        local response =
          vim.fn.systemlist("curl --silent --no-buffer https://" .. options.host .. ":" .. options.port .. "/api/tags")
        local list = vim.fn.json_decode(response)
        local models = {}
        for key, _ in pairs(list.models) do
          table.insert(models, list.models[key].name)
        end
        table.sort(models)
        return models
      end,
      -- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
      -- This can also be a command string.
      -- The executed command must return a JSON object with { response, context }
      -- (context property is optional).
      -- list_models = '<omitted lua function>', -- Retrieves a list of model names
      debug = false, -- Prints errors and the command which is run.
    },
    keys = {
      { "<leader>]", "<cmd>Gen<cr>", mode = { "n", "v" }, desc = "Generative AI" },
    },
  },
}
