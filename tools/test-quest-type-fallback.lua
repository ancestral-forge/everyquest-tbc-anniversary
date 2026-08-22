local sourceFile = assert(io.open("EveryQuest/Everyquest.lua", "r"))
local source = sourceFile:read("*a")
sourceFile:close()

EveryQuest = {}
_G.L = setmetatable({}, {
	__index = function(_, key)
		return key
	end,
})

local questTypeSource = assert(source:match("(function EveryQuest:QuestType.-\nend)\n"))
assert(loadstring(questTypeSource))()
local escortTag, escortName = EveryQuest:QuestType(84)
assert(escortTag == "E" and escortName == "Escort", "escort quest type 84 must have an explicit display tag")
assert(EveryQuest:QuestType(9999) == "", "future unknown quest types must use an empty display tag")

local updateButtonSource = assert(source:match("(function EveryQuest:UpdateButton.-)\nfunction EveryQuest:ButtonEnter"))
assert(updateButtonSource:find('self:QuestType%(quest%["t"%]%) or ""'), "renderer must guard QuestType results")

print("Quest type fallback test passed.")
