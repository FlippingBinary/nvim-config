-- backwards compatibility with the old treesitter config for adding custom parsers
local function patch()
  local parsers = require("nvim-treesitter.parsers")
  parsers.get_parser_configs = setmetatable({}, {
    __call = function()
      return parsers
    end,
  })
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "css",
        "rust",
        "svelte",
        "wgsl",
      },
    },
    init = function()
      patch()

      require("vim.treesitter.query").add_predicate("is-mise?", function(_, _, bufnr, _)
        local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
        local filename = vim.fn.fnamemodify(filepath, ":t")
        return string.match(filename, ".*mise.*%.toml$") ~= nil
      end, { force = true, all = false })

      -- Recognize the wgsl file type
      vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
        pattern = "*.wgsl",
        callback = function()
          vim.bo.filetype = "wgsl"
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    enabled = false,
  },
  {
    "RRethy/vim-illuminate",
    optional = true,
    enabled = false,
  },
  {
    "rayliwell/tree-sitter-rstml",
    dependencies = { "nvim-treesitter" },
    build = ":TSUpdate",
  },
}
