return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    "folke/snacks.nvim",
  },
  event = "VeryLazy",
  config = function()
    ---@type opencode. Opts
    vim.g.opencode_opts = {
      provider = {
        enabled = "snacks",
        snacks = {
          auto_close = true,
          win = {
            position = "right",
            enter = false,
            bo = {
              filetype = "opencode_terminal",
            },
          },
        },
      },
    }

    vim.o.autoread = true

    -- Wrap the provider's start/toggle to inject LazyVim root as cwd
    local config = require("opencode.config")
    if config.provider then
      local original_start = config.provider.start
      local original_toggle = config.provider.toggle

      -- Get LazyVim root helper
      local function get_root()
        local ok, lazyvim = pcall(require, "lazyvim.util")
        if ok then
          return lazyvim.root.get() or vim.fn.getcwd()
        end
        return vim.fn.getcwd()
      end

      -- Override start to inject cwd
      config.provider.start = function(self)
        self.opts = self.opts or {}
        self.opts.cwd = get_root()
        return original_start(self)
      end

      -- Override toggle to inject cwd
      if original_toggle then
        config.provider.toggle = function(self)
          self.opts = self.opts or {}
          self.opts.cwd = get_root()
          return original_toggle(self)
        end
      end
    end

    -- Keymaps
    vim.keymap.set({ "n", "x" }, "<leader>aa", function()
      require("opencode").ask("@this: ", { submit = true })
    end, { desc = "Ask opencode" })

    vim.keymap.set({ "n", "x" }, "<leader>as", function()
      require("opencode").select()
    end, { desc = "Execute opencode action" })

    vim.keymap.set({ "n", "t" }, "<leader>at", function()
      require("opencode").toggle()
    end, { desc = "Toggle opencode" })

    vim.keymap.set({ "n", "x" }, "go", function()
      return require("opencode").operator("@this ")
    end, { expr = true, desc = "Add range to opencode" })

    vim.keymap.set("n", "goo", function()
      return require("opencode").operator("@this ") .. "_"
    end, { expr = true, desc = "Add line to opencode" })
  end,
}
