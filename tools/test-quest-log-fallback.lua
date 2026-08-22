local sourceFile = assert(io.open("EveryQuest/Everyquest.lua", "r"))
local source = sourceFile:read("*a")
sourceFile:close()

local questLogInfoSource = assert(source:match(
	"(local function getQuestLogInfo.-)\nlocal function getQuestLogQuestID"
))
local loader = assert(loadstring(questLogInfoSource .. "\nreturn getQuestLogInfo"))

local legacyCalls = 0
local environment = {
	C_QuestLog = {},
	GetQuestLogTitle = function(index)
		legacyCalls = legacyCalls + 1
		assert(index == 7)
		return "Data Rescue", 30, 0, false, false, 0, 1, 2930, false
	end,
}
setmetatable(environment, { __index = _G })
setfenv(loader, environment)

local getQuestLogInfo = loader()
local info = getQuestLogInfo(7)
assert(legacyCalls == 1, "legacy quest-log API must be used when C_QuestLog.GetInfo is unavailable")
assert(info.title == "Data Rescue")
assert(info.isHeader == false, "isHeader must use GetQuestLogTitle return value 4")
assert(info.isComplete == 0, "isComplete must use GetQuestLogTitle return value 6")
assert(info.frequency == 1, "frequency must use GetQuestLogTitle return value 7")
assert(info.questID == 2930, "questID must use GetQuestLogTitle return value 8")

local nativeCalls = 0
environment.C_QuestLog.GetInfo = function(index)
	nativeCalls = nativeCalls + 1
	return { title = "Native", questID = index }
end
info = getQuestLogInfo(2962)
assert(nativeCalls == 1, "native quest-log API must remain preferred when available")
assert(legacyCalls == 1, "legacy quest-log API must not run when C_QuestLog.GetInfo is available")
assert(info.title == "Native" and info.questID == 2962)

print("Quest log fallback tests passed.")
