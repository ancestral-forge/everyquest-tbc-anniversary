local sourceFile = assert(io.open("EveryQuest/Everyquest.lua", "r"))
local source = sourceFile:read("*a")
sourceFile:close()

local questLogInfoSource = assert(source:match(
	"(local function getQuestLogInfo.-)\nfunction EveryQuest:RequestFrameUpdate"
))
local loader = assert(loadstring(questLogInfoSource .. "\nreturn getQuestLogInfo, isQuestLogInfoDaily"))

local legacyCalls = 0
local legacyFrequency = 1
local environment = {
	C_QuestLog = {},
	Enum = {
		QuestFrequency = {
			Daily = 1,
		},
	},
	LE_QUEST_FREQUENCY_DAILY = 2,
	GetQuestLogTitle = function(index)
		legacyCalls = legacyCalls + 1
		assert(index == 7)
		return "Data Rescue", 30, 0, false, false, 0, legacyFrequency, 2930, false
	end,
}
environment._G = environment
setmetatable(environment, { __index = _G })
setfenv(loader, environment)

local getQuestLogInfo, isQuestLogInfoDaily = loader()
local info = getQuestLogInfo(7)
assert(legacyCalls == 1, "legacy quest-log API must be used when C_QuestLog.GetInfo is unavailable")
assert(info.title == "Data Rescue")
assert(info.level == 30, "level must use GetQuestLogTitle return value 2")
assert(info.isHeader == false, "isHeader must use GetQuestLogTitle return value 4")
assert(info.isComplete == 0, "isComplete must use GetQuestLogTitle return value 6")
assert(info.frequency == 1, "frequency must use GetQuestLogTitle return value 7")
assert(info.questID == 2930, "questID must use GetQuestLogTitle return value 8")
assert(info.usesLegacyFrequency == true, "legacy frequency values must be marked")
assert(isQuestLogInfoDaily(info) == false, "legacy normal frequency 1 must not be treated as daily")

legacyFrequency = 2
info = getQuestLogInfo(7)
assert(isQuestLogInfoDaily(info) == true, "legacy daily frequency 2 must be treated as daily")

local nativeCalls = 0
environment.C_QuestLog.GetInfo = function(index)
	nativeCalls = nativeCalls + 1
	return { title = "Native", questID = index, level = 30, frequency = 1 }
end
info = getQuestLogInfo(2962)
assert(nativeCalls == 1, "native quest-log API must remain preferred when available")
assert(legacyCalls == 2, "legacy quest-log API must not run when C_QuestLog.GetInfo is available")
assert(info.title == "Native" and info.questID == 2962)
assert(isQuestLogInfoDaily(info) == true, "native daily enum must be treated as daily")

print("Quest log fallback tests passed.")
