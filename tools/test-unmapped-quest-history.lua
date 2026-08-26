local sourceFile = assert(io.open("EveryQuest/Everyquest.lua", "r"))
local source = sourceFile:read("*a")
sourceFile:close()

EveryQuest = {}
EveryQuestData = {}
local harnessSessionVars = {}
rawset(_G, "zonemenu", {
	["Eastern Kingdoms"] = {
		{1537, "Ironforge"},
	},
	Kalimdor = {
		{15, "Dustwallow Marsh"},
	},
	Dungeons = {
		{2100, "Maraudon"},
	},
	Professions = {
		{-324, "First Aid"},
	},
})
rawset(_G, "sessionvars", harnessSessionVars)

local zoneSource = assert(source:match("(local function getZoneIDByCategory.-)\nlocal function rememberQuestContext"))
local contextSource = assert(source:match("(local function rememberQuestContext.-)\nlocal function reportRuntimeError"))
local metadataSource = assert(source:match("(local questMetadataFields.-)\nfunction EveryQuest:HydrateQuestHistoryForGroup"))
local historySource = assert(source:match("(function EveryQuest:GetHistoryByQuestID.-)\nlocal function getLoadedQuestDataByID"))
local loadedQuestSource = assert(source:match("(local function getLoadedQuestDataByID.-)\nfunction EveryQuest:SaveQuestHistoryByID"))
local saveSource = assert(source:match("(function EveryQuest:SaveQuestHistoryByID.-)\nfunction EveryQuest:AddQuestByID"))

local loader = assert(loadstring(table.concat({
	zoneSource,
	contextSource,
	metadataSource,
	historySource,
	"local function loadQuestDataAddon(addon) return EveryQuest:LoadQuestDataAddon(addon) end",
	loadedQuestSource,
	"local function getCurrentZoneSelection() return 'Kalimdor', {15, 'Dustwallow Marsh'} end",
	saveSource,
}, "\n")))
loader()

local function clearTable(target)
	for key in pairs(target) do
		target[key] = nil
	end
end

local function dungeonsData()
	return {
		Dungeons = {
			[2100] = {
				{id = 7070, n = "Shadowshard Fragments", l = 42, r = 39, s = 1, t = 81},
			},
		},
	}
end

local function resetHarness(staticData)
	clearTable(harnessSessionVars)
	EveryQuest.db = {
		char = {
			history = {},
		},
	}
	EveryQuest.requestFrameUpdates = 0
	function EveryQuest:RequestFrameUpdate()
		self.requestFrameUpdates = self.requestFrameUpdates + 1
	end
	function EveryQuest:LoadQuestDataAddon()
		return false
	end
	EveryQuestData = staticData or {}
end

resetHarness()
local savedQuestID, zoneid = EveryQuest:SaveQuestHistoryByID(7070, nil, -1)
assert(savedQuestID == false and zoneid == nil, "unmapped quest events must wait for a real zone mapping")
assert(next(EveryQuest.db.char.history) == nil, "unmapped quest events must not fall back to the current zone")
assert(EveryQuest.requestFrameUpdates == 0, "unmapped quest events must not refresh history UI")

resetHarness()
savedQuestID, zoneid = EveryQuest:SaveQuestHistoryByID(11134, "Dustwallow Marsh", 0, "The End of the Deserters", false, 37)
assert(savedQuestID == 11134 and zoneid == 15)
assert(EveryQuest.db.char.history[15][11134].n == "The End of the Deserters")
assert(EveryQuest.db.char.history[15][11134].l == 37)
assert(EveryQuest.db.char.history[15][11134].status == 0)
EveryQuest.db.char.history[15][11134].d = 1
local _, _, savedDaily, _, changed = EveryQuest:SaveQuestHistoryByID(11134, "Dustwallow Marsh", 0, "The End of the Deserters", false, 37)
assert(savedDaily == nil, "confirmed non-daily quest-log context must clear stale daily flags")
assert(changed == true, "clearing a stale daily flag must count as a history change")
assert(EveryQuest.db.char.history[15][11134].status == 0, "daily cleanup must preserve quest status")

