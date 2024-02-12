-- Common settings for TokyoNight
local plugin = {
  "folke/tokyonight.nvim",
}

if vim.g.os_family == "linux" and vim.g.os_platform == "native" then
  -- Enable transparent background only on native Linux
  plugin.opts = {
    transparent = true,
    styles = {
      sidebars = "transparent",
      floats = "transparent",
    },
  }
end

return plugin
