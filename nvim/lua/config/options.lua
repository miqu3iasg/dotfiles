-- lua/config/options.lua

-- Global editor options, set once at startup.
--
-- `grepprg` relies on ripgrep, and the session options must match what
-- lua/modules/sessions.lua saves and restores.
--
-- See: lua/modules/sessions.lua
-- See: :help option-summary

-- `--smart-case` mirrors the search case rule below; `lib/substitute.lua`
-- passes `--case-sensitive` explicitly.
if vim.fn.executable("rg") == 1 then
	vim.opt.grepprg = "rg --vimgrep --smart-case"
end

-- The file explorer is canola.nvim, so netrw never loads.
vim.g.loaded_netrw = 1

vim.opt.hidden = true
vim.opt.history = 10000
vim.opt.showtabline = 0
vim.opt.switchbuf = "uselast" -- Jumps to the window that last showed the buffer.
vim.opt.showcmd = false
vim.opt.mouse = ""
vim.opt.wrap = false
vim.opt.startofline = false -- Keeps the cursor column on `gg` and `G`.
vim.opt.list = false
vim.opt.listchars = { tab = "¬·", trail = "•", nbsp = "·", space = "·" }
vim.opt.diffopt:append({ "algorithm:histogram", "indent-heuristic", "linematch:60" })

vim.opt.ignorecase = true
vim.opt.smartcase = true -- Case-sensitive only when the pattern has uppercase.
vim.opt.inccommand = "nosplit"
vim.opt.wildignorecase = true
vim.opt.wildignore:append({ "*/.git/*", "*/node_modules/*", "*/target/*", "*/dist/*" })
vim.opt.completeopt = "menuone,noselect"

vim.opt.path:append("**") -- Makes `:find` and `gf` recursive.
vim.opt.wildmenu = true
vim.opt.wildmode = "lastused,full"
vim.opt.wildoptions = "pum,fuzzy"
vim.opt.pumheight = 15

vim.opt.backspace = "indent,eol,start"
vim.opt.belloff = "all"
vim.opt.matchpairs:append("<:>") -- Lets `%` jump between angle brackets.
vim.opt.nrformats:remove("octal")
vim.opt.isfname:append("@-@")
vim.opt.formatoptions:remove("o")
vim.opt.clipboard = "unnamedplus" -- Yanks go to the system clipboard.
vim.opt.virtualedit = "block" -- Lets the cursor pass the line end in blockwise visual mode.
vim.opt.jumpoptions = "view" -- Restores the scroll position on jumps.
vim.opt.iskeyword:append("-") -- Treats kebab-case as one word.

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.laststatus = 2
vim.opt.winborder = "single"

vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 5
vim.opt.cmdheight = 1
vim.opt.signcolumn = "no"
vim.opt.termguicolors = true
vim.opt.title = false
vim.opt.titlestring = "%t"
vim.opt.background = "dark"
vim.opt.display:append("lastline")
vim.opt.more = true

vim.opt.shortmess:append("aIWsF")
vim.opt.shortmess:remove("S")

vim.opt.foldmethod = "manual"
vim.opt.foldlevel = 99 -- Starts with every fold open.
vim.opt.foldopen:remove("hor") -- Horizontal motions do not open folds.

-- Undo is persistent, so swap and backup files are not needed.
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undolevels = 10000
-- Must match what the sessions feature saves and restores.
vim.o.sessionoptions = "buffers,curdir,tabpages,winsize,help,globals,skiprtp,folds,terminal"

vim.opt.guicursor = "a:block"
