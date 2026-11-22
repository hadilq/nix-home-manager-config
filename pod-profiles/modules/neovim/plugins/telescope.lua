local builtin = require("telescope.builtin")
pcall(require("telescope").load_extension, "fzy_native")

-- <leader>ff is fff; telescope keeps buffers, help, git files, and grep.
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help" })
vim.keymap.set("n", "<C-p>", builtin.git_files, { desc = "Telescope git files" })
vim.keymap.set("n", "<leader>ps", function()
  builtin.grep_string({ search = vim.fn.input("Grep > ") })
end, { desc = "Telescope grep string" })
