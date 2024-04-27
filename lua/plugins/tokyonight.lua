-- Common settings for TokyoNight
local plugin = {
  "folke/tokyonight.nvim",
  opts = {
    on_highlights = function(highlights, colors)
      highlights.DiagnosticUnnecessary = {
        fg = colors.comment,
      }
    end,
  },
}

if vim.g.os_family == "linux" and vim.g.os_platform == "native" then
  return vim.tbl_deep_extend("error", plugin, {
    -- Enable transparent background only on native Linux
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  })
else
  return plugin
end
