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

local function questieLoaderReturning(result)
	return {
		ImportModule = function()
			return {
				QueryQuestSingle = function()
					return result
				end,
			}
		end,
	}
end

environment._G.QuestieLoader = false
assert(getNextQuestInChainID({id = 301}) == nil, "a disabled Questie loader must fail open")

environment._G.QuestieLoader = "invalid loader"
assert(getNextQuestInChainID({id = 302}) == nil, "a non-table Questie loader must fail open")

environment._G.QuestieLoader = {
	ImportModule = function()
		error("Questie import failure")
	end,
}
assert(getNextQuestInChainID({id = 303}) == nil, "a Questie import error must fail open")
environment._G.QuestieLoader = questieLoaderReturning(304)
assert(getNextQuestInChainID({id = 303}) == 304, "a Questie import error must not be cached")

environment._G.QuestieLoader = {ImportModule = function() return "invalid module" end}
assert(getNextQuestInChainID({id = 305}) == nil, "a non-table Questie module must fail open")

environment._G.QuestieLoader = {ImportModule = function() return {QueryQuestSingle = true} end}
assert(getNextQuestInChainID({id = 306}) == nil, "a non-function Questie query must fail open")

environment._G.QuestieLoader = {
	ImportModule = function()
		return {
			QueryQuestSingle = function()
				error("Questie query failure")
			end,
		}
	end,
}
assert(getNextQuestInChainID({id = 307}) == nil, "a Questie query error must fail open")
environment._G.QuestieLoader = questieLoaderReturning(308)
assert(getNextQuestInChainID({id = 307}) == 308, "a Questie query error must not be cached")

local retryResult
environment._G.QuestieLoader = {
	ImportModule = function()
		return {
			QueryQuestSingle = function()
				return retryResult
			end,
		}
	end,
}
assert(getNextQuestInChainID({id = 309}) == nil, "a nil Questie answer must fail open")
retryResult = 310
assert(getNextQuestInChainID({id = 309}) == 310, "a nil Questie answer must not be cached")

local invalidQuestIDs = {
	"308",
	{},
	false,
	0,
	-1,
	1.5,
	0 / 0,
	math.huge,
	16777216,
}
for index, invalidQuestID in ipairs(invalidQuestIDs) do
	environment._G.QuestieLoader = questieLoaderReturning(invalidQuestID)
	assert(
		getNextQuestInChainID({id = 400 + index}) == nil,
		"garbage and out-of-range Questie IDs must fail open"
	)
end

environment._G.QuestieLoader = questieLoaderReturning(501)
assert(getNextQuestInChainID({id = "500"}) == nil, "the current quest ID must also be validated")
assert(getNextQuestInChainID({id = 500.5}) == nil, "fractional current quest IDs must be rejected")

local garbageThenValid = {}
environment._G.QuestieLoader = {
	ImportModule = function()
		return {
			QueryQuestSingle = function()
				return garbageThenValid[1]
			end,
		}
	end,
}
garbageThenValid[1] = "invalid"
assert(getNextQuestInChainID({id = 600}) == nil, "a garbage Questie answer must fail open")
garbageThenValid[1] = 601
assert(getNextQuestInChainID({id = 600}) == 601, "a garbage Questie answer must not be cached")

print("Quest chain status tests passed.")
