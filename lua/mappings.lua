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

--------------------------------------------------------------------------------
--                          Imported from nvchad.mappings
--------------------------------------------------------------------------------

map("n", "<C-h>", "<C-w>h", { desc = "switch window left" })
map("n", "<C-l>", "<C-w>l", { desc = "switch window right" })
map("n", "<C-j>", "<C-w>j", { desc = "switch window down" })
map("n", "<C-k>", "<C-w>k", { desc = "switch window up" })

map({ "n", "i" }, "<C-s>", "<Esc>:w<CR>", { desc = "save file" })
map({ "n", "i" }, "<C-S-s>", "<Esc>:wa<CR>", { desc = "Save all buffers" })

map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "general copy whole file" })

map({ "n", "x" }, "<leader>fm", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "general format file" })

-- tabufline
map("n", "<leader>b", "<cmd>enew<CR>", { desc = "buffer new" })

map("n", "<tab>", function()
  require("nvchad.tabufline").next()
end, { desc = "buffer goto next" })

map("n", "<S-tab>", function()
  require("nvchad.tabufline").prev()
end, { desc = "buffer goto prev" })

map("n", "<leader>x", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "buffer close" })

map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })

-- Comment
map("n", "<leader>/", "gcc", { desc = "toggle comment", remap = true })
map("v", "<leader>/", "gc", { desc = "toggle comment", remap = true })

-- telescope
map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", { desc = "telescope live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "telescope find buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "telescope help page" })
map("n", "<leader>ma", "<cmd>Telescope marks<CR>", { desc = "telescope find marks" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "telescope find oldfiles" })
map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "telescope find in current buffer" })
map("n", "<leader>cm", "<cmd>Telescope git_commits<CR>", { desc = "telescope git commits" })
map("n", "<leader>gt", "<cmd>Telescope git_status<CR>", { desc = "telescope git status" })
map("n", "<leader>pt", "<cmd>Telescope terms<CR>", { desc = "telescope pick hidden term" })

map("n", "<leader>th", function()
  require("nvchad.themes").open()
end, { desc = "telescope nvchad themes" })

map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "telescope find files" })
map(
  "n",
  "<leader>fa",
  "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
  { desc = "telescope find all files" }
)

