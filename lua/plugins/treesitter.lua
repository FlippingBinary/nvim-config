-- backwards compatibility with the old treesitter config for adding custom parsers
local function patch()
  local parsers = require("nvim-treesitter.parsers")
  parsers.get_parser_configs = setmetatable({}, {
    __call = function()
      return parsers
    end,
  })
end

if vim.tbl_contains(LazyVim.config.json.data.extras, "lazyvim.plugins.extras.ui.treesitter-rewrite") then
  if vim.fn.executable("tree-sitter") == 0 then
    LazyVim.error("**treesitter-rewrite** requires the `tree-sitter` executable to be installed")
    return {}
  end

  if vim.fn.has("nvim-0.10") == 0 then
    LazyVim.error("**treesitter-rewrite** requires Neovim >= 0.10")
    return {}
  end
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    cmd = {},
    opts = function()
      patch()
      return {
        highlight = { enable = true },
        indent = { enable = true },
        ensure_install = {
          -- "bash", -- because sometimes you need to bash your head against the wall
          "c", -- because you can't spell classic without c
          "css", -- because colors make everything better
          "diff", -- because it's different
          "html", -- because it's hyper
          "javascript", -- because who doesn't love a good semicolon joke
          "jsdoc", -- because semicolons need documentation too
          "json", -- because it's just so on point
          "jsonc", -- because it's weird
          "lua", -- because it's the moon of programming languages
          "luadoc", -- because the moon needs documentation
          "luap", -- because who knows what might happen without it
          "markdown", -- because we're down with the marks
          "markdown_inline", -- because we're reading between the lines
          "printf", -- because I assume this is needed
          "python", -- because indentation is not a suggestion
          "query", -- because it's a curious thing
          "regex", -- because regular is expressive
          "rust", -- because memory safety is no laughing matter
          "svelte", -- because it's the new kid on the block
          "toml", -- because it's not yaml
          "tsx", -- because typescript + jsx = tsx
          "typescript", -- because javascript needs some discipline
          "vim", -- because vim script needs colors too
          "vimdoc", -- because docs are good but highlighting is better
          "wgsl", -- because webgpu shading language sounds cool
          "xml", -- because markup is extensible
          "yaml", -- because it's not toml
        },
      }
    end,
    init = function()
      require("vim.treesitter.query").add_predicate("is-mise?", function(_, _, bufnr, _)
        local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
        local filename = vim.fn.fnamemodify(filepath, ":t")
        return string.match(filename, ".*mise.*%.toml$") ~= nil
      end, { force = true, all = false })
    end,
    ---@param opts TSConfig
    config = function(_, opts)
      ---@return string[]
      local function norm(ensure)
        return ensure == nil and {} or type(ensure) == "string" and { ensure } or ensure
      end

      -- ensure_installed is deprecated, but still supported
      opts.ensure_install = LazyVim.dedup(vim.list_extend(norm(opts.ensure_install), norm(opts.ensure_installed)))

      require("nvim-treesitter").setup(opts)
      patch()

      -- backwards compatibility with the old treesitter config for indent
      if vim.tbl_get(opts, "indent", "enable") then
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      -- backwards compatibility with the old treesitter config for highlight
      if vim.tbl_get(opts, "highlight", "enable") then
        vim.api.nvim_create_autocmd("FileType", {
          callback = function()
            pcall(vim.treesitter.start)
          end,
        })
      end

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
