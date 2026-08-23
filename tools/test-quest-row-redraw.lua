local sourceFile = assert(io.open("EveryQuest/Everyquest.lua", "r"))
local source = sourceFile:read("*a")
sourceFile:close()

local updateFrameSource = assert(source:match(
	"(function EveryQuest:UpdateFrame.-)\nfunction EveryQuest:SortTable"
))
local loader = assert(loadstring(table.concat({
	"local EveryQuest, EveryQuestFrame, questdisplay, sessionvars, updateCurrentZoneButtonState = ...",
	updateFrameSource,
	"return EveryQuest",
}, "\n")))

local questdisplay = {}
local hiddenRows = {}
local environment = {}
environment._G = environment
setmetatable(environment, {__index = _G})

for index = 1, 27 do
	questdisplay[index] = {id = index}
	environment["EveryQuestTitle"..index] = {
		Hide = function()
			hiddenRows[index] = true
		end,
	}
end

local EveryQuest = {}
function EveryQuest:GetQuestZoneData()
	return {{id = 100, n = "Test Quest", s = 3}}
end
function EveryQuest:UpdateButton()
	error("simulated row-rendering failure")
end

EveryQuest.db = {profile = {view = "zone"}}
environment.EveryQuestListScrollFrame = {}
environment.FauxScrollFrame_Update = function() end
environment.FauxScrollFrame_GetOffset = function() return 0 end

setfenv(loader, environment)
loader(
	EveryQuest,
	{IsShown = function() return true end},
	questdisplay,
	{zonegroup = "Kalimdor", zoneid = 15, faction = 3},
	function() end
)

local ok, err = pcall(function()
	EveryQuest:UpdateFrame()
end)
assert(not ok and err:find("simulated row%-rendering failure"), "the simulated redraw must fail")

for index = 1, 27 do
	assert(questdisplay[index] == nil, "redraw must clear stale quest row "..index)
	assert(hiddenRows[index], "redraw must hide stale quest row "..index)
end

print("Quest row redraw cleanup test passed.")