--------------------------------------------------------------------------------
--                          Custom mappings
--------------------------------------------------------------------------------

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
map("n", "<C-e>", "<cmd>Telescope find_files<CR>", { noremap = true, silent = true, desc = "telescope find files" })
map("n", "<C-f>", "<cmd>Telescope live_grep<CR>", { noremap = true, silent = true, desc = "telescope live grep" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Recent Files" })

-- allow to move selected lines up/down
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

--use leader to copy to system clipboard
vim.opt.clipboard = "" -- disables use of system clipboard
map("n", "<leader>y", '"+y', { desc = "copy to system clipboard" })
map("v", "<leader>y", '"+y', { desc = "copy to system clipboard" })
map({ "i", "!", "t", "c" }, "<C-p>", '<C-r>"', { desc = "Paste from clipboard in insert mode" })

-- navigate "quick-fix list"
map("n", "<leader>j", "<cmd>cnext<CR>zz", { desc = "Quick-fix list next" })
map("n", "<leader>k", "<cmd>cprev<CR>zz", { desc = "Quick-fix list prev" })
map("n", "<F4>", "<cmd>cnext<CR>zz", { desc = "Quick-fix list next" })
map("n", "<S-F4>", "<cmd>cprev<CR>zz", { desc = "Quick-fix list next" })
map("n", "<F16>", "<cmd>cprev<CR>zz", { desc = "Quick-fix list prev" }) -- workaround for S-F4 not working in rio terminal

-- ADD J/K of 2+lines to jumplist
map("n", "j", [[v:count ? (v:count >= 3 ? "m'" . v:count : '') . 'j' : 'gj']], { noremap = true, expr = true })
map("n", "k", [[v:count ? (v:count >= 3 ? "m'" . v:count : '') . 'k' : 'gk']], { noremap = true, expr = true })

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

--- navigation with hjkl in insert mode
map("i", "<C-h>", "<ESC>^i", { desc = "move beginning of line" })
map("i", "<C-l>", "<End>", { desc = "move end of line" })
map("i", "<C-j>", "<Down>", { desc = "move down" })
map("i", "<C-k>", "<Up>", { desc = "move up" })

-- toggle terminal
map({ "n", "t", "i" }, "<C-`>", function()
  -- require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
  local current_buf = vim.api.nvim_get_current_buf()
  local current_buf_name = vim.api.nvim_buf_get_name(current_buf)

  -- If we're currently in a terminal, go back to previous buffer
  if current_buf_name:match "^term://" then
    vim.cmd "buffer #"
    return
  end

  -- Look for existing terminal buffer
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if buf_name:match "^term://" then
        -- Found terminal buffer, switch to it
        vim.cmd("buffer " .. buf)
        -- vim.cmd "startinsert"
        return
      end
    end
  end

  -- No terminal found, create new one
  vim.cmd "terminal"
  vim.cmd "startinsert"
end, { desc = "terminal toggle" })

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

-- some apps
map("n", "<leader>u", "<cmd>UndotreeToggle<CR>")
-- map("n", "-", "<cmd>Oil<Cr>")

-- TODO:
-- RustLsp renderDiagnostics
-- vim.cmd.RustLsp('renderDiagnostic')
-- RustLsp explainError
-- vim.cmd.RustLsp('explainError')

-- telescope lsp integration
-- Find references for the word under your cursor.
map("n", "gr", require("telescope.builtin").lsp_references, { noremap = true, desc = "[G]oto [R]eferences" })

-- Jump to the implementation of the word under your cursor.
--  Useful when your language has ways of declaring types without an actual implementation.
map("n", "gi", require("telescope.builtin").lsp_implementations, { noremap = true, desc = "[G]oto [I]mplementation" })

-- Jump to the definition of the word under your cursor.
--  This is where a variable was first declared, or where a function is defined, etc.
--  To jump back, press <C-t>.
map("n", "gd", require("telescope.builtin").lsp_definitions, { noremap = true, desc = "[G]oto [D]efinition" })

-- This is not Goto Definition, this is Goto Declaration.
-- For example, in C this would take you to the header.
map("n", "gD", vim.lsp.buf.declaration, { desc = "[G]oto [D]eclaration" })

-- Fuzzy find all the symbols in your current document.
--  Symbols are things like variables, functions, types, etc.
map("n", "go", require("telescope.builtin").lsp_document_symbols, { desc = "Open Document Symbols" })

-- Fuzzy find all the symbols in your current workspace.
--  Similar to document symbols, except searches over your entire project.
map("n", "gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, { desc = "Open Workspace Symbols" })

-- Jump to the type of the word under your cursor.
--  Useful when you're not sure what type a variable is and you want to see
--  the definition of its *type*, not where it was *defined*.
map("n", "gt", require("telescope.builtin").lsp_type_definitions, { desc = "[G]oto [T]ype Definition}" })

-- open file in git
map("n", "<leader>gg", function()
  require("snacks").gitbrowse()
end, { desc = "Open file in git URL" })

-- shift+arrow selection
map("n", "<S-Up>", "v<Up>", { desc = "Select upward in normal mode" })
map("n", "<S-Down>", "v<Down>", { desc = "Select downward in normal mode" })
map("n", "<S-Left>", "v<Left>", { desc = "Select left in normal mode" })
map("n", "<S-Right>", "v<Right>", { desc = "Select right in normal mode" })

map("v", "<S-Up>", "<Up>", { desc = "Move selection upward" })
map("v", "<S-Down>", "<Down>", { desc = "Move selection downward" })
map("v", "<S-Left>", "<Left>", { desc = "Move selection left" })
map("v", "<S-Right>", "<Right>", { desc = "Move selection right" })

map("i", "<S-Up>", "<Esc>v<Up>", { desc = "Exit insert and select upward" })
map("i", "<S-Down>", "<Esc>v<Down>", { desc = "Exit insert and select downward" })
map("i", "<S-Left>", "<Esc>v<Left>", { desc = "Exit insert and select left" })
map("i", "<S-Right>", "<Esc>v<Right>", { desc = "Exit insert and select right" })

-- close all buffers except the current one
map("n", "<leader><S-x>", "<cmd>%bd|e#<CR>", { desc = "close all buffers except the current one" })

map("n", "gh", function()
  require("neogit").open() -- { kind = "split" }
end, { desc = "open neogit" })

map("n", "gf", "gF", { desc = "open file under cursor (uses line and column if present" })
