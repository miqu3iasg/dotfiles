-- lua/config/keymaps/inserts.lua

-- Date, time, filename and UUID insertion in insert and command-line mode.
--
-- `uuidgen` comes with util-linux.
--
-- See: :help map.txt

-- The `!` mode applies to both insert and command-line mode.
local km = vim.keymap.set

km("!", "<C-r><C-n>", "<C-r>=strftime('%F')<CR>", { desc = "Insert current date (YYYY-MM-DD)" })
km("!", "<C-r><C-b>", "<C-r>=strftime('%d/%m/%Y')<CR>", { desc = "Insert current date (DD/MM/YYYY)" })
km("!", "<C-r><C-t>", "<C-r>=strftime('%H:%M')<CR>", { desc = "Insert current time (HH:MM)" })
km(
	"!",
	"<C-r><C-d>",
	"<C-r>=strftime('%Y-%m-%dT%H:%M')<CR>",
	{ desc = "Insert current date and time (YYYY-MM-DDTHH:MM)" }
)
km("!", "<C-r><C-c>", "<C-r>=strftime('%Y%m%d%H%M')<CR>", { desc = "Insert compact date+time (YYYYMMDDHHMM)" })
km("!", "<C-r><C-e>", "<C-r>=expand('%:t:r')<CR>", { desc = "Insert current filename without extension" })
km("!", "<C-r><C-f>", "<C-r>=expand('%:t')<CR>", { desc = "Insert current filename with extension" })
km("!", "<C-r><C-u>", "<C-r>=trim(system('uuidgen'))<CR>", { desc = "Insert UUID" })
