-- trouble.nvim 3.x: :Trouble, not the old :TroubleToggle.
require("trouble").setup()
vim.keymap.set("n", "<leader>xq", "<cmd>Trouble quickfix toggle<cr>", {
  silent = true,
  desc = "Trouble quickfix",
})
