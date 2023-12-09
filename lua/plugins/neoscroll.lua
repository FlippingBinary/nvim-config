-- Smooth scrolling instead of jump scrolling
return {
  {
    "karb94/neoscroll.nvim",
    event = "WinScrolled",
    lazy = false,
    opts = {
      -- All these keys will be mapped to their corresponding default scrolling animation
      -- They already have descriptions, so they don't need to be listed in the keys table
      -- TODO: Figure out how to override the descriptions of the default mappings
      mappings = { "<C-b>", "<C-f>", "zt", "zz", "zb" },
      easing_function = "quintic",
      hide_cursor = true, -- Hide cursor while scrolling
      stop_eof = true, -- Stop at <EOF> when scrolling downwards
      use_local_scrolloff = false, -- Use the local scope of scrolloff instead of the global scope
      respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
      cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
      -- easing_function = nil, -- Default easing function
      pre_hook = nil, -- Function to run before the scrolling animation starts
      post_hook = nil, -- Function to run after the scrolling animation ends
    },
    keys = {
      {
        "<C-U>",
        "<cmd>lua require('neoscroll').scroll(-vim.wo.scroll, true, 75)<cr>",
        mode = { "n", "t", "v" },
        desc = "NeoScroll up",
      },
      {
        "<C-D>",
        "<cmd>lua require('neoscroll').scroll(vim.wo.scroll, true, 75)<cr>",
        mode = { "n", "t", "v" },
        desc = "NeoScroll down",
      },
      {
        "<C-Y>",
        "<cmd>lua require('neoscroll').scroll(-0.10, true, 50)<cr>",
        mode = { "n", "t", "v" },
        desc = "NeoScroll up a little",
      },
      {
        "<C-E>",
        "<cmd>lua require('neoscroll').scroll(0.10, true, 50)<cr>",
        mode = { "n", "t", "v" },
        desc = "NeoScroll down a little",
      },
    },
  },
}
