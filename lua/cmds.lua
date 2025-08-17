-- use :Q to quit all
vim.cmd "command! Q qa"
vim.cmd [[command! -bang Q qa<bang>]]

-- open a vertical split and navigate back on the left window
vim.api.nvim_create_user_command("Vsp", function()
  vim.cmd "vsplit"
  vim.cmd "wincmd h" -- Move to left window
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-o>", true, false, true), "n", false)
end, {})

-- swap the current window with the next one (same as Ctrl+W x)
vim.cmd "command! Xsp wincmd x"
