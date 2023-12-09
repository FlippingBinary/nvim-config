-- This is included to add file type to the status line with an icon reprsenting the file type
return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, "filetype")
    end,
  },
}
