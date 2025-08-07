require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

-- modes:
-- n -- Normal mode -- Regular mode when you’re navigating around
-- i -- Insert mode -- When you’re typing text
-- v -- Visual mode (charwise) -- When you visually select text (charwise)
-- x -- Visual mode (exclusive) -- Similar to v but behaves slightly differently internally
-- s -- Select mode -- Like visual, but behaves like insert
-- o -- Operator-pending mode -- While waiting for a movement after an operator (e.g., d, y)
-- ! -- Insert or command-line mode -- For mapping in insert or cmd-line mode
-- t -- Terminal mode -- In terminal buffers
-- c -- Command-line mode -- When typing commands after :

-- map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- keep cursor in the middle of the screen when scrolling
map("n", "<C-u>", "<C-u>zz")
-- prevent overscrolling at the bottom
vim.keymap.set("n", "<C-d>", function()
  local last_line = vim.fn.line "$"
  local bottom_visible = vim.fn.line "w$"
  if bottom_visible < last_line then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-d>zz", true, false, true), "n", true)
  end
end, { noremap = true, silent = true, desc = "Smart <C-d>" })

-- keeps the cursor in the middle of the screen when searching
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

--keep the contents of the _ register when pasting over a selection
map("x", "<leader-p>", "_dP")

-- map a decent keys to telescope stuff
map("n", "<C-p>", "<cmd>Telescope find_files<CR>", { noremap = true, silent = true, desc = "telescope find files" })
map("n", "<C-f>", "<cmd>Telescope live_grep<CR>", { noremap = true, silent = true, desc = "telescope live grep" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Recent Files" })

-- allow to move selected lines up/down
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

--use leader to copy to system clipboard
map("n", "<leader>y", '"+y', { desc = "copy to system clipboard" })
map("v", "<leader>y", '"+y', { desc = "copy to system clipboard" })
-- map("n", "<leader>Y", '"+Y', { desc = "copy to system clipboard" })

-- navigate "quick-fix list" (commenting as I have no clue wtf that is lol)
-- map("n", "<C-k>", "<cmd>cnext<CR>zz")
-- map("n", "<C-j>", "<cmd>cprev<CR>zz")
-- map("n", "<leader>k", "<cmd>cnext<CR>zz")
-- map("n", "<leader>j", "<cmd>cprev<CR>zz")

-- replace occurances of the current word
map(
  "n",
  "<leader>s",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "replace all occurances current word" }
)

-- Navigate buffers with Ctrl + PageDown/PageUp
map("n", "<C-PageDown>", ":bnext<CR>", { noremap = true, silent = true, desc = "Next buffer" })
map("n", "<C-PageUp>", ":bprevious<CR>", { noremap = true, silent = true, desc = "Previous buffer" })

-- map nerdtree to a more familiar shortcut
map("n", "<C-b>", ":NvimTreeToggle<CR>", { noremap = true, silent = true, desc = "Toggle NERDTree" })

-- toggle line wrap
map("n", "<leader>z", function()
  vim.opt.wrap = not vim.opt.wrap:get()
end, { desc = "Toggle line wrap" })

--- navigation with arrow keys
map("i", "<C-h>", "<ESC>^i", { desc = "move beginning of line" })
map("i", "<C-l>", "<End>", { desc = "move end of line" })

-- toggle terminal
map({ "n", "t" }, "<C-`>", function()
  require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
end, { desc = "terminal toggle horizonal term" })

-- map <Esc> to exit terminal mode
map("t", "<Esc>", [[<C-\><C-n>]], { noremap = true })

-- rust Test mappings
map("n", "<leader>tt", function()
  require("neotest").run.run()
end, { desc = "Run nearest test" })
map("n", "<leader>tf", function()
  require("neotest").run.run(vim.fn.expand "%")
end, { desc = "Run file tests" })
map("n", "<leader>ts", function()
  require("neotest").summary.toggle()
end, { desc = "Test summary" })
map("n", "<leader>to", function()
  require("neotest").output.open { enter = true }
end, { desc = "Test output" })
