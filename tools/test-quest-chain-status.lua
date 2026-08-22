local sourceFile = assert(io.open("EveryQuest/Everyquest.lua", "r"))
local source = sourceFile:read("*a")
sourceFile:close()

local statusSource = assert(source:match(
	"(local function getStoredQuestStatus.-)\nlocal function loadQuestDataAddon"
))
local loader = assert(loadstring(statusSource .. [[
return getNextQuestInChainID, isQuestUnavailable, getDisplayedQuestStatus, addQuestStatusLabel
]]))

local histories = {}
local completed = {}
local chain = {[100] = 101}
local queryCalls = 0
local EveryQuest = {}

function EveryQuest:GetHistoryByQuestID(questid)
	return histories[questid]
end

local locale = setmetatable({}, {__index = function(_, key) return key end})
local environment = {
	EveryQuest = EveryQuest,
	L = locale,
	UnitLevel = function() return 70 end,
	isQuestFlaggedCompleted = function(questid) return completed[questid] == true end,
	_G = {
		QuestieLoader = {
			ImportModule = function(_, moduleName)
				assert(moduleName == "QuestieDB")
				return {
					QueryQuestSingle = function(questid, field)
						queryCalls = queryCalls + 1
						assert(field == "nextQuestInChain")
						return chain[questid]
					end,
				}
			end,
		},
	},
}
setmetatable(environment, {__index = _G})
setfenv(loader, environment)

local getNextQuestInChainID, isQuestUnavailable, getDisplayedQuestStatus, addQuestStatusLabel = loader()
local firstQuest = {id = 100, n = "First Quest", r = 1}

assert(getNextQuestInChainID(firstQuest) == 101)
assert(getNextQuestInChainID(firstQuest) == 101)
assert(queryCalls == 1, "chain relationships must be cached")
assert(not isQuestUnavailable(firstQuest), "an untouched next quest must not hide the current quest")

histories[101] = {id = 101, status = 0}
assert(isQuestUnavailable(firstQuest), "an active next quest must make the skipped quest unavailable")
assert(getDisplayedQuestStatus(firstQuest) == -2, "automatic Unavailable must be displayed")

local manualCurrentStatus = {id = 100, status = 1}
assert(
	getDisplayedQuestStatus(firstQuest, manualCurrentStatus) == 1,
	"a manual status must override automatic Unavailable"
)

histories[101] = nil
completed[101] = true
assert(isQuestUnavailable(firstQuest), "a completed next quest must make the skipped quest unavailable")

assert(addQuestStatusLabel("[10] First Quest", -3) == "[10] First Quest (Abandoned)")
assert(addQuestStatusLabel("[10] First Quest", -1) == "[10] First Quest (Failed)")
assert(addQuestStatusLabel("[10] First Quest", -2) == "[10] First Quest")

local embeddedQuest = {id = 200, nextQuestInChain = 201, r = 1}
histories[201] = {id = 201, status = 2}
assert(getNextQuestInChainID(embeddedQuest) == 201, "embedded chain data must work without Questie")
assert(isQuestUnavailable(embeddedQuest))

environment._G.QuestieLoader = nil
local unrelatedQuest = {id = 300, r = 1}
assert(not isQuestUnavailable(unrelatedQuest), "missing optional chain data must fail open")

print("Quest chain status tests passed.")
