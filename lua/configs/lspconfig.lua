local servers = {
  "html",
  "cssls",
  "gopls",
  "solidity_ls_nomicfoundation",
  "lua_ls",
}

--------------------------------------------------------------------------------
--                          Imported from nvchad lsp configs
--------------------------------------------------------------------------------

dofile(vim.g.base46_cache .. "lsp")

-- diagnostics config
local sev = vim.diagnostic.severity
vim.diagnostic.config {
  virtual_text = { prefix = "" },
  signs = { text = { [sev.ERROR] = "󰅙", [sev.WARN] = "", [sev.INFO] = "󰋼", [sev.HINT] = "󰌵" } },
  underline = true,
  float = { border = "single" },
}

------------------------------------------------------------------
--- LUA
------------------------------------------------------------------

local lua_lsp_settings = {
  Lua = {
    runtime = { version = "LuaJIT" },
    workspace = {
      library = {
        vim.fn.expand "$VIMRUNTIME/lua",
        vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types",
        vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
        "${3rd}/luv/library",
      },
    },
  },
}

local lua_capabilities = vim.lsp.protocol.make_client_capabilities()
lua_capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

vim.lsp.config("*", {
  capabilities = lua_capabilities,
  on_init = function(client, _)
    if client.supports_method "textDocument/semanticTokens" then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end,
})
vim.lsp.config("lua_ls", { settings = lua_lsp_settings })

------------------------------------------------------------------
------------------------------------------------------------------
vim.lsp.enable(servers)
