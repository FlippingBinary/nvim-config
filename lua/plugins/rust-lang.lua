local map = vim.keymap.set

-- This function makes it easy to switch the build target during runtime
local function set_rust_target(target)
  LazyVim.info("Setting target to *" .. target .. "*", { title = "Rust architecture" })
  vim.g.rust_analyzer_cargo_target = target
  vim.cmd.RustAnalyzer("restart")
end

local function get_rust_target()
  local target = vim.g.rust_analyzer_cargo_target

  -- Check if target was set during runtime
  if target ~= nil then
    return target
  end

  -- Otherwise, check the default target
  local handle = io.popen("rustc -vV")
  if handle ~= nil then
    local result = handle:read("*a")
    handle:close()
    for line in result:gmatch("[^\r\n]+") do
      if line:find("host:") then
        return line:match("^%s*(.-)%s*$"):gsub("host: ", "")
      end
    end
  else
    return nil
  end
end

local function print_rust_target()
  LazyVim.info("Current target *" .. get_rust_target() .. "*", { title = "Rust architecture" })
end

local rust_analyzer_default_settings = {
  -- rust-analyzer language server configuration
  ["rust-analyzer"] = {
    cargo = {
      allFeatures = true,
      loadOutDirsFromCheck = true,
      runBuildScripts = true, -- possibly can be removed?
      buildScripts = {
        enable = true,
      },
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

return {
  "mrcjkb/rustaceanvim",
  version = "^4", -- Recommended
  ft = { "rust" },
  opts = {
    setup = {
      rust_analyzer = function()
        return true
      end,
    },
    server = {
      cmd = function()
        local mason_registry = require("mason-registry")
        local ra_binary = mason_registry.is_installed("rust-analyzer")
            -- This may need to be tweaked, depending on the operating system.
            and mason_registry.get_package("rust-analyzer"):get_install_path() .. "/rust-analyzer"
          or "rust-analyzer"
        return { ra_binary } -- You can add args to the list, such as '--log-file'
      end,
      on_attach = function(_, bufnr)
        -- From LazyVim's standard configuration
        map("n", "<leader>cR", function()
          vim.cmd.RustLsp("codeAction")
        end, { desc = "Code Action", buffer = bufnr })
        map("n", "<leader>dr", function()
          vim.cmd.RustLsp("debuggables")
        end, { desc = "Rust Debuggables", buffer = bufnr })

        -- Clear the Rust target architecture override (reverts to default)
        map("n", "<leader>tc", function()
          set_rust_target(nil)
        end, { desc = "Clear target", buffer = bufnr })
        -- Set Linux as Rust target architecture
        map("n", "<leader>tl", function()
          set_rust_target("x86_64-unknown-linux-gnu")
        end, { desc = "Target Linux", buffer = bufnr })
        -- Set Windows as Rust target architecture
        map("n", "<leader>tm", function()
          set_rust_target("x86_64-pc-windows-msvc")
        end, { desc = "Target MS Windows", buffer = bufnr })
        -- Print the current Rust target architecture
        map("n", "<leader>tp", function()
          print_rust_target()
        end, { desc = "Print target", buffer = bufnr })
        -- Set WASM as Rust target architecture
        map("n", "<leader>tw", function()
          set_rust_target("wasm32-unknown-unknown")
        end, { desc = "Target WASM", buffer = bufnr })

        -- Add which-key groups
        local wk = require("which-key")
        wk.register({
          ["<leader>t"] = {
            name = "+target",
          },
          ["<leader>d"] = {
            name = "debug",
          },
        }, {
          buffer = bufnr,
        })
      end,
      ---@param project_root string
      settings = function(project_root)
        return vim.tbl_deep_extend(
          "keep",
          require("rustaceanvim.config.server").load_rust_analyzer_settings(project_root) or {},
          vim.tbl_deep_extend("force", rust_analyzer_default_settings, {
            ["rust-analyzer"] = {
              cargo = {
                target = get_rust_target(),
              },
            },
          })
        )
      end,
      default_settings = rust_analyzer_default_settings,
    },
  },
  config = function(_, opts)
    vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
    if vim.fn.executable("rust-analyzer") == 0 then
      LazyVim.error(
        "**rust-analyzer** not found in PATH, please install it.\nhttps://rust-analyzer.github.io/",
        { title = "rustaceanvim" }
      )
    end
  end,
}
