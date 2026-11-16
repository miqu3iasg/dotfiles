-- lua/lib/colors.lua

-- Color and highlight helpers shared by the colorschemes in colors/. Every
-- theme used to carry its own copy of this machinery (three variants of the
-- same `blend`, two copies of the xterm-256 conversion, duplicated
-- frontmatter sync), drifting apart in argument order and behavior; this
-- module is the single version all of them build on.
--
-- The module is stateless except for the cterm conversion cache, which only
-- memoizes pure results. It registers nothing global: the colorschemes own
-- their `highlight clear`, their `colors_name` and their augroups.

local M = {}

---@class HighlightSpec
---Attributes of one highlight group, as passed to `nvim_set_hl`. Colors are
---hex strings ("#rrggbb"); attribute flags mirror the GUI attributes.
---@field fg? string Default (foreground) color.
---@field bg? string Background color.
---@field sp? string Special color: the underline/undercurl color.
---@field bold? boolean
---@field italic? boolean
---@field underline? boolean
---@field undercurl? boolean
---@field reverse? boolean
---@field strikethrough? boolean
---@field nocombine? boolean
---@field blend? integer Blend level for floating window shadows (0..100).
---@field link? string Group to link to; when present, other fields are ignored.
---@field cterm? table<string, boolean> Explicit cterm attributes, skipping derivation.

-- GUI attributes mirrored into `cterm` by `normalize`. `nocombine` is in the
-- list because enfocadomod sets it extensively; the others cover every flag
-- the themes use.
local ATTRS = { "bold", "italic", "underline", "undercurl", "reverse", "strikethrough", "nocombine" }

---Splits `#rrggbb` into its red, green and blue components.
---@param hex string
---@return integer r
---@return integer g
---@return integer b
function M.rgb(hex)
	return tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
end

---Mixes `fg` over `bg` with the given alpha (0..1): alpha 0 returns `bg`,
---alpha 1 returns `fg`.
---@param fg string
---@param bg string
---@param alpha number
---@return string
function M.blend(fg, bg, alpha)
	local fr, fgr, fb = M.rgb(fg)
	local br, bgr, bb = M.rgb(bg)
	local function mix(f, b)
		return math.floor(f * alpha + b * (1 - alpha) + 0.5)
	end
	return string.format("#%02x%02x%02x", mix(fr, br), mix(fgr, bgr), mix(fb, bb))
end

---Scales the HSL saturation of `hex` by `factor` (1 = unchanged, 0 = gray).
---Hue and lightness are preserved; grays are unaffected.
---@param hex string
---@param factor number
---@return string
function M.desaturate(hex, factor)
	local r, g, b = M.rgb(hex)
	r, g, b = r / 255, g / 255, b / 255
	local max, min = math.max(r, g, b), math.min(r, g, b)
	local l = (max + min) / 2
	if max == min then
		return hex
	end

	local d = max - min
	local s = l > 0.5 and d / (2 - max - min) or d / (max + min)
	local h
	if max == r then
		h = (g - b) / d + (g < b and 6 or 0)
	elseif max == g then
		h = (b - r) / d + 2
	else
		h = (r - g) / d + 4
	end
	h = h / 6

	s = s * factor

	local function hue(p, q, t)
		if t < 0 then
			t = t + 1
		end
		if t > 1 then
			t = t - 1
		end
		if t < 1 / 6 then
			return p + (q - p) * 6 * t
		end
		if t < 1 / 2 then
			return q
		end
		if t < 2 / 3 then
			return p + (q - p) * (2 / 3 - t) * 6
		end
		return p
	end

	local q = l < 0.5 and l * (1 + s) or l + s - l * s
	local p = 2 * l - q
	return string.format(
		"#%02x%02x%02x",
		math.floor(hue(p, q, h + 1 / 3) * 255 + 0.5),
		math.floor(hue(p, q, h) * 255 + 0.5),
		math.floor(hue(p, q, h - 1 / 3) * 255 + 0.5)
	)
end

-- xterm-256 has a 6x6x6 color cube (levels 0,95,135,175,215,255) and a
-- 24-step gray ramp (8,18,...,238). For every hex the closest candidate in
-- each is computed and the nearest one kept (euclidean RGB distance).
-- Results are cached, so the cost is paid once per distinct color.
local CUBE = { 0, 95, 135, 175, 215, 255 }
local cterm_cache = {}

