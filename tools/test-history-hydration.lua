local sourceFile = assert(io.open("EveryQuest/Everyquest.lua", "r"))
local source = sourceFile:read("*a")
sourceFile:close()

EveryQuest = {}
EveryQuestData = {}

local hydrationSource = assert(source:match("(local questMetadataFields.-)\nfunction EveryQuest:SyncCompletedQuestFlagsForGroup"))
assert(loadstring(hydrationSource))()

EveryQuest.db = {
	char = {
		history = {
			[15] = {
				[11134] = {
					id = 11134,
					n = "Quest 11134",
					s = 3,
					status = -1,
					abandoned = 1787389502,
				},
				[11137] = {
					id = 11137,
					n = "Quest 11137",
					s = 3,
					status = -1,
					failed = 1787383289,
					count = 2,
				},
				[7070] = {
					id = 7070,
					n = "Quest 7070",
					s = 3,
					status = -1,
					abandoned = 1787344511,
				},
			},
		},
	},
}

EveryQuestData.Kalimdor = {
	[15] = {
		{id = 11134, n = "The End of the Deserters", l = 37, r = 32, s = 1},
		{id = 11137, n = "Defias in Dustwallow?", l = 37, r = 32, s = 1},
	},
}
EveryQuestData.Dungeons = {
	[2100] = {
		{id = 7070, n = "Shadowshard Fragments", l = 42, r = 39, s = 1, t = 81},
	},
}

assert(EveryQuest:HydrateQuestHistoryForGroup("Kalimdor") == 2)

local deserters = EveryQuest.db.char.history[15][11134]
assert(deserters.n == "The End of the Deserters")
assert(deserters.l == 37 and deserters.r == 32 and deserters.s == 1)
assert(deserters.status == -1 and deserters.abandoned == 1787389502)

local defias = EveryQuest.db.char.history[15][11137]
assert(defias.n == "Defias in Dustwallow?")
assert(defias.l == 37 and defias.r == 32 and defias.s == 1)
assert(defias.status == -1 and defias.failed == 1787383289 and defias.count == 2)

local misplaced = EveryQuest.db.char.history[15][7070]
assert(misplaced.n == "Quest 7070" and misplaced.l == nil and misplaced.s == 3)
assert(misplaced.status == -1 and misplaced.abandoned == 1787344511)

assert(EveryQuest:HydrateQuestHistoryForGroup("Dungeons") == 1)
assert(EveryQuest.db.char.history[15][7070] == nil, "misplaced quest history must move out of Dustwallow")

local shadowshards = EveryQuest.db.char.history[2100][7070]
assert(shadowshards.n == "Shadowshard Fragments")
assert(shadowshards.l == 42 and shadowshards.r == 39 and shadowshards.s == 1 and shadowshards.t == 81)
assert(shadowshards.status == -1 and shadowshards.abandoned == 1787344511)

assert(EveryQuest:HydrateQuestHistoryForGroup("Kalimdor") == 0, "hydration must be idempotent")
assert(EveryQuest:HydrateQuestHistoryForGroup("Dungeons") == 0, "relocation must be idempotent")

print("History hydration tests passed.")
