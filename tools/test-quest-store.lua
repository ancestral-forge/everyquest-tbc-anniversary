EveryQuest = {}
dofile("EveryQuest/QuestStore.lua")

local function assertSame(actual, expected, message)
	assert(actual == expected, message or (tostring(actual) .. " ~= " .. tostring(expected)))
end

local historyRoot = {}
local store = EveryQuest.QuestStore:Create(historyRoot)
local staticQuest = {
	id = 100,
	n = "Foundation Quest",
	l = 20,
	r = 18,
	s = 1,
	t = 81,
	d = 1,
	p = 4,
	relations = {followUps = {101}},
	nextQuestInChain = 101,
}

local history, added = store:EnsureHistoryRecord(100, {
	zoneID = 15,
	quest = staticQuest,
})

assert(added == true)
assert(history ~= staticQuest, "history must not alias the static quest table")
for _, field in ipairs({"id", "n", "l", "r", "s", "t", "d"}) do
	assert(history[field] == staticQuest[field], "history must copy the flat metadata whitelist")
end
assert(history.p == nil, "phase metadata must remain static-only")
assert(history.relations == nil, "relationship tables must not enter character history")
assert(history.nextQuestInChain == nil, "legacy relationship fields must not enter character history")

history.status = 2
history.completed = 12345
assert(staticQuest.status == nil and staticQuest.completed == nil, "history progress must not mutate static data")

local existing, addedAgain = store:EnsureHistoryRecord(100, {
	zoneID = 15,
	quest = staticQuest,
})
assert(existing == history and addedAgain == false, "ensure must preserve an existing history record")
assert(existing.status == 2 and existing.completed == 12345)

history.d = 1
assert(store:ApplyStaticHistoryMetadata(history, {
	id = 100,
	n = "Updated Foundation Quest",
	l = 21,
	s = 1,
	p = 5,
	relations = {followUps = {102}},
}) == true)
assert(history.n == "Updated Foundation Quest" and history.l == 21)
assert(history.d == nil, "hydration must clear a stale daily flag")
assert(history.p == nil and history.relations == nil, "hydration must use the persisted whitelist")
assert(history.status == 2 and history.completed == 12345, "hydration must preserve progress")

local fallback = store:EnsureHistoryRecord(101, {
	zoneID = 16,
	quest = {id = 101, n = "Faction Fallback"},
	faction = 1,
	source = 2,
})
assert(fallback.s == 1, "the faction fallback must not consume provider source provenance")

local oldRecord = {id = 200, n = "Old Root"}
store:SetHistoryRoot({[30] = {[200] = oldRecord}})
assertSame(store:GetHistory(200), oldRecord)
local replacementRecord = {id = 200, n = "Replacement Root"}
store:SetHistoryRoot({[40] = {[200] = replacementRecord}})
local rebound, reboundZone = store:GetHistory(200)
assertSame(rebound, replacementRecord, "history root replacement must discard old references")
assertSame(reboundZone, 40)
assert(rebound ~= oldRecord)

