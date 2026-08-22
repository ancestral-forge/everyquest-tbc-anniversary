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

print("Quest type and unmapped history tests passed.")
