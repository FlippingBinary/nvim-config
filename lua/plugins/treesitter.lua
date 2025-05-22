return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    lazy = false,
    opts_extend = { "ensure_installed" },
    ---@type TSConfig
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "bash", -- because sometimes you need to bash your head against the wall
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
    },
    ---@param opts TSConfig
    config = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        opts.ensure_installed = LazyVim.dedup(opts.ensure_installed)
      end
      require("nvim-treesitter.configs").setup(opts)
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
    "rayliwell/tree-sitter-rstml",
    dependencies = { "nvim-treesitter" },
    build = ":TSUpdate",
    config = function()
      require("tree-sitter-rstml").setup()
    end,
  },
}
