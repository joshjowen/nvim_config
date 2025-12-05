vim.pack.add({
	-- Language server
	{ src = "https://github.com/neovim/nvim-lspconfig" },

	-- Autocomplete and deps
	{ src = "https://github.com/hrsh7th/nvim-cmp" },
	{ src = "https://github.com/hrsh7th/cmp-nvim-lsp", rev = "99c4e3ea26262dbe457d8fd57b1136ede6157531" }, -- LSP source
	{ src = "https://github.com/hrsh7th/cmp-buffer" }, -- Buffer words
	{ src = "https://github.com/hrsh7th/cmp-path" }, -- Path autocompletion
	{ src = "https://github.com/L3MON4D3/LuaSnip" }, -- Required for snippets
	{ src = "https://github.com/saadparwaiz1/cmp_luasnip" }, -- Snippet source
	{ src = "https://github.com/onsails/lspkind.nvim" }, -- Icons for cmp menu
	{ src = "https://github.com/stevearc/conform.nvim" }, -- formatting

	-- Zebones and deps
	{ src = "https://github.com/zenbones-theme/zenbones.nvim" },
	{ src = "https://github.com/rktjmp/lush.nvim" }, -- required by zenbones

	-- neo-tree and deps
	{ src = "https://github.com/nvim-neo-tree/neo-tree.nvim", branch = "v2.x" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/MunifTanjim/nui.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },

	-- gitsigns
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },

	-- Telescope and deps
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	-- { src = 'https://github.com/nvim-lua/plenary.nvim' },

	-- Treesitter
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", run = ":TSUpdate" },
})

-- Set the default yank and paste to be the unnamed register
vim.opt.clipboard = ""

-- Set the + register to use OSC-52 to copy to the system clipboard
if vim.fn.has("win32") == 0 then
	vim.g.clipboard = {
		name = "OSC 52",
		copy = {
			["+"] = require("vim.ui.clipboard.osc52").copy("+"),
			["*"] = require("vim.ui.clipboard.osc52").copy("*"),
		},
		paste = {
			["+"] = function()
				return {
					vim.split(vim.fn.getreg("+"), "\n"),
					vim.fn.getregtype("+"),
				}
			end,
			["*"] = function()
				return {
					vim.split(vim.fn.getreg("*"), "\n"),
					vim.fn.getregtype("*"),
				}
			end,
		},
	}
end

-- Keymaps to enable shift-p shift-y and shift-yy to copy/paste to the system clipboard
vim.api.nvim_set_keymap("n", "YY", '"+yy', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "Y", '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "Y", '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "P", '"+p', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "P", '"+p', { noremap = true, silent = true })

-- Set the leader key to be space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 3

-- Configuration for zenbones.nvim
vim.g.zenbones_darken_comments = 45
vim.cmd.colorscheme("kanagawabones")
require("neo-tree").setup({
	filesystem = {
		filtered_items = {
			visible = true,
		},
		window = {
			mappings = {
				["\\"] = "close_window",
			},
		},
	},
})

vim.api.nvim_set_keymap("n", "\\", ":Neotree reveal<CR>", { noremap = true, silent = true, desc = "NeoTree reveal" })

-- Configuration for telescope
local telescope = require("telescope.builtin")
vim.keymap.set("n", "<leader>sf", telescope.find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sg", telescope.live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "gd", telescope.lsp_definitions, { desc = "[G]oto [D]efintion" })
vim.keymap.set("n", "gr", telescope.lsp_references, { desc = "[G]oto [R]eferences" })

--  Configuration for treesitter
require("nvim-treesitter.configs").setup({
	ensure_installed = { "c", "cpp", "python", "rust", "go", "lua" },
	highlight = { enable = true },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<C-space>",
			node_incremental = "<C-space>",
			scope_incremental = "<C-s>",
			node_decremental = "<C-backspace>",
		},
	},
})