resetHarness()
function EveryQuest:LoadQuestDataAddon(addon)
	assert(addon ~= "EveryQuest_Kalimdor", "canonical lookup must find profession quests before loading continent fallbacks")
	if addon == "EveryQuest_Professions" then
		EveryQuestData.Professions = {
			[-324] = {
				{id = 6625, n = "Alliance Trauma", l = 45, r = 35, s = 1},
			},
		}
		return true
	end
	return false
end
EveryQuest.db.char.history[1537] = {
	[6625] = {
		id = 6625,
		n = "Alliance Trauma",
		s = 1,
		status = 0,
	},
}
savedQuestID, zoneid = EveryQuest:SaveQuestHistoryByID(6625, "Ironforge", 0, "Alliance Trauma", false, 45)
assert(savedQuestID == 6625 and zoneid == -324, "static profession data must override a misleading Ironforge quest-log header")
assert(EveryQuest.db.char.history[1537][6625] == nil, "canonical remap must remove misplaced Ironforge history")
local allianceTrauma = EveryQuest.db.char.history[-324][6625]
assert(allianceTrauma.n == "Alliance Trauma" and allianceTrauma.l == 45 and allianceTrauma.r == 35 and allianceTrauma.status == 0)

resetHarness()
function EveryQuest:LoadQuestDataAddon(addon)
	if addon == "EveryQuest_Professions" then
		EveryQuestData.Professions = {
			[-324] = {
				{id = 6625, n = "Alliance Trauma", l = 45, r = 35, s = 1},
			},
		}
		return true
	end
	return false
end
EveryQuest.db.char.history[1537] = {
	[6625] = {
		id = 6625,
		n = "Alliance Trauma",
		s = 1,
		status = 0,
		count = 1,
	},
}
assert(EveryQuest:ReconcileQuestHistoryForZone("Eastern Kingdoms", 1537) == 1, "opening Ironforge history must move already-saved profession quests")
assert(EveryQuest.db.char.history[1537][6625] == nil, "history render reconciliation must remove the old Ironforge entry")
allianceTrauma = EveryQuest.db.char.history[-324][6625]
assert(allianceTrauma.n == "Alliance Trauma" and allianceTrauma.l == 45 and allianceTrauma.r == 35)
assert(allianceTrauma.status == 0 and allianceTrauma.count == 1)
assert(EveryQuest:ReconcileQuestHistoryForZone("Eastern Kingdoms", 1537) == 0, "history render reconciliation must be idempotent")

resetHarness(dungeonsData())
savedQuestID, zoneid = EveryQuest:SaveQuestHistoryByID(7070, nil, 2)
assert(savedQuestID == 7070 and zoneid == 2100, "loaded static quest data must resolve the canonical zone")
local shadowshards = EveryQuest.db.char.history[2100][7070]
assert(shadowshards.n == "Shadowshard Fragments")
assert(shadowshards.l == 42 and shadowshards.r == 39 and shadowshards.s == 1 and shadowshards.t == 81)
assert(shadowshards.status == 2)

resetHarness(dungeonsData())
EveryQuest.db.char.history[15] = {
	[7070] = {
		id = 7070,
		n = "Quest 7070",
		s = 3,
		status = -1,
		abandoned = 1787344511,
	},
}
savedQuestID, zoneid = EveryQuest:SaveQuestHistoryByID(7070, nil, 2)
assert(savedQuestID == 7070 and zoneid == 2100, "loaded static quest data must move misplaced history")
assert(EveryQuest.db.char.history[15][7070] == nil)
shadowshards = EveryQuest.db.char.history[2100][7070]
assert(shadowshards.n == "Shadowshard Fragments")
assert(shadowshards.l == 42 and shadowshards.r == 39 and shadowshards.s == 1 and shadowshards.t == 81)
assert(shadowshards.status == 2 and shadowshards.abandoned == 1787344511)

print("Unmapped quest history tests passed.")
