require "nvchad.autocmds"

-- local aucmd = vim.api.nvim_create_autocmd
local autocmd = vim.api.nvim_create_autocmd




-------------- turn relative line numbers on / off for normal / insert mode
autocmd({"InsertEnter"}, {
  pattern = "*",
  callback = function()
    vim.opt.relativenumber = false
  end
})

autocmd({"InsertLeave"}, {
  pattern = "*",
  callback = function()
    vim.opt.relativenumber = true
  end
})
----------------
