require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

vim.opt.relativenumber = true

-- don't do backups, but let me keep undo's for days
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv "HOME" .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.scrolloff = 8 -- keep 8 lines, don't let the cursor hit the bottom of the page

vim.opt.wrap = false -- don't wrap lines

vim.o.laststatus = 2 -- statusline show in every split
