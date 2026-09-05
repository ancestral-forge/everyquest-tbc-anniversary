EveryQuest = EveryQuest or {}
local EveryQuest = EveryQuest

local QuestStore = {}
QuestStore.__index = QuestStore

local questMetadataFields = {"id", "n", "l", "r", "s", "t", "d"}

function QuestStore:Create(historyRoot)
	return setmetatable({historyRoot = historyRoot or {}}, QuestStore)
end

function QuestStore:SetHistoryRoot(historyRoot)
	self.historyRoot = historyRoot or {}
	return self
end

function QuestStore:CreateHistoryRecord(quest)
	local history = {}
	for _, field in ipairs(questMetadataFields) do
		if quest and quest[field] ~= nil then
			history[field] = quest[field]
		end
	end
	return history
end

function QuestStore:EnsureHistoryRecord(questID, context)
	questID = tonumber(questID)
	context = context or {}
	local zoneID = context.zoneID
	if not questID or zoneID == nil or type(self.historyRoot) ~= "table" then
		return nil, false
	end

	local zoneHistory = self.historyRoot[zoneID]
	if type(zoneHistory) ~= "table" then
		zoneHistory = {}
		self.historyRoot[zoneID] = zoneHistory
	end

	local history = zoneHistory[questID]
	if type(history) == "table" then
		return history, false
	end

	history = self:CreateHistoryRecord(context.quest)
	history.id = questID
	if history.n == nil then
		history.n = context.title or ("Quest " .. questID)
	end
	if history.s == nil then
		history.s = context.source or 3
	end
	zoneHistory[questID] = history
	return history, true
end

function QuestStore:RemoveHistoryRecord(questID, zoneID)
	questID = tonumber(questID)
	local zoneHistory = zoneID ~= nil and self.historyRoot and self.historyRoot[zoneID]
	if not questID or type(zoneHistory) ~= "table" or zoneHistory[questID] == nil then
		return false
	end
	zoneHistory[questID] = nil
	return true
end

EveryQuest.QuestStore = QuestStore:Create()
