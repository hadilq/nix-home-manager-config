-- Grammars come from nvim-treesitter.withPlugins; do not install at runtime.
-- This is the current nvim-treesitter (main) API; nvim-treesitter.configs is gone.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("hadi_treesitter", { clear = true }),
  callback = function()
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
