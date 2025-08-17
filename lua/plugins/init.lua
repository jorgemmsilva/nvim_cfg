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
      disable_netrw = true,
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
    },
  },

  ------------------------------------------------------------------
  --- Autocompletion
  ------------------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      -- {
      --   -- snippet plugin
      --   "L3MON4D3/LuaSnip",
      --   dependencies = "rafamadriz/friendly-snippets",
      --   opts = { history = true, updateevents = "TextChanged,TextChangedI" },
      --   config = function(_, opts)
      --     require("luasnip").config.set_config(opts)
      --     require "nvchad.configs.luasnip"
      --   end,
      -- },

      -- autopairing of (){}[] etc
      -- {
      --   "windwp/nvim-autopairs",
      --   opts = {
      --     fast_wrap = {},
      --     disable_filetype = { "TelescopePrompt", "vim" },
      --   },
      --   config = function(_, opts)
      --     require("nvim-autopairs").setup(opts)
      --
      --     -- setup cmp for autopairs
      --     local cmp_autopairs = require "nvim-autopairs.completion.cmp"
      --     require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
      --   end,
      -- },

      -- cmp sources plugins
      {
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "https://codeberg.org/FelipeLema/cmp-async-path.git",
        -- "saecki/crates.nvim",
      },
    },

    opts = function()
      local opts = require "nvchad.configs.cmp"

      local cmp = require "cmp"
      opts.mapping = vim.tbl_extend("force", opts.mapping or {}, {
        ["<Down>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select },
        ["<Up>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select },
      })

      opts.mapping["<Tab>"] = vim.NIL
      opts.mapping["<S-Tab>"] = vim.NIL

      table.insert(opts.sources, { name = "lazydev", group_index = 0 })
      table.insert(opts.sources, { name = "crates" })
      -- table.insert(opts.sources, { name = "supermaven" })
      opts.sorting = {
        comparators = {
          cmp.config.compare.exact,
          cmp.config.compare.offset,
          cmp.config.compare.recently_used,
        },
      }

      return opts
    end,
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

  -- {
  --   "unblevable/quick-scope",
  --   lazy = false,
  --   init = function()
  --     vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }
  --   end,
  -- },
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
      -- notifier = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      -- scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
  },

  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    init = function()
      local harpoon = require "harpoon"
      harpoon:setup()
      local conf = require("telescope.config").values
      local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end

        local make_finder = function()
          local paths = {}

          for _, item in ipairs(harpoon_files.items) do
            table.insert(paths, item.value)
          end

          return require("telescope.finders").new_table {
            results = paths,
          }
        end

        require("telescope.pickers")
          .new({}, {
            prompt_title = "Harpoon",
            finder = require("telescope.finders").new_table {
              results = file_paths,
            },
            previewer = conf.file_previewer {},
            sorter = conf.generic_sorter {},
            attach_mappings = function(prompt_buffer_number, map)
              -- delete entries from the telescope list
              map("i", "<C-d>", function()
                local state = require "telescope.actions.state"
                local selected_entry = state.get_selected_entry()
                local current_picker = state.get_current_picker(prompt_buffer_number)

                harpoon:list():remove(selected_entry)
                current_picker:refresh(make_finder())
              end)

              return true
            end,
          })
          :find()
      end

      -- add to the list
      vim.keymap.set("n", "<leader>a", function()
        harpoon:list():add()
      end, { desc = "add file to harpoon" })
      -- toggle harpoon menu
      vim.keymap.set("n", "-", function()
        toggle_telescope(harpoon:list())
      end, { noremap = true, desc = "Open harpoon window" })
    end,
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },

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
    laxy = false,
    ft = { "toml" },
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
}
