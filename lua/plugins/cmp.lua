-- This plugin override file prevents the first completion from being automatically selected
-- and also prevents the enter key from accepting the first completion unless it was selected manually.
local cmp = require("cmp")

return {
  "hrsh7th/nvim-cmp",
  opts = {
    completion = {
      completeopt = "menu,menuone,noselect",
    },
    mapping = {
      ["<CR>"] = cmp.mapping({
        i = function(fallback)
          if cmp.visible() and cmp.get_active_entry() then
            cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
          else
            fallback()
          end
        end,
        s = cmp.mapping.confirm({ select = true }),
        c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
      }),
    },
  },
}
