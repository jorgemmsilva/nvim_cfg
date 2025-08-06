return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false, -- plugin is already lazy
    -- ft = { "rust" },
    -- config = function(_,_)
    --   vim.g.rustaceanvim = {
    --     server = { on_attach = on_attach }
    --   }
    -- end
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

  {
    "saecki/crates.nvim",
    tag = "stable",
    laxy = false,
    ft = { "toml" },
    config = function()
      require("crates").setup()
    end,
  },
}
