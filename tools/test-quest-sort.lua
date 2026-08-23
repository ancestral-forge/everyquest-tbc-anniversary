local sourceFile = assert(io.open("EveryQuest/Everyquest.lua", "r"))
local source = sourceFile:read("*a")
sourceFile:close()

local sortTableSource = assert(source:match(
	"(function EveryQuest:SortTable.-)\nfunction EveryQuest:UpdateButton"
))
local loader = assert(loadstring(table.concat({
	"local EveryQuest = ...",
	sortTableSource,
	"return EveryQuest",
}, "\n")))

local EveryQuest = {}
loader(EveryQuest)

local function quest(name, level, questType, daily)
	return {n = name, l = level, t = questType, d = daily}
end

local groupQuest = quest("Group Quest", 20, 1)
local raidQuest = quest("Raid Quest", 20, 62)
local untypedQuest = quest("Untyped Quest", 20)

assert(EveryQuest:SortTable(groupQuest, raidQuest) == true, "lower quest type must sort first")
assert(EveryQuest:SortTable(raidQuest, groupQuest) == false, "higher quest type must sort last")
assert(EveryQuest:SortTable(groupQuest, untypedQuest) == true, "typed quest must sort before untyped quest")
assert(EveryQuest:SortTable(untypedQuest, groupQuest) == false, "untyped quest must sort after typed quest")

local history = {
	[101] = groupQuest,
	[102] = raidQuest,
}
assert(EveryQuest:SortTable(101, 102, history) == true, "history must use forward type ordering")
assert(EveryQuest:SortTable(102, 101, history) == false, "history must use reverse type ordering")

assert(
	EveryQuest:SortTable(quest("Normal", 20, 1, 1), quest("Daily", 20, 1, 2)) == false,
	"daily ordering must remain unchanged"
)
assert(
	EveryQuest:SortTable(quest("Higher", 21, 1), quest("Lower", 20, 1)) == true,
	"higher-level quests must continue to sort first"
)
assert(
	EveryQuest:SortTable(quest("Alpha", 20, 1), quest("Beta", 20, 1)) == true,
	"equal-level quests must continue to sort alphabetically"
)

print("Quest sort comparator test passed.")
