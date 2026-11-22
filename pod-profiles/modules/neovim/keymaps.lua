-- Personal maps. Leader is comma (see options.lua).

vim.keymap.set("i", "jj", "<Esc>", { desc = "Escape insert mode" })

vim.keymap.set("n", "yf", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
end, { desc = "Yank filepath to clipboard" })

vim.keymap.set("n", "yd", function()
  vim.fn.setreg("+", vim.fn.expand("%:p:h"))
end, { desc = "Yank file directory to clipboard" })
