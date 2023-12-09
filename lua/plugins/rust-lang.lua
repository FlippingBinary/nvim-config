-- Rust software development additional configuration
local lspconfig = require("lspconfig")

-- This function makes it easy to switch the build target during runtime
local function set_rust_target(target)
  lspconfig.rust_analyzer.setup({
    settings = {
      ["rust-analyzer"] = {
        cargo = {
          target = target,
        },
      },
    },
  })
end

return {
  {
    "simrat39/rust-tools.nvim",
    keys = {
      {
        "<leader>rl",
        function()
          set_rust_target("x86_64-unknown-linux-gnu")
        end,
        desc = "Rust target Linux",
      },
      {
        "<leader>rm",
        function()
          set_rust_target("x86_64-pc-windows-msvc")
        end,
        desc = "Rust target Windows",
      },
      {
        "<leader>rw",
        function()
          set_rust_target("wasm32-unknown-unknown")
        end,
        desc = "Rust target WASM",
      },
    },
  },
}
