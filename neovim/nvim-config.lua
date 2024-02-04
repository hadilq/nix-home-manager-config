
-- Setup nvim-treesitter
require'nvim-treesitter.configs'.setup {
  sync_install = false,

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = true,
  },
}

-- Setup telescope.nvim
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
require("telescope").load_extension("fzy_native")

-- Setup trouble
vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>",
  {silent = true, noremap = true}
)


-- Setup refactoring
require('refactoring').setup({})

vim.api.nvim_set_keymap("v", "<leader>ri", [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]], {noremap = true, silent = true, expr = false})

-- Setup nvim-lint
require('lint').linters_by_ft = {
  markdown = { 'vale' },
  python = { "mypy", "ruff" },
  nix = { "statix" },
  bash = { "shellcheck" },
  rust = { "rustfmt" }
}
-- Srtup conform-nvim
require("conform").formatters.lua_format = {
  command = "lua-format",
  stdin = true
}

