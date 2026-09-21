
-- Spell
vim.opt.spelllang = 'en_us'
vim.opt.spell = true

-- Setup trouble
vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>",
  {silent = true, noremap = true}
)

