-- Rust software development additional configuration
local lspconfig = require("lspconfig")

-- Get current target with:
-- vim.inspect(require('lspconfig').rust_analyzer.manager.config.settings['rust-analyzer'].cargo.target)

-- This function makes it easy to switch the build target during runtime
local function set_rust_target(target)
  lspconfig.rust_analyzer.setup(vim.tbl_deep_extend("force", lspconfig.rust_analyzer.manager.config, {
    settings = {
      ["rust-analyzer"] = {
        cargo = {
          target = target,
        },
      },
    },
  }))
end

local function print_rust_target()
  local target = lspconfig.rust_analyzer.manager.config.settings["rust-analyzer"].cargo.target

  -- Check if target was set during runtime
  if target ~= nil then
    print(target)
    return
  end

  -- Otherwise, check the default target
  local handle = io.popen("rustc -vV")
  if handle ~= nil then
    local result = handle:read("*a")
    handle:close()
    for line in result:gmatch("[^\r\n]+") do
      if line:find("host:") then
        target = line:match("^%s*(.-)%s*$"):gsub("host: ", "")
      end
    end
  else
    print("Unable to run `rustc -vV` to get rust target")
  end

  -- Print the results
  if target ~= nil then
    print(target)
  else
    print("Unable to find the rust target in `rustc -vV` output")
  end
end

return {
  {
    "simrat39/rust-tools.nvim",
    keys = {
      {
        "<leader>rp",
        function()
          print_rust_target()
        end,
        desc = "Print current target",
      },
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
