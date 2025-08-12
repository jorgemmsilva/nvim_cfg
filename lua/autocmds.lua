require "nvchad.autocmds"

-- local aucmd = vim.api.nvim_create_autocmd
local autocmd = vim.api.nvim_create_autocmd

--------------
--- turn relative line numbers on / off for normal / insert mode
autocmd({ "InsertEnter" }, {
  pattern = "*",
  callback = function()
    vim.opt.relativenumber = false
  end,
})

autocmd({ "InsertLeave" }, {
  pattern = "*",
  callback = function()
    vim.opt.relativenumber = true
  end,
})

----------------
-- rename with F2
autocmd("LspAttach", {
  callback = function(args)
    vim.keymap.set("n", "<F2>", require "nvchad.lsp.renamer", {
      buffer = args.buf,
      desc = "LSP Rename",
      noremap = true,
    })
  end,
})

----------------
-- Toggle quickfix list
local function toggle_quickfix()
  local qf_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win["quickfix"] == 1 then
      qf_exists = true
    end
  end
  if qf_exists == true then
    vim.cmd "cclose"
  else
    vim.cmd "botright copen"
  end
end

vim.keymap.set("n", "<leader>q", toggle_quickfix, { desc = "Toggle quickfix" })

---------------
---auto-refresh files when they change underneath

-- Create a variable to track the state
vim.g.auto_refresh_enabled = false

-- Function to toggle the behavior
function ToggleAutoRefresh()
  if vim.g.auto_refresh_enabled then
    vim.api.nvim_clear_autocmds { group = "AutoRefresh" }
    vim.g.auto_refresh_enabled = false
    print "Auto refresh disabled"
  else
    vim.o.autoread = true
    vim.api.nvim_create_augroup("AutoRefresh", { clear = true })
    -- vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
    vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
      group = "AutoRefresh",
      command = "if mode() != 'c' | checktime | endif",
      pattern = "*",
    })
    vim.g.auto_refresh_enabled = true
    print "Auto refresh enabled"
  end
end

ToggleAutoRefresh() -- start with autorefresh enabled

vim.keymap.set("n", "<leader>rr", ToggleAutoRefresh, {
  noremap = true,
  silent = false,
  desc = "Toggle auto refresh of files",
})

--------------
