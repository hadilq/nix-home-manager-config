vim.g.rustaceanvim = {
  inlay_hints = {
    highlight = "NonText",
  },
  tools = {
    hover_actions = {
      auto_focus = true,
    },
  },
  server = {
    on_attach = function(client, bufnr)
      require("lsp-inlayhints").on_attach(client, bufnr)

      local opts = {buffer = bufnr, remap = false, silent=true}
      vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
      vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
      vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
      vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
      vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
      vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)

      vim.keymap.set("n", "<leader>ca", function() vim.cmd.RustLsp('codeAction') end, opts)
      vim.keymap.set("n", "<leader>ws", function() vim.cmd.RustLsp('workspaceSymbol') end, opts)
      vim.keymap.set("n", "<leader>up", function() vim.cmd.RustLsp { 'moveItem',  'up' } end, opts)
      vim.keymap.set("n", "<leader>dn", function() vim.cmd.RustLsp { 'moveItem',  'down' } end, opts)
      vim.keymap.set("n", "<leader>ha", function() vim.cmd.RustLsp { 'hover', 'actions' } end, opts)
      vim.keymap.set("n", "<leader>hr", function() vim.cmd.RustLsp { 'hover', 'range' } end, opts)
      vim.keymap.set("n", "<leader>ee", function() vim.cmd.RustLsp('explainError') end, opts)
      vim.keymap.set("n", "<leader>rd", function() vim.cmd.RustLsp('renderDiagnostic') end, opts)
      vim.keymap.set("n", "<leader>oc", function() vim.cmd.RustLsp('openCargo') end, opts)
      vim.keymap.set("n", "<leader>od", function() vim.cmd.RustLsp('openDocs') end, opts)
      vim.keymap.set("n", "<leader>pm", function() vim.cmd.RustLsp('parentModule') end, opts)
      vim.keymap.set("n", "<leader>jl", function() vim.cmd.RustLsp('joinLines') end, opts)
    end,
    default_settings = {
      -- rust-analyzer language server configuration
      ['rust-analyzer'] = {
      },
    },
  }
}

require("lsp-inlayhints").setup()

