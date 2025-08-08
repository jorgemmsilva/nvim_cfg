require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
local bufnr = vim.api.nvim_get_current_buf()

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
vim.opt.clipboard = "" -- disables use of system clipboard
map("n", "<leader>y", '"+y', { desc = "copy to system clipboard" })
map("v", "<leader>y", '"+y', { desc = "copy to system clipboard" })

-- navigate "quick-fix list"
map("n", "<leader>j", "<cmd>cnext<CR>zz", { desc = "Quick-fix list next" })
map("n", "<leader>k", "<cmd>cprev<CR>zz", { desc = "Quick-fix list prev" })
map("n", "<F4>", "<cmd>cnext<CR>zz", { desc = "Quick-fix list next" })
map("n", "<S-F4>", "<cmd>cprev<CR>zz", { desc = "Quick-fix list next" })
map("n", "<F16>", "<cmd>cprev<CR>zz", { desc = "Quick-fix list prev" }) -- workaround for S-F4 not working in rio terminal

-- ADD J/K for 2+lines to jumplist
map("n", "j", [[v:count ? (v:count >= 3 ? "m'" . v:count : '') . 'j' : 'gj']], { noremap = true, expr = true })
map("n", "k", [[v:count ? (v:count >= 3 ? "m'" . v:count : '') . 'k' : 'gk']], { noremap = true, expr = true })

-- replace occurances of the current word
-- map(
--   "n",
--   "<leader>s",
--   [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
--   { desc = "replace all occurances current word" }
-- )

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

-- use ESC to close floats
map("n", "<esc>", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == "win" then
      vim.api.nvim_win_close(win, false)
    end
    vim.cmd.nohlsearch() -- also clear search highlight
  end
end)

-- Tests
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

map("n", "<leader>td", function()
  require("neotest").run.run { strategy = "dap" }
end, { desc = "Debug nearest test" })

--- code actions
vim.keymap.set({ "n", "v" }, "<C-.>", function()
  if vim.bo.filetype == "rust" then
    vim.cmd.RustLsp "codeAction"
    return
  end

  local has_clients = next(vim.lsp.get_clients { bufnr = 0 }) ~= nil
  if not has_clients then
    vim.notify("No LSP client attached", vim.log.levels.WARN)
    return
  end

  vim.lsp.buf.code_action()
end, { silent = true, desc = "Show code actions" })

-- hover with ?
vim.keymap.set("n", "?", function()
  -- TODO this should fall back to regular LSP hover when not in a rust file
  vim.cmd.RustLsp { "hover", "actions" }
end, { silent = true, buffer = bufnr })

-- TODO:
-- RustLsp renderDiagnostics
-- vim.cmd.RustLsp('renderDiagnostic')
-- RustLsp explainError
-- vim.cmd.RustLsp('explainError')

map("n", "<leader>u", "<cmd>UndotreeToggle<CR>")
