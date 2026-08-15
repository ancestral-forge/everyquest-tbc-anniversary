local EveryQuest = EveryQuest
local L = EveryQuest_Locale

function EveryQuest:CreateOptions()
	EveryQuest.options = {
		debug = function() EveryQuest:ToggleDebug() end,
	}
end

function EveryQuest:ToggleDebug()
	self.db.profile.debug = not self.db.profile.debug
	if self.db.profile.debug then
		self:Print("EveryQuest: debugging messages enabled")
	else
		self:Print("EveryQuest: debugging messages disabled")
	end
end

function EveryQuest:PrintUsage()
	self:Print(L["EveryQuest"] .. ": /everyquest, /everyquest debug")
end

function EveryQuest:HandleSlash(input)
	local command = string.lower((input or ""):match("^%s*(%S*)") or "")
	if command == "" then
		self:Toggle()
	elseif command == "debug" then
		self:ToggleDebug()
	elseif command == "help" or command == "?" then
		self:PrintUsage()
	else
		self:PrintUsage()
	end
end
