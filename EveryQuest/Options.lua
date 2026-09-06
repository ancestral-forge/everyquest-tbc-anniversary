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
	local command, arguments = (input or ""):match("^%s*(%S*)%s*(.-)%s*$")
	command = string.lower(command or "")
	if command == "" then
		self:Toggle()
	elseif command == "debug" then
		self:ToggleDebug()
	elseif command == "api" then
		local action, rest = arguments:match("^(%S*)%s*(.-)%s*$")
		action = string.lower(action or "")
		if action == "audit" then
			self:HandleQuestApiAuditCommand(rest)
		elseif action == "discover" then
			self:HandleQuestApiDiscoveryCommand(rest)
		elseif action == "overlay" and rest == "" then
			self:ToggleQuestApiOverlay()
		else
			self:Print("EveryQuest: /everyquest api audit | discover <first> <last> | overlay")
		end
	elseif command == "help" or command == "?" then
		self:PrintUsage()
	else
		self:PrintUsage()
	end
end
