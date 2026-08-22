local sourcePath = "EveryQuest/Everyquest.lua"
local file = assert(io.open(sourcePath, "r"))
local source = file:read("*a")
file:close()

assert(
	source:find('qTag = self:QuestType%(quest%["t"%]%) or ""'),
	"UpdateButton must fall back to an empty tag for unknown quest types"
)

local questTypeChunk = assert(source:match("function EveryQuest:QuestType%(qtype%)(.-)\nend"))

local L = setmetatable({}, {
	__index = function(_, key)
		return key
	end,
})

local EveryQuest = {}
local loader = assert(loadstring("local L = ...; function EveryQuest:QuestType(qtype)" .. questTypeChunk .. "\nend"))
setfenv(loader, { EveryQuest = EveryQuest })
loader(L)

assert(EveryQuest:QuestType(1) == "G", "group quest type must keep its display tag")
assert(EveryQuest:QuestType(84) == "", "legacy quest type 84 must fall back to an empty display tag")
assert(EveryQuest:QuestType(9999) == "", "future unknown quest types must use an empty display tag")
