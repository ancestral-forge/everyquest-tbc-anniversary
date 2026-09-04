EveryQuest = {}
dofile("EveryQuest/QuestStore.lua")

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

historyRoot[16] = {
	[200] = {
		id = 200,
		n = "Existing Quest",
		s = 3,
		status = -1,
		failed = 67890,
	},
}
local legacy, legacyAdded = store:EnsureHistoryRecord(200, {
	zoneID = 16,
	quest = {id = 200, n = "Replacement"},
})
assert(legacyAdded == false)
assert(legacy.n == "Existing Quest" and legacy.status == -1 and legacy.failed == 67890)

assert(store:RemoveHistoryRecord(100, 15) == true)
assert(historyRoot[15][100] == nil)
assert(store:RemoveHistoryRecord(100, 15) == false)

print("Quest store tests passed.")