-- Configuration for gitsigns
require("gitsigns").setup({
	on_attach = function(bufnr)
		local gitsigns = require("gitsigns")

		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		map("n", "]c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gitsigns.nav_hunk("next")
			end
		end, { desc = "Jump to next git [c]hange" })

		map("n", "[c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gitsigns.nav_hunk("prev")
			end
		end, { desc = "Jump to previous git [c]hange" })

		map("v", "<leader>hs", function()
			gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "git [s]tage hunk" })
		map("v", "<leader>hr", function()
			gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "git [r]eset hunk" })

		map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "git [s]tage hunk" })
		map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "git [r]eset hunk" })
		map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "git [S]tage buffer" })
		map("n", "<leader>hu", gitsigns.stage_hunk, { desc = "git [u]ndo stage hunk" })
		map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "git [R]eset buffer" })
		map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "git [p]review hunk" })
		map("n", "<leader>hb", gitsigns.blame_line, { desc = "git [b]lame line" })
		map("n", "<leader>hd", gitsigns.diffthis, { desc = "git [d]iff against index" })
		map("n", "<leader>hD", function()
			gitsigns.diffthis("@")
		end, { desc = "git [D]iff against last commit" })

		map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "[T]oggle git show [b]lame line" })
		map("n", "<leader>tD", gitsigns.preview_hunk_inline, { desc = "[T]oggle git show [D]eleted" })
	end,
})

-- Language server
vim.lsp.config("pyright", {
	settings = {
		pyright = {
			-- Using Ruff's import organizer
			disableOrganizeImports = true,
		},
		python = {
			analysis = {
				-- Ignore all files for analysis to exclusively use Ruff for linting
				ignore = { "*" },
			},
		},
	},
})
vim.lsp.config("ruff", {
	init_options = {
		settings = {
			logLevel = "debug",
		},
	},
})
vim.lsp.config("bashls", {})
vim.lsp.config("gopls", {})
vim.lsp.config("clangd", {})
vim.lsp.config("rust_analyzer", {})
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				checkThirdParty = false,
			},
			telemetry = {
				enable = false,
			},
		},
	},
})

require("conform").setup({
	formatters_by_ft = {
		python = {
			-- To fix auto-fixable lint errors.
			"ruff_fix",
			-- To run the Ruff formatter.
			"ruff_format",
			-- To organize the imports.
			"ruff_organize_imports",
		},
		sh = { "shfmt" },
		lua = { "stylua" },
		go = { "gofmt", "goimports" },
		yaml = { "yamlfmt" },
		json = { "jq" },
		cmake = { "cmake_format" },
	},
	format_on_save = false,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	callback = function()
		vim.lsp.enable("ruff") -- Python
		vim.lsp.enable("pyright") -- Python
		vim.lsp.enable("gopls") -- Go
		vim.lsp.enable("clangd") -- C and C++
		vim.lsp.enable("rust_analyzer") -- Rust
		vim.lsp.enable("bashls") -- Bash
	end,
	group = vim.api.nvim_create_augroup("LspAutoEnable", { clear = true }),
})

vim.keymap.set("n", "<leader>f", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "[F]ormat buffer" })

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })

-- Auto Complete
local cmp = require("cmp")
local lspkind = require("lspkind")
local luasnip = require("luasnip")

cmp.setup({
	sources = cmp.config.sources({
		{ name = "nvim_lsp" }, -- Autocompletion from LSP
		{ name = "luasnip" }, -- Autocompletion from snippets
		{ name = "buffer" }, -- Autocompletion from the current buffer
		{ name = "path" }, -- File path autocompletion
	}),

	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<C-y>"] = cmp.mapping.confirm({ select = true }),
	}),

	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},

	formatting = {
		format = lspkind.cmp_format({
			with_text = true,
			menu = {
				buffer = "[Buffer]",
				nvim_lsp = "[LSP]",
				luasnip = "[LuaSnip]",
				path = "[Path]",
			},
		}),
	},
})

luasnip.config.setup({})
