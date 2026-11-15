-- pandoc/filters/wikilinks.lua

-- Handles Obsidian-style [[wikilinks]] during Pandoc conversion.
--
-- [[Note]] and [[Note|alias]] are converted to their visible text instead of
-- remaining links. A link to an Obsidian note would otherwise point to a
-- destination that generally does not exist in the exported PDF.
--
-- Image embeds such as ![[image.png]] are handled earlier by
-- lua/modules/pandoc.lua, which rewrites them as ordinary Markdown images
-- because Pandoc does not parse Obsidian image embeds reliably.

---Determine whether a Pandoc link represents an Obsidian wikilink.
---Both the `wikilink` title and class are accepted for compatibility with
---different Pandoc versions.
---@param el pandoc.Link Link element supplied by Pandoc.
---@return boolean `true` when the link is an Obsidian wikilink.
local function is_wikilink(el)
	return el.title == "wikilink" or el.classes:includes("wikilink")
end

---Replace an Obsidian wikilink with its visible inline content.
---When no alias is given, an anchor such as `#section` is stripped from the
---visible text, since a heading the PDF does not contain reads as noise.
---Returning nil for ordinary links leaves them unchanged.
---@param el pandoc.Link Link element supplied by Pandoc.
---@return pandoc.Inline[]|nil Visible link content, or nil to keep the link.
function Link(el)
	if is_wikilink(el) then
		local content = el.content
		-- An alias already replaces the target, so only the bare `[[Note#x]]`
		-- form, whose content equals the link target, needs trimming. When the
		-- target starts with `#` there is nothing left, so the link keeps
		-- its content.
		local target = el.target
		if target and target:find("#", 1, true) and pandoc.utils.stringify(content) == target then
			local stripped = target:match("^[^#]*")
			if stripped ~= "" then
				content = pandoc.Inlines({ pandoc.Str(stripped) })
			end
		end
		return content
	end
end