local function nearest_cube_level(v)
	local best_i, best_d = 1, math.huge
	for i, c in ipairs(CUBE) do
		local d = math.abs(v - c)
		if d < best_d then
			best_i, best_d = i, d
		end
	end
	return best_i - 1
end

local function dist2(r1, g1, b1, r2, g2, b2)
	return (r1 - r2) ^ 2 + (g1 - g2) ^ 2 + (b1 - b2) ^ 2
end

---Converts a hex color to the nearest xterm-256 color index.
---@param hex string
---@return integer
function M.to256(hex)
	if cterm_cache[hex] then
		return cterm_cache[hex]
	end

	local r, g, b = M.rgb(hex)

	-- Best color-cube candidate
	local ri, gi, bi = nearest_cube_level(r), nearest_cube_level(g), nearest_cube_level(b)
	local cube_d = dist2(r, g, b, CUBE[ri + 1], CUBE[gi + 1], CUBE[bi + 1])

	-- Best gray-ramp candidate
	local step = math.max(0, math.min(23, math.floor(((r + g + b) / 3 - 8) / 10 + 0.5)))
	local gv = 8 + 10 * step
	local gray_d = dist2(r, g, b, gv, gv, gv)

	local idx = gray_d < cube_d and (232 + step) or (16 + 36 * ri + 6 * gi + bi)
	cterm_cache[hex] = idx
	return idx
end

local function is_hex(v)
	return type(v) == "string" and v:match("^#%x%x%x%x%x%x$") ~= nil
end

---Turns a group spec into `nvim_set_hl` options. A string spec links to the
---named group (with `force`, so the link wins over stale definitions); a
---table spec with `link` is passed through untouched; otherwise `ctermfg` and
---`ctermbg` are derived from hex `fg`/`bg` and every GUI attribute is mirrored
---into `cterm` (with undercurl falling back to underline on terminals
---without support), so the theme renders the same on any terminal.
---@param spec string|HighlightSpec
---@return HighlightSpec
function M.normalize(spec)
	if type(spec) == "string" then
		return { link = spec, force = true }
	end
	if spec.link or next(spec) == nil then
		return spec
	end

	local opts = vim.deepcopy(spec)

	if is_hex(opts.fg) and not opts.ctermfg then
		opts.ctermfg = M.to256(opts.fg)
	end
	if is_hex(opts.bg) and not opts.ctermbg then
		opts.ctermbg = M.to256(opts.bg)
	end

	if not opts.cterm then
		opts.cterm = {}
		for _, attr in ipairs(ATTRS) do
			if opts[attr] then
				opts.cterm[attr == "undercurl" and "underline" or attr] = true
			end
		end
	end
	return opts
end

---Sets every `group` → `spec` entry of `groups` in namespace `ns` (the global
---namespace when omitted), through `normalize`.
---@param groups table<string, string|HighlightSpec>
---@param ns? integer Defaults to the global namespace.
function M.apply(groups, ns)
	for name, spec in pairs(groups) do
		vim.api.nvim_set_hl(ns or 0, name, M.normalize(spec))
	end
end

---Writes `colors` (16 entries) into `terminal_color_0` ... `terminal_color_15`,
---defining the :terminal palette.
---@param colors string[]
function M.terminal_colors(colors)
	for i, color in ipairs(colors) do
		vim.g["terminal_color_" .. (i - 1)] = color
	end
end

---Applies `spec` in a dedicated namespace `name` and keeps it active only in
---markdown windows, so YAML frontmatter is themed without leaking into plain
---YAML buffers. The namespace, augroup and window sentinel variable share the
---`name`. Returns the augroup, so the theme can attach its own autocmds to the
---same group.
---
---Every markdown-focused theme (hollow, insanity, artifact) needs this, and
---the sync logic must agree across them; it lives here as the single copy.
---@param name string Namespace and augroup name.
---@param spec table<string, string|HighlightSpec>
---@return integer augroup
function M.frontmatter(name, spec)
	local ns = vim.api.nvim_create_namespace(name)
	M.apply(spec, ns)

	local aug = vim.api.nvim_create_augroup(name, { clear = true })
	local function sync()
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			if vim.bo[buf].filetype == "markdown" then
				vim.api.nvim_win_set_hl_ns(win, ns)
				vim.w[win][name] = true
			elseif vim.w[win][name] then
				vim.api.nvim_win_set_hl_ns(win, 0)
				vim.w[win][name] = nil
			end
		end
	end
	vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "BufEnter", "WinEnter" }, {
		group = aug,
		callback = sync,
	})
	sync()

	return aug
end

return M
