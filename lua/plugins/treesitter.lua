-- Treesitter handles syntax highlighting

-- Recognize the wgsl file type
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.wgsl",
  callback = function()
    vim.bo.filetype = "wgsl"
  end,
})

return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    -- Ensure these languages are installed so I don't have to rely on autodetection
    ensure_installed = {
      "bash", -- because sometimes you need to bash your head against the wall
      "c", -- because you can't spell classic without c
      "css", -- because colors make everything better
      "eslint", -- because javascript needs some discipline
      "javascript", -- because who doesn't love a good semicolon joke
      "json", -- because it's just so on point
      "lua", -- because it's the moon of programming languages
      "python", -- because indentation is not a suggestion
      "rust", -- because memory safety is no laughing matter
      "svelte", -- because it's the new kid on the block
      "taplo", -- because taplo is the new kid on the block
      "toml", -- because it's not yaml
      "tsx", -- because typescript + jsx = tsx
      "typescript", -- because javascript needs some discipline
      "wgsl", -- because webgpu shading language sounds cool
      "yaml", -- because it's not toml
    },
  },
}
