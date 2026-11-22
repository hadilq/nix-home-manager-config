vim.keymap.set("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git status" })

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("Hadi_Fugitive", { clear = true }),
  callback = function()
    if vim.bo.ft ~= "fugitive" then
      return
    end
    local opts = { buffer = vim.api.nvim_get_current_buf(), remap = false }
    vim.keymap.set("n", "<leader>p", function()
      vim.cmd.Git("push")
    end, opts)
    vim.keymap.set("n", "<leader>P", function()
      vim.cmd.Git({ "pull", "--rebase" })
    end, opts)
    vim.keymap.set("n", "<leader>t", ":Git push -u origin ", opts)
  end,
})