local duplicateA = {id = 300, n = "Later Zone"}
local duplicateB = {id = 300, n = "Earlier Zone"}
local duplicateRoot = {
	[30] = {[300] = duplicateA},
	[10] = {[300] = duplicateB},
}
store:SetHistoryRoot(duplicateRoot)
local primary, primaryZone = store:GetHistory(300)
assertSame(primary, duplicateB, "primary history selection must be deterministic")
assertSame(primaryZone, 10)
assertSame(store:GetHistory(300, 30), duplicateA, "an exact history zone hint must win")
assert(#store:GetHistoryOccurrences(300) == 2, "duplicate saved locations must remain indexed")

local classQuest = {id = 400, n = "Class Copy", p = 4}
local dungeonQuest = {id = 400, n = "Dungeon Copy", p = 4}
local classData = {[100] = {classQuest}}
local dungeonData = {[200] = {dungeonQuest}}
local groupOrder = {"Classes", "Dungeons", "Eastern Kingdoms"}

local firstOrder = EveryQuest.QuestStore:Create({}, {groupOrder = groupOrder})
assert(firstOrder:RegisterGroup("Dungeons", dungeonData) == true)
assert(firstOrder:RegisterGroup("Classes", classData) == true)
assert(firstOrder:RegisterGroup("Classes", classData) == false, "group registration must be idempotent")
assert(#firstOrder:GetStaticOccurrences(400) == 2, "every static occurrence must be retained")
local selected, selectedGroup, selectedZone = firstOrder:GetStaticQuest(400)
assertSame(selected, classQuest, "canonical precedence must beat registration order")
assertSame(selectedGroup, "Classes")
assertSame(selectedZone, 100)
assertSame(firstOrder:GetStaticQuest(400, "Dungeons"), dungeonQuest, "an exact group hint must win")
assertSame(firstOrder:GetStaticQuest(400, "Dungeons", 200), dungeonQuest, "exact group and zone hints must win")
assertSame(firstOrder:GetStaticQuest(400, nil, 200), dungeonQuest, "an exact zone hint must win")
local locationGroup, locationZone, locationQuest = firstOrder:GetQuestLocation(400)
assertSame(locationGroup, "Classes")
assertSame(locationZone, 100)
assertSame(locationQuest, classQuest)

local secondOrder = EveryQuest.QuestStore:Create({}, {groupOrder = groupOrder})
secondOrder:RegisterGroup("Classes", classData)
secondOrder:RegisterGroup("Dungeons", dungeonData)
assertSame(secondOrder:GetStaticQuest(400), classQuest, "opposite registration order must select the same occurrence")

local autoRoot = {}
local autoLocation = EveryQuest.QuestStore:Create(autoRoot, {groupOrder = groupOrder})
autoLocation:RegisterGroup("Classes", classData)
local autoHistory, autoAdded = autoLocation:EnsureHistoryRecord(400, {groupHint = "Classes"})
assert(autoAdded == true and autoRoot[100][400] == autoHistory, "ensure must use the selected static location")
assert(autoHistory.n == "Class Copy" and autoHistory.p == nil)

local loaderCalls = {}
local loaderLog = {}
local loadableData = {
	Dungeons = {[201] = {{id = 500, n = "Hinted Dungeon"}}},
	Classes = {[101] = {{id = 600, n = "Fallback Class"}}},
	["Eastern Kingdoms"] = {[12] = {}},
}
local indexed = EveryQuest.QuestStore:Create({}, {
	groupOrder = groupOrder,
	loader = function(group)
		loaderCalls[group] = (loaderCalls[group] or 0) + 1
		table.insert(loaderLog, group)
		return loadableData[group]
	end,
})

local hinted = indexed:GetStaticQuest(500, "Dungeons", 201)
assertSame(hinted, loadableData.Dungeons[201][1])
assertSame(loaderCalls.Dungeons, 1, "a successful hinted group must load once")
assertSame(indexed:GetStaticQuest(500, "Dungeons", 201), hinted)
assertSame(loaderCalls.Dungeons, 1, "an indexed hit must not call the loader again")

loaderLog = {}
local fallbackQuest, fallbackGroup, fallbackZone = indexed:GetStaticQuest(600, "Eastern Kingdoms", 12)
assertSame(loaderLog[1], "Eastern Kingdoms", "the explicit hint must load before ordered fallback")
assertSame(fallbackQuest, loadableData.Classes[101][1])
assertSame(fallbackGroup, "Classes")
assertSame(fallbackZone, 101)
assertSame(loaderCalls.Classes, 1)
assertSame(indexed:GetStaticQuest(600), fallbackQuest)
assertSame(loaderCalls.Classes, 1, "successful fallback groups must remain indexed")

local unknownStore = EveryQuest.QuestStore:Create({}, {
	groupOrder = groupOrder,
	loader = function(group)
		return loadableData[group]
	end,
})
local unknownQuest, unknownGroup, unknownZone = unknownStore:GetStaticQuest(999999)
assert(unknownQuest == nil and unknownGroup == nil and unknownZone == nil, "unknown IDs must not invent a static location")

local misplaced = {
	id = 700,
	n = "Misplaced",
	status = -3,
	count = 2,
	abandoned = 77,
	legacy = "preserve",
}
local canonical = {id = 700, n = "Canonical"}
local moveRoot = {
	[90] = {[700] = misplaced},
	[20] = {[700] = canonical},
}
local moveStore = EveryQuest.QuestStore:Create(moveRoot, {groupOrder = groupOrder})
local canonicalStatic = {id = 700, n = "Static Canonical", l = 30, s = 3}
moveStore:RegisterGroup("Dungeons", {[20] = {canonicalStatic}})
assert(#moveStore:GetHistoryOccurrences(700) == 2)
local merged, mergedZone, moved = moveStore:MoveHistoryToCanonicalLocation(700)
assertSame(merged, canonical, "an existing canonical record must remain the merge target")
assertSame(mergedZone, 20)
assert(moved == true)
assert(merged.status == -3 and merged.count == 2 and merged.abandoned == 77)
assert(merged.legacy == "preserve", "compatible legacy metadata must survive the merge")
assert(moveRoot[90][700] == nil, "all stale saved locations must be removed")
assert(#moveStore:GetHistoryOccurrences(700) == 1)
assertSame(moveStore:GetHistory(700), merged)
local mergedAgain, sameZone, movedAgain = moveStore:MoveHistoryToCanonicalLocation(700)
assertSame(mergedAgain, merged)
assertSame(sameZone, 20)
assert(movedAgain == false, "canonical reconciliation must be idempotent")

assert(moveStore:RemoveHistoryRecord(700, 20) == true)
assert(moveRoot[20][700] == nil)
assert(moveStore:GetHistory(700) == nil, "history removal must evict the runtime index")
assert(moveStore:RemoveHistoryRecord(700, 20) == false)

print("Quest store tests passed.")
