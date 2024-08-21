
local function on_attach(client, bufnr)
  local opts = {buffer = bufnr, remap = false}

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)

  require("clangd_extensions.inlay_hints").setup_autocmd()
  require("clangd_extensions.inlay_hints").set_inlay_hints()
end

require("clangd_extensions").setup({
  inlay_hints = {
    max_len_align_padding = 2,
    priority = 100,
  },
  ast = {
    highlights = {
      detail = "Comment",
    },
  },
  memory_usage = {
    border = "none",
  },
  symbol_info = {
    border = "none",
  },
})

local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

lspconfig.clangd.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
})

