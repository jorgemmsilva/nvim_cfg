-- require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "gopls", "solidity_ls_nomicfoundation", "lua_ls" }

-- read :h vim.lsp.config for changing options of lsp servers

dofile(vim.g.base46_cache .. "lsp")
require("nvchad.lsp").diagnostic_config()

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
        "~/.local/share/nvim/lazy",
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
vim.lsp.enable "lua_ls"

------------------------------------------------------------------
------------------------------------------------------------------
vim.lsp.enable(servers)
