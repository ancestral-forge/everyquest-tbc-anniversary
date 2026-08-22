local sourceFile = assert(io.open("EveryQuest/Everyquest.lua", "r"))
local source = sourceFile:read("*a")
sourceFile:close()

EveryQuest = {}
EveryQuestData = {}
_G.L = setmetatable({}, {
	__index = function(_, key)
		return key
	end,
})

local questTypeSource = assert(source:match("(function EveryQuest:QuestType.-\nend)\n"))
assert(loadstring(questTypeSource))()
assert(EveryQuest:QuestType(84) == "", "unknown quest types must use an empty display tag")

_G.getQuestContext = function() end
_G.rememberQuestContext = function() end
_G.getZoneIDByCategory = function() end

function EveryQuest:GetHistoryByQuestID() end
function EveryQuest:RequestFrameUpdate() end

EveryQuest.db = {char = {history = {}}}
local saveSource = assert(source:match("(function EveryQuest:SaveQuestHistoryByID.-\nend)\n\nfunction EveryQuest:AddQuestByID"))
assert(loadstring(saveSource))()

local questid, zoneid = EveryQuest:SaveQuestHistoryByID(7070, nil, -1)
assert(questid == 7070 and zoneid == "unmapped", "unknown quests must not use the current zone")
assert(EveryQuest.db.char.history.unmapped[7070].status == -1, "unmapped quests must retain runtime status")

local hydrationSource = assert(source:match("(local questMetadataFields.-)\nfunction EveryQuest:SyncCompletedQuestFlagsForGroup"))
assert(loadstring(hydrationSource))()

EveryQuest.db.char.history = {
	[15] = {
		[11123] = {id = 11123, n = "Quest 11123", s = 3, status = 2, count = 4},
		[7070] = {id = 7070, n = "Quest 7070", s = 3, status = -1},
	},
	unmapped = {
		[11134] = {id = 11134, n = "Quest 11134", s = 3, status = 1},
	},
}

function EveryQuest:GetHistoryByQuestID(lookupQuestID)
	for historyZoneID, quests in pairs(self.db.char.history) do
		if type(quests) == "table" and quests[lookupQuestID] then
			return quests[lookupQuestID], historyZoneID
		end
	end
end

EveryQuestData.Kalimdor = {
	[15] = {
		{id = 11123, n = "Inspecting the Ruins", l = 35, r = 30, s = 1},
		{id = 11134, n = "The End of the Deserters", l = 37, r = 32, s = 1},
	},
}

local hydrated, moved = EveryQuest:HydrateQuestHistoryForGroup("Kalimdor")
assert(hydrated == 2, "both matching history records must be hydrated")
assert(moved == 2, "unmapped and misplaced records must move out of their old buckets")

local inspecting = EveryQuest.db.char.history[15][11123]
assert(inspecting.n == "Inspecting the Ruins" and inspecting.l == 35 and inspecting.r == 30 and inspecting.s == 1)
assert(inspecting.status == 2 and inspecting.count == 4, "runtime completion fields must survive hydration")

local deserters = EveryQuest.db.char.history[15][11134]
assert(deserters.n == "The End of the Deserters" and deserters.l == 37 and deserters.status == 1)
assert(EveryQuest.db.char.history.unmapped[11134] == nil, "hydrated records must leave the unmapped bucket")

local maraudon = EveryQuest.db.char.history.unmapped[7070]
assert(maraudon and maraudon.status == -1, "wrong-zone placeholders must be quarantined without losing runtime state")
assert(EveryQuest.db.char.history[15][7070] == nil, "wrong-zone placeholders must not remain in the current zone")

print("Quest type, unmapped history, and hydration tests passed.")
