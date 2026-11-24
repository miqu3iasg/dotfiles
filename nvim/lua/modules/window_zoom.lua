-- lua/modules/window_zoom.lua

-- Zoom the focused window by showing it in a new tab, with the layout intact in
-- its own tab. Toggling again closes the zoom tab.
--
-- The state lives in the tabpage-local `t:zoomed`, which the statusline reads.
-- Closing the zoom tab by other means also ends the zoom.
--
-- See: doc/modules.md
-- See: lua/modules/statusline.lua

local M = {}

---@return boolean
function M.is_zoomed()
	return vim.t.zoomed == true
end

---Close the zoom tab when zoomed. Otherwise open one, unless the current window
---is already alone, since a single window in a single tab is already full
---screen.
function M.toggle()
	if vim.fn.tabpagenr("$") > 1 and M.is_zoomed() then
		vim.cmd("tabclose")
	elseif vim.fn.winnr("$") > 1 then
		vim.cmd("tab split")
		vim.t.zoomed = true
	end
end

return M
