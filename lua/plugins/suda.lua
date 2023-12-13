-- Make it possible to sudo save a file without losing changes
return {
  "lambdalisue/suda.vim",
  keys = {
    { "<A-s>", ":SudaWrite<cr>", mode = { "i", "n" }, desc = "Save file with sudo" },
  },
}
