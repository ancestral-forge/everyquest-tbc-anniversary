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

print("Quest type fallback test passed.")
