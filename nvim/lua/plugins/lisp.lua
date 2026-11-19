-- lua/plugins/lisp.lua

-- Conjure for REPL-driven evaluation in the Lisp family, with MIT Scheme as
-- the Scheme REPL.
--
-- Conjure lazy-loads on the first Lisp buffer, after `configure()` sets the
-- globals it reads.
--
-- $ sudo pacman -S tree-sitter-cli racket rlwrap expect
-- $ yay -S mit-scheme
--
-- See: lua/lib/lazy.lua
-- See: lua/plugins/treesitter.lua
-- See: https://github.com/Olical/conjure
-- See: https://aur.archlinux.org/packages/mit-scheme
-- See: https://web.mit.edu/scheme/current/doc/mit-scheme-user/Introduction.html

local M = {}

---Set the Conjure globals. Called once per session by `lib.lazy`, before
---Conjure is loaded.
function M.configure()
	-- The local leader must be set before Conjure defines its mappings.
	if vim.g.maplocalleader == nil or vim.g.maplocalleader == "" then
		vim.g.maplocalleader = ","
	end

	vim.g["conjure#filetype#scheme"] = "conjure.client.scheme.stdio"
	vim.g["conjure#client#scheme#stdio#command"] = "unbuffer -p mit-scheme"

	-- A docked split on the far right replaces the floating HUD.
	vim.g["conjure#log#hud#enabled"] = false
	vim.g["conjure#log#botright"] = true
	vim.g["conjure#log#split#width"] = 0.5
	vim.opt.splitright = true

	vim.g["conjure#highlight#enabled"] = true

	vim.g["conjure#mapping#eval_current_form"] = "ee"
	vim.g["conjure#mapping#eval_root_form"] = "er"
	vim.g["conjure#mapping#eval_word"] = "ew"
	vim.g["conjure#mapping#eval_file"] = "ef"
	vim.g["conjure#mapping#eval_buf"] = "eb"
	vim.g["conjure#mapping#eval_visual"] = "E"
	vim.g["conjure#mapping#eval_motion"] = "E"
	vim.g["conjure#mapping#eval_marked_form"] = "em"
	vim.g["conjure#mapping#eval_previous"] = "ep"
	vim.g["conjure#mapping#eval_replace_form"] = "e!"

	vim.g["conjure#eval#comment_prefix"] = "; => "
	vim.g["conjure#mapping#eval_comment_current_form"] = "ece"
	vim.g["conjure#mapping#eval_comment_root_form"] = "ecr"
	vim.g["conjure#mapping#eval_comment_word"] = "ecw"

	vim.g["conjure#mapping#log_split"] = "ls"
	vim.g["conjure#mapping#log_vsplit"] = "lv"
	vim.g["conjure#mapping#log_tab"] = "lt"
	vim.g["conjure#mapping#log_buf"] = "le"
	vim.g["conjure#mapping#log_toggle"] = "lg"
	vim.g["conjure#mapping#log_close_visible"] = "lq"
	vim.g["conjure#mapping#log_reset_soft"] = "lr"
	vim.g["conjure#mapping#log_reset_hard"] = "lR"
	vim.g["conjure#mapping#log_jump_to_latest"] = "ll"

	vim.g["conjure#mapping#def_word"] = "gd"
	vim.g["conjure#mapping#doc_word"] = { "K" }

	-- Opens the log split on the first Scheme, Lisp or Racket buffer, on a
	-- best-effort basis. It is registered here so that it only exists while
	-- Conjure is loaded.
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("conjure_auto_log_split", { clear = true }),
		pattern = { "scheme", "lisp", "racket" },
		callback = function()
			if vim.g.conjure_log_split_opened then
				return
			end
			vim.g.conjure_log_split_opened = true
			local origin_win = vim.api.nvim_get_current_win()
			vim.defer_fn(function()
				pcall(vim.cmd, "ConjureLogVsplit")
				if vim.api.nvim_win_is_valid(origin_win) then
					vim.api.nvim_set_current_win(origin_win)
				end
			end, 50)
		end,
	})
end

require("lib.lazy").setup({
	src = "https://github.com/Olical/conjure",
	filetypes = { "scheme", "lisp", "racket", "clojure" },
	configure = M.configure,
})

return M
