return {
  "FlippingBinary/opencode.nvim",
  branch = "feat/project-root",
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

    -- Keymaps
    vim.keymap.set({ "n", "x" }, "<leader>aa", function()
      require("opencode").ask("@this: ", { cwd = LazyVim.root(), submit = true })
    end, { desc = "Ask opencode" })

    vim.keymap.set({ "n", "x" }, "<leader>as", function()
      require("opencode").select({ cwd = LazyVim.root() })
    end, { desc = "Execute opencode action" })

    vim.keymap.set({ "n" }, "<leader>at", function()
      require("opencode").toggle({ cwd = LazyVim.root() })
    end, { desc = "Toggle opencode" })

    vim.keymap.set({ "n", "x" }, "go", function()
      return require("opencode").operator("@this ", { cwd = LazyVim.root() })
    end, { expr = true, desc = "Add range to opencode" })

    vim.keymap.set("n", "goo", function()
      return require("opencode").operator("@this ", { cwd = LazyVim.root() }) .. "_"
    end, { expr = true, desc = "Add line to opencode" })
  end,
}
