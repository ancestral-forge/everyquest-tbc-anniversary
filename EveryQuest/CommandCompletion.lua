local EveryQuest = EveryQuest
local RANGE_HINT = "discover <first> <last> (decimal IDs, at most 100000 per run)"

-- Pure completion: never dispatch a command or fabricate numeric arguments.
function EveryQuest:CompleteCommandText(text)
	local root, rest = text:match("^(%S+)(.*)$")
	if not root or root:lower() ~= "/everyquest" then return false end
	if rest == "" then return true, text .. " " end
	local prefix, partial = text:match("^(.*%s)(%S*)$")
	local words = {}
	for word in prefix:gmatch("%S+") do words[#words + 1] = word:lower() end
	local candidates, hint
	if #words == 1 then
		candidates = {"api", "debug", "help"}
	elseif #words == 2 and words[2] == "api" then
		candidates = {"audit", "discover", "overlay"}
	elseif #words == 3 and words[2] == "api" and (words[3] == "audit" or words[3] == "discover") then
		candidates = {"status", "cancel", "clear"}
		if words[3] == "discover" then hint = RANGE_HINT end
	elseif words[2] == "api" and words[3] == "discover" and words[4] and words[4]:match("^%d+$") then
		return true, nil, RANGE_HINT
	else
		return false
	end
	local matches = {}
	partial = partial:lower()
	for _, candidate in ipairs(candidates) do
		if candidate:sub(1, #partial) == partial then matches[#matches + 1] = candidate end
	end
	if #matches == 1 then return true, prefix .. matches[1] .. " " end
	if #matches > 1 then
		return true, nil, table.concat(matches, ", ") .. (hint and ("; " .. hint) or "")
	end
	if hint then return true, nil, hint end
	return false
end

-- Blizzard's dedicated addon extension returns true to suppress default Tab.
-- Chain it rather than replacing chat scripts, secure handlers or key bindings.
local previous = _G.ChatEdit_CustomTabPressed
if type(previous) == "function" then
	_G.ChatEdit_CustomTabPressed = function(editBox, ...)
		local text = editBox:GetText()
		if editBox:GetCursorPosition() == #text then
			local handled, replacement, hint = EveryQuest:CompleteCommandText(text)
			if handled then
				if replacement then
					editBox:SetText(replacement)
					editBox:ClearHighlightText()
					editBox:SetCursorPosition(#replacement)
				elseif hint then
					EveryQuest:Print("EveryQuest: " .. hint)
				end
				return true
			end
		end
		return previous(editBox, ...)
	end
else
	EveryQuest:Print("EveryQuest: chat Tab extension unavailable; type commands manually.")
end
