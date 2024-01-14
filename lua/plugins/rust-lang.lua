-- This function makes it easy to switch the build target during runtime
local function set_rust_target(target)
  print("Setting target to " .. target)
  vim.g.rust_analyzer_cargo_target = target
  vim.cmd.RustAnalyzer("stop")
  local bufnr = vim.api.nvim_get_current_buf()
  local timer = vim.loop.new_timer()
  if not timer then
    vim.loop.sleep(5000)
    vim.cmd.RustAnalyzer("start")
  else
    local time_to_live = 50
    timer:start(
      200,
      100,
      vim.schedule_wrap(function()
        local clients = vim.lsp.get_active_clients({ bufnr = bufnr, name = "rust-analyzer" })
        if #clients == 0 or time_to_live <= 0 then
          -- rust-analyzer has stopped running or we've waited too long
          vim.cmd.RustAnalyzer("start")
          timer:close()
          time_to_live = 0
        end
        time_to_live = time_to_live - 1
      end)
    )
  end
end

local function print_rust_target()
  local target = vim.g.rust_analyzer_cargo_target

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

    -- Print the results
    if target ~= nil then
      print("Default: " .. target)
    else
      print("Unable to find the rust target in `rustc -vV` output")
    end
  else
    print("Unable to run `rustc -vV` to get rust target")
  end
end

return {

  -- Extend auto completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      {
        "Saecki/crates.nvim",
        event = { "BufRead Cargo.toml" },
        opts = {
          src = {
            cmp = { enabled = true },
          },
        },
      },
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.sources = cmp.config.sources(vim.list_extend(opts.sources, {
        { name = "crates" },
      }))
    end,
  },

  -- Add Rust & related to treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "ron", "rust", "toml" })
      end
    end,
  },

  -- Ensure Rust debugger is installed
  {
    "williamboman/mason.nvim",
    optional = false,
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "codelldb" })
      end
    end,
  },

  {
    "mrcjkb/rustaceanvim",
    version = "^3", -- Recommended
    ft = { "rust" },
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
    opts = {
      server = {
        on_attach = function(client, bufnr)
          -- register which-key mappings
          local wk = require("which-key")
          wk.register({
            ["<leader>cR"] = {
              function()
                vim.cmd.RustLsp("codeAction")
              end,
              "Code Action",
            },
            ["<leader>dr"] = {
              function()
                vim.cmd.RustLsp("debuggables")
              end,
              "Rust debuggables",
            },
          }, { mode = "n", buffer = bufnr })
        end,
        settings = function(project_root)
          local default_settings = {
            -- rust-analyzer language server configuration
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
              },
              -- Add clippy lints for Rust.
              checkOnSave = {
                allFeatures = true,
                command = "clippy",
                extraArgs = { "--no-deps" },
              },
              procMacro = {
                enable = true,
                ignored = {
                  ["async-trait"] = { "async_trait" },
                  ["napi-derive"] = { "napi" },
                  ["async-recursion"] = { "async_recursion" },
                },
              },
            },
          }
          if vim.g.rust_analyzer_cargo_target ~= nil then
            default_settings["rust-analyzer"].cargo.target = vim.g.rust_analyzer_cargo_target
          end
          local local_settings = require("rustaceanvim.config.server").load_rust_analyzer_settings(project_root)

          return vim.tbl_deep_extend("force", default_settings, local_settings)
        end,
      },
    },
    config = function(_, opts)
      vim.g.rustaceanvim = vim.tbl_deep_extend("force", {}, opts or {})
    end,
  },

  -- Correctly setup lspconfig for Rust 🚀
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        rust_analyzer = {},
        taplo = {
          keys = {
            {
              "K",
              function()
                if vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
                  require("crates").show_popup()
                else
                  vim.lsp.buf.hover()
                end
              end,
              desc = "Show Crate Documentation",
            },
          },
        },
      },
      setup = {
        rust_analyzer = function()
          return true
        end,
      },
    },
  },

  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "rouge8/neotest-rust",
    },
    opts = {
      adapters = {
        ["neotest-rust"] = {},
      },
    },
  },
}
