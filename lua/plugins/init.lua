return {

  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    -- import = "nvchad.plugins",
  },

  ------------------------------------------------------------------
  --- NVChad
  ------------------------------------------------------------------
  { "nvim-lua/plenary.nvim" },

  {
    "nvchad/base46",
    build = function()
      require("base46").load_all_highlights()
    end,
  },

  {
    "nvchad/ui",
    lazy = false,
    config = function()
      require "nvchad"
    end,
  },

  -- { "nvzone/volt", lazy = true },
  -- { "nvzone/menu", lazy = true },
  -- { "nvzone/minty", cmd = { "Huefy", "Shades" } },

  {
    "nvim-tree/nvim-web-devicons",
    opts = function()
      dofile(vim.g.base46_cache .. "devicons")
      return { override = require "nvchad.icons.devicons" }
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    event = "User FilePost",
    opts = {
      indent = { char = "│", highlight = "IblChar" },
      scope = { char = "│", highlight = "IblScopeChar" },
    },
    config = function(_, opts)
      dofile(vim.g.base46_cache .. "blankline")

      local hooks = require "ibl.hooks"
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
      require("ibl").setup(opts)
    end,
  },

  -- file managing , picker etc
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    opts = {
      filters = { dotfiles = false },
      -- disable_netrw = true,
      hijack_cursor = true,
      sync_root_with_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = false,
      },
      view = {
        width = 30,
        preserve_window_proportions = true,
      },
      renderer = {
        root_folder_label = false,
        highlight_git = true,
        indent_markers = { enable = true },
        icons = {
          glyphs = {
            default = "󰈚",
            folder = {
              default = "",
              empty = "",
              empty_open = "",
              open = "",
              symlink = "",
            },
            git = { unmerged = "" },
          },
        },
      },
    },
  },

  {
    "folke/which-key.nvim",
    keys = { "<leader>", "<c-w>", '"', "'", "`", "c", "v", "g" },
    cmd = "WhichKey",
    opts = function()
      dofile(vim.g.base46_cache .. "whichkey")
      return {}
    end,
  },

  ------------------------------------------------------------------
  --- Formatting
  ------------------------------------------------------------------

  -- TODO formatting for toml files

  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- format on save
    opts = function()
      local opts = require "configs.conform"

      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
        rust = { "rustfmt_nightly" },
        solidity = { "forge_fmt" },
        lua = { "stylua" },
      })

      opts.formatters = vim.tbl_deep_extend("force", opts.formatters or {}, {
        rustfmt_nightly = {
          command = "rustfmt",
          options = {
            default_edition = "2021",
          },
          env = { RUSTUP_TOOLCHAIN = "nightly" },
          args = function(self, ctx)
            local args = {
              "--emit=stdout",
              "--unstable-features",
            }
            -- Get the edition from Cargo.toml or use default
            local edition = require("conform.util").parse_rust_edition(ctx.dirname) or self.options.default_edition
            table.insert(args, "--edition=" .. edition)
            return args
          end,
          stdin = true,
          cwd = require("conform.util").root_file {
            "Cargo.toml",
            "rustfmt.toml",
            ".rustfmt.toml",
          },
        },
      })

      opts.format_on_save = {
        lsp_format = "fallback",
        timeout_ms = 2000,
      }

      return opts
    end,
  },

  ------------------------------------------------------------------
  --- LSP stuff
  ------------------------------------------------------------------

  {
    "neovim/nvim-lspconfig",
    event = "User FilePost",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall" },
    opts = {
      PATH = "append", -- use stuff that already exists on $PATH
      ensure_installed = {
        "lua-language-server",
        "html-lsp",
        "prettier",
        "stylua",
        "gopls",
        "rust-analyzer",
        "solhint",
        "nomicfoundation-solidity-language-server",
      },
    },
  },

  ------------------------------------------------------------------
  --- Git stuff
  ------------------------------------------------------------------

  {
    "lewis6991/gitsigns.nvim",
    event = "User FilePost",
    opts = {
      signs = {
        delete = { text = "󰍵" },
        changedelete = { text = "󱕖" },
      },
      current_line_blame = true,
      on_attach = function(bufnr)
        local gitsigns = require "gitsigns"

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]", function()
          if vim.wo.diff then
            vim.cmd.normal { "]c", bang = true }
          else
            ---@diagnostic disable-next-line: param-type-mismatch
            gitsigns.nav_hunk "next"
          end
        end)

        map("n", "[", function()
          if vim.wo.diff then
            vim.cmd.normal { "[c", bang = true }
          else
            ---@diagnostic disable-next-line: param-type-mismatch
            gitsigns.nav_hunk "prev"
          end
        end)

        -- Actions
        map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Git: Stage Hunk" })
        map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Git: Reset Hunk" })

        map("v", "<leader>hs", function()
          gitsigns.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
        end, { desc = "Git: Stage Hunk" })

        map("v", "<leader>hr", function()
          gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
        end, { desc = "Git: Reset Hunk" })

        map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Git: Stage Buffer" })
        map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Git: Reset Buffer" })
        map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Git: Preview Hunk" })
        map("n", "<leader>hi", gitsigns.preview_hunk_inline, { desc = "Git: Preview Hunk Inline" })

        map("n", "<leader>hd", gitsigns.diffthis)

        map("n", "<leader>hD", function()
          ---@diagnostic disable-next-line: param-type-mismatch
          gitsigns.diffthis "~"
        end)

        map("n", "<leader>hQ", function()
          ---@diagnostic disable-next-line: param-type-mismatch
          gitsigns.setqflist "all"
        end)
        map("n", "<leader>hq", gitsigns.setqflist)

        -- Toggles
        map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
        map("n", "<leader>tw", gitsigns.toggle_word_diff)

        -- Text object
        map({ "o", "x" }, "ih", gitsigns.select_hunk)
      end,
    },
  },

  { "sindrets/diffview.nvim", lazy = false },

  {
    "NeogitOrg/neogit",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional - Diff integration

      -- Only one of these is needed.
      -- "nvim-telescope/telescope.nvim", -- optional
      -- "ibhagwan/fzf-lua",              -- optional
      -- "echasnovski/mini.pick", -- optional
      "folke/snacks.nvim", -- optional
    },

    config = function()
      -- NOTE: need to re-apply these theme changes, otherwise they will disappear
      dofile(vim.g.base46_cache .. "syntax")
      dofile(vim.g.base46_cache .. "git")

      require("neogit").setup {
        disable_commit_confirmation = true,
        integrations = {
          diffview = true,
          snacks = true,
        },
      }
    end,
  },

  ------------------------------------------------------------------
  --- Autocompletion
  ------------------------------------------------------------------

  -- compatibility layer for blink.cmp sources
  {
    "saghen/blink.compat",
    -- use v2.* for blink.cmp v1.*
    version = "2.*",
    -- lazy.nvim will automatically load the plugin when it's required by blink.cmp
    lazy = true,
    -- make sure to set opts so that lazy.nvim calls blink.compat's setup
    opts = {},
  },

  {
    "saghen/blink.cmp",
    lazy = false,
    -- optional: provides snippets for the snippet source
    dependencies = {
      --"rafamadriz/friendly-snippets"
      "saecki/crates.nvim",
    },

    -- use a release tag to download pre-built binaries
    version = "1.*",
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
      -- 'super-tab' for mappings similar to vscode (tab to accept)
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- All presets have the following mappings:
      -- C-space: Open menu or open docs if already open
      -- C-n/C-p or Up/Down: Select next/previous item
      -- C-e: Hide menu
      -- C-k: Toggle signature help (if signature.enabled = true)
      --
      -- See :h blink-cmp-config-keymap for defining your own keymap
      keymap = { preset = "enter" },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = "mono",
      },

      -- (Default) Only show the documentation popup when manually triggered
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = "single" },
        },
        -- menu = require("nvchad.blink").menu,
        menu = {
          scrollbar = true,
          border = "single",
          draw = {
            padding = { 1, 1 },
            columns = { { "label" }, { "kind_icon" }, { "kind" } },
            components = {
              kind_icon = {
                text = function(ctx)
                  local icons = require "nvchad.icons.lspkind"
                  local icon = (icons[ctx.kind] or "󰈚")
                  return icon
                end,
              },

              kind = {
                highlight = function(ctx)
                  return ctx.kind
                end,
              },
            },
          },
        },
      },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      -- TODO check if integration with autopairs is good
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "crates" },
        providers = {
          crates = {
            name = "crates",
            module = "blink.compat.source",
          },
          -- magenta = {
          --   name = "magenta",
          --   module = "blink.compat.source",
          -- },
        },
      },

      -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
      -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
      -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
      --
      -- See the fuzzy documentation for more information
      fuzzy = { implementation = "prefer_rust_with_warning" },
      -- cmdline = { enabled = false },
    },
    opts_extend = { "sources.default" },
  },

  {
    "supermaven-inc/supermaven-nvim",
    lazy = false,
    config = function()
      require("supermaven-nvim").setup {
        keymaps = {
          accept_suggestion = "<Tab>",
          -- clear_suggestion = "<C-S-h>",
          -- accept_word = "<S-l>",
        },
        color = {
          suggestion_color = "#7a7e85",
          cterm = 244,
        },
      }
    end,
  },

  -- {
  --   "dlants/magenta.nvim",
  --   lazy = false, -- you could also bind to <leader>mt
  --   build = "npm install --frozen-lockfile",
  --   opts = {
  --     profiles = {
  --       {
  --         name = "claude",
  --         provider = "anthropic",
  --         model = "claude-4-sonnet-20250514",
  --
  --         fastModel = "claude-3-5-haiku-20241022", -- optional, defaults provided
  --         -- apiKeyEnvVar = "ANTHROPIC_API_KEY",
  --         authType = "max",
  --         thinking = {
  --           enabled = true,
  --           -- budgetTokens = 1024, -- optional, defaults to 1024, must be >= 1024
  --         },
  --       },
  --     },
  --     sidebarPosition = "right",
  --     picker = "snacks",
  --     defaultKeymaps = true,
  --   },
  -- },

  ------------------------------------------------------------------
  --- MISC
  ------------------------------------------------------------------

  -- { "karb94/neoscroll.nvim" },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    cmd = "Telescope",
    opts = {
      defaults = {
        prompt_prefix = "   ",
        selection_caret = " ",
        entry_prefix = " ",
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
          },
          width = 0.87,
          height = 0.80,
        },
        mappings = {
          n = { ["q"] = require("telescope.actions").close },
        },
      },

      extensions_list = { "themes", "terms" },
      extensions = {},
    },
    -- config = function()
    --   require("telescope").setup {
    --     pickers = {
    --       find_files = {
    --         find_command = { "rg", "--files", "--iglob", "!.git", "--hidden" },
    --       },
    --       grep_string = {
    --         additional_args = { "--hidden" },
    --       },
    --       live_grep = {
    --         additional_args = { "--hidden" },
    --       },
    --     },
    --   }
    -- end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "lua", "luadoc", "printf", "vim", "vimdoc" },

      highlight = {
        enable = true,
        use_languagetree = true,
      },

      indent = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  {
    "jake-stewart/multicursor.nvim",
    lazy = false,
    branch = "1.0",
    config = function()
      local mc = require "multicursor-nvim"
      mc.setup()

      local set = vim.keymap.set

      -- Add or skip cursor above/below the main cursor.
      -- set({ "n", "x" }, "<up>", function()
      --   mc.lineAddCursor(-1)
      -- end)
      -- set({ "n", "x" }, "<down>", function()
      --   mc.lineAddCursor(1)
      -- end)
      -- set({ "n", "x" }, "<leader><up>", function()
      --   mc.lineSkipCursor(-1)
      -- end)
      -- set({ "n", "x" }, "<leader><down>", function()
      --   mc.lineSkipCursor(1)
      -- end)

      -- Add or skip adding a new cursor by matching word/selection
      set({ "n", "x" }, "m", function()
        mc.matchAddCursor(1)
      end)
      set({ "n", "x" }, "M", function()
        mc.matchAddCursor(-1)
      end)
      -- set({ "n", "x" }, "<leader>s", function()
      --   mc.matchSkipCursor(1)
      -- end)
      -- set({ "n", "x" }, "<leader>S", function()
      --   mc.matchSkipCursor(-1)
      -- end)

      -- Add and remove cursors with control + left click.
      set("n", "<c-leftmouse>", mc.handleMouse)
      set("n", "<c-leftdrag>", mc.handleMouseDrag)
      set("n", "<c-leftrelease>", mc.handleMouseRelease)

      -- Disable and enable cursors.
      set({ "n", "x" }, "<c-q>", mc.toggleCursor)

      -- Mappings defined in a keymap layer only apply when there are
      -- multiple cursors. This lets you have overlapping mappings.
      mc.addKeymapLayer(function(layerSet)
        -- Select a different cursor as the main one.
        layerSet({ "n", "x" }, "<left>", mc.prevCursor)
        layerSet({ "n", "x" }, "<right>", mc.nextCursor)

        -- Delete the main cursor.
        layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

        -- Enable and clear cursors using escape.
        layerSet("n", "<esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)

      -- Customize how cursors look.
      local hl = vim.api.nvim_set_hl
      hl(0, "MultiCursorCursor", { reverse = true })
      hl(0, "MultiCursorVisual", { link = "Visual" })
      hl(0, "MultiCursorSign", { link = "SignColumn" })
      hl(0, "MultiCursorMatchPreview", { link = "Search" })
      hl(0, "MultiCursorDisabledCursor", { reverse = true })
      hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
      hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
    end,
  },

  -- VScode-like breadcrumbs
  {
    "Bekaboo/dropbar.nvim",
    lazy = false,
    -- optional, but required for fuzzy finder support
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
    config = function()
      local dropbar_api = require "dropbar.api"
      vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
      -- vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
      vim.keymap.set("n", "<C-S-.>", dropbar_api.select_next_context, { desc = "Select next context" })
    end,
    opts = {
      bar = { hover = false },
    },
  },

  -- lazy loads lua projects to LUA_LSP as they are required
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  {
    "rmagatti/auto-session",
    lazy = false,
    ---enables autocomplete for opts
    ---@module "auto-session"
    -- ---@type AutoSession.Config
    opts = {
      suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
      -- log_level = 'debug',
    },
  },

  -- {
  --   "petertriho/nvim-scrollbar",
  --   lazy = false,
  --   config = function()
  --     require("scrollbar").setup {
  --       -- TODO git colors are not correct
  --       handle = {
  --         color = "White",
  --       },
  --       marks = {
  --         Search = { color = "#ff6600" },
  --         Error = { color = "DiagnosticError" },
  --         Warn = { color = "DiagnosticWarn" },
  --         Info = { color = "DiagnosticInfo" },
  --         Hint = { color = "DiagnosticHint" },
  --         Misc = { color = "Identifier" },
  --         GitAdd = { color = "green" },
  --         GitChange = { color = "orange" },
  --         GitDelete = { color = "red" },
  --       },
  --     }
  --     require("scrollbar.handlers.search").setup {
  --       -- hlslens config overrides
  --       override_lens = function() end,
  --     }
  --     require("gitsigns").setup()
  --     require("scrollbar.handlers.gitsigns").setup()
  --   end,
  -- },

  -- {
  --   "kevinhwang91/nvim-hlslens",
  -- },
  -- {
  --   "levouh/tint.nvim",
  --   event = "VeryLazy",
  --   opts = {
  --     tint = 0, -- Negative values darken inactive windows
  --     saturation = 0.3, -- Slight desaturation
  --   },
  --   keys = {
  --     { "<leader>ti", "<cmd>TintToggle<cr>", desc = "Toggle window tinting" },
  --   },
  -- },

  {
    "leath-dub/snipe.nvim",
    keys = {
      {
        "gb",
        function()
          require("snipe").open_buffer_menu()
        end,
        desc = "Open Snipe buffer menu",
      },
    },
    opts = {},
  },

  {
    "folke/todo-comments.nvim",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      keywords = {
        FIX = {
          icon = " ", -- icon used for the sign, and in search results
          color = "error", -- can be a hex color, or a named color (see below)
          alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
          -- signs = false, -- configure signs for some keywords individually
        },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
      highlight = {
        multiline = true,
        pattern = [[.*<(KEYWORDS)\s*]],
        keyword = "fg",
        after = "fg",
      },
      colors = {
        error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
        warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
        info = { "DiagnosticInfo", "#2563EB" },
        hint = { "#f28d11", "DiagnosticHint", "#10B981" },
        default = { "Identifier", "#7C3AED" },
        test = { "Identifier", "#FF00FF" },
      },
      search = {
        pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
      },
    },
  },

  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = {
      {
        "<leader>tx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>tX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>tL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>tQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
      {
        "<leader>tD",
        "<cmd>Trouble todo filter = {tag = {TODO,FIX,FIXME}}<cr>",
        desc = "TODO List (Trouble)",
      },
    },
  },

  {
    "Goose97/timber.nvim",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("timber").setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  },

  {
    "unblevable/quick-scope",
    lazy = false,
    init = function()
      vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }
    end,
  },
  --
  -- {
  --   "MagicDuck/grug-far.nvim",
  --   -- Note (lazy loading): grug-far.lua defers all it's requires so it's lazy by default
  --   -- additional lazy config to defer loading is not really needed...
  --   init = function()
  --     -- optional setup call to override plugin options
  --     -- alternatively you can set options with vim.g.grug_far = { ... }
  --     require("grug-far").setup {
  --       -- options, see Configuration section below
  --       -- there are no required options atm
  --     }
  --   end,
  -- },

  {
    "stevearc/oil.nvim",
    opts = {},
    -- Optional dependencies
    -- dependencies = { { "echasnovski/mini.icons", opts = {} } },
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
    init = function()
      require("oil").setup()
    end,
  },

  {
    "kylechui/nvim-surround",
    version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  },

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      bigfile = { enabled = true },
      -- dashboard = { enabled = true },
      explorer = { enabled = true },
      indent = { enabled = true, animate = { enabled = false } },
      input = { enabled = true },
      picker = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      -- scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
  },

  -- {
  --   "ThePrimeagen/harpoon",
  --   branch = "harpoon2",
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   init = function()
  --     local harpoon = require "harpoon"
  --     harpoon:setup()
  --     local conf = require("telescope.config").values
  --     -- add to the list
  --     vim.keymap.set("n", "<leader>a", function()
  --       harpoon:list():add()
  --     end, { desc = "add file to harpoon" })
  --
  --     vim.keymap.set("n", "=", function()
  --       harpoon.ui:toggle_quick_menu(harpoon:list())
  --     end)
  --     -- toggle harpoon menu
  --     vim.keymap.set("n", "-", function()
  --       local make_finder = function()
  --         local paths = {}
  --         for _, item in ipairs(harpoon:list()) do
  --           table.insert(paths, item.value)
  --         end
  --         return require("telescope.finders").new_table {
  --           results = paths,
  --         }
  --       end
  --
  --       require("telescope.pickers")
  --         .new({}, {
  --           prompt_title = "Harpoon",
  --           finder = make_finder(),
  --           previewer = conf.file_previewer {},
  --           sorter = conf.generic_sorter {},
  --           attach_mappings = function(prompt_buffer_number, map)
  --             -- delete entries from the telescope list
  --             map("i", "<C-d>", function()
  --               local state = require "telescope.actions.state"
  --               local selected_entry = state.get_selected_entry()
  --               local current_picker = state.get_current_picker(prompt_buffer_number)
  --               harpoon:list():remove(selected_entry)
  --               current_picker:refresh(make_finder())
  --             end)
  --
  --             return true
  --           end,
  --         })
  --         :find()
  --     end, { noremap = true, desc = "Open harpoon window" })
  --   end,
  -- },

  {
    "dmtrKovalenko/fff.nvim",
    build = "cargo build --release",
    opts = {
      layout = {
        prompt_position = "top",
      },
      frecency = {
        enabled = true,
      },
    },
    keys = {
      {
        "<C-->",
        function()
          require("fff").find_files() -- or find_in_git_root() if you only want git files
        end,
        desc = "Open file picker",
      },
      {
        "-",
        function()
          require("fff").find_in_git_root()
        end,
        desc = "Open file picker",
      },
    },
  },

  -- {
  --   "MeanderingProgrammer/render-markdown.nvim",
  --   lazy = false,
  --   dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
  --   -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
  --   -- dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
  --   ---@module 'render-markdown'
  --   ---@type render.md.UserConfig
  --   opts = {},
  -- },

  ------------------------------------------------------------------
  --- RUST
  ------------------------------------------------------------------
  {
    -- NOTE: must use rust-analyzer from rustup `rustup component add rust-analyzer`
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false,
    dependencies = {
      "mason-org/mason.nvim",
    },
    init = function()
      vim.g.rustaceanvim = {
        -- Disable if you have issues
        tools = {
          hover_actions = {
            auto_focus = false,
          },
        },
        server = {
          -- on_attach = function(client, bufnr) end,
          default_settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                buildScripts = {
                  enable = true,
                },
              },
              checkOnSave = true,
              check = {
                command = "clippy",
              },
              procMacro = {
                enable = true,
              },
            },
          },
        },
      }
      -- vim.g.rustaceanvim.tools.test_executor = "background"
      -- vim.g.rustaceanvim.tools.enable_nextest = false
    end,
  },

  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("neotest").setup {
        ---@diagnostic disable-next-line: missing-fields
        adapters = {
          require "rustaceanvim.neotest",
        },
      }
    end,
  },

  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap, dapui = require "dap", require "dapui"
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
      dap.adapters.codelldb = {
        type = "executable",
        command = "codelldb",
      }
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      require("dapui").setup()
    end,
  },

  {
    "saecki/crates.nvim",
    tag = "stable",
    event = { "BufRead Cargo.toml" },
    config = function()
      require("crates").setup {
        completion = {
          cmp = {
            enabled = true,
          },
        },
      }
    end,
  },

  ------------------------------------------------------------------
  --- TYPESCRIPT
  ------------------------------------------------------------------
  { "dmmulroy/ts-error-translator.nvim" },

  ------------------------------------------------------------------
  --- AI
  ------------------------------------------------------------------
  -- {
  --   "yetone/avante.nvim",
  --   -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  --   -- ⚠️ must add this setting! ! !
  --   build = vim.fn.has "win32" ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
  --     or "make",
  --   event = "VeryLazy",
  --   version = false, -- Never set this value to "*"! Never!
  --   ---@module 'avante'
  --   ---@type avante.Config
  --   opts = {
  --     -- add any opts here
  --     -- for example
  --     provider = "ollama",
  --     providers = {
  --       -- claude = {
  --       --   endpoint = "https://api.anthropic.com",
  --       --   model = "claude-sonnet-4-20250514",
  --       --   timeout = 30000, -- Timeout in milliseconds
  --       --   extra_request_body = {
  --       --     temperature = 0.75,
  --       --     max_tokens = 20480,
  --       --   },
  --       -- },
  --       -- moonshot = {
  --       --   endpoint = "https://api.moonshot.ai/v1",
  --       --   model = "kimi-k2-0711-preview",
  --       --   timeout = 30000, -- Timeout in milliseconds
  --       --   extra_request_body = {
  --       --     temperature = 0.75,
  --       --     max_tokens = 32768,
  --       --   },
  --       -- },
  --       ollama = {
  --         endpoint = "http://localhost:11434",
  --         model = "qwen3-coder:latest",
  --       },
  --     },
  --   },
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "MunifTanjim/nui.nvim",
  --     --- The below dependencies are optional,
  --     "echasnovski/mini.pick", -- for file_selector provider mini.pick
  --     "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
  --     "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
  --     "ibhagwan/fzf-lua", -- for file_selector provider fzf
  --     "stevearc/dressing.nvim", -- for input provider dressing
  --     "folke/snacks.nvim", -- for input provider snacks
  --     "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
  --     "zbirenbaum/copilot.lua", -- for providers='copilot'
  --     {
  --       -- support for image pasting
  --       "HakonHarnes/img-clip.nvim",
  --       event = "VeryLazy",
  --       opts = {
  --         -- recommended settings
  --         default = {
  --           embed_image_as_base64 = false,
  --           prompt_for_file_name = false,
  --           drag_and_drop = {
  --             insert_mode = true,
  --           },
  --           -- required for Windows users
  --           use_absolute_path = true,
  --         },
  --       },
  --     },
  --     {
  --       -- Make sure to set this up properly if you have lazy=true
  --       "MeanderingProgrammer/render-markdown.nvim",
  --       opts = {
  --         file_types = { "markdown", "Avante" },
  --       },
  --       ft = { "markdown", "Avante" },
  --     },
  --   },
  -- },

  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    opts = {
      terminal = {
        provider = "native",
      },
    },
    keys = {
      { "<leader>a", nil, desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles" },
      },
      -- Diff management
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },
}
