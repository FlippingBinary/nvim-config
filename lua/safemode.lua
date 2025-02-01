--- @class PluginProps
--- @field url string The Git URL of the plugin
--- @field branch string|nil The branch or tag to clone
--- @field load function The code that loads and configures the plugin.

--- @param plugins table<string, PluginProps>
local function install_plugins(plugins)
  for name, props in pairs(plugins) do
    local install_path = vim.fn.fnamemodify("nvim_safemode_plugins/" .. name, ":p")
    if vim.fn.isdirectory(install_path) == 0 then
      vim.notify("cloning " .. props.url .. " into " .. install_path)
      if props.branch == nil then
        vim.fn.system({ "git", "clone", "--depth=1", props.url, install_path })
      else
        vim.fn.system({ "git", "clone", "--depth=1", "--branch", props.branch, props.url, install_path })
      end
    end
    vim.opt.runtimepath:append(install_path)
    props.load()
  end
end

-- List the desired plugins in the table below.
-- The optional `branch` key can be used to specify a branch or tag to clone.
-- Use the `onload` key to define a function that calls the setup function
-- after the plugin is downloaded.
install_plugins({
  model = {
    url = "https://github.com/gsuuon/model.nvim",
    load = function()
      local ollama = require("model.providers.ollama")
      require("model").setup({
        chats = {
          ["review"] = {
            provider = ollama,
            options = {
              url = "http://localhost:11434",
            },
            system = "You are an expert programmer that gives constructive feedback. Review the changes in the user's git diff.",
            params = {
              model = "starling-lm",
            },
            create = function(input, context)
              local git_diff = vim.fn.system({ 'git', 'diff', '--staged' })
              -- if not git_diff:match("^diff") then
              --   error("Git error:\n" .. git_diff)
              --   return context.selection and input or ""
              -- else
              --   return git_diff .. "\n" .. input
              -- end
              return git_diff .. "\n" .. input
              -- return context.selection and input or ""
            end,
            run = function(messages, config)
              if #messages < 1 then
                error("Need at least one message")
              end

              local first_msg = messages[1]
              local prompt = "GPT4 Correct User: "
                .. (config.system and config.system .. "\n" or "")
                .. first_msg.content
                .. "<|end_of_turn|>"

              for i, msg in ipairs(messages) do
                if i > 1 then
                  prompt = prompt
                    .. (msg.role == "user" and "GPT4 Correct User:" or "GPT4 Correct Assistant:")
                    .. msg.content
                    .. "<|end_of_turn|>"
                end
              end

              prompt = prompt .. "GPT4 Correct Assistant: "

              return {
                prompt = prompt,
                raw = true,
              }
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
    end,
  },
})
