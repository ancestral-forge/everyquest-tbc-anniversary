local function harness()
	local frame = {}
	function frame:SetScript(event, callback) self[event] = callback end
	local titles, calls, warms, messages = {}, {}, {}, {}
	local redraws = 0
	local addon = {
		Print = function(_, message) table.insert(messages, message) end,
		UpdateFrame = function() redraws = redraws + 1 end,
	}
	local env = setmetatable({
		EveryQuest = addon,
		EveryQuest_Locale = setmetatable({}, {__index = function(_, key) return key end}),
		CreateFrame = function() return frame end,
		C_QuestLog = {
			GetQuestInfo = function(id)
				calls[id] = (calls[id] or 0) + 1
				if titles[id] == false then error("probe failure") end
				return titles[id]
			end,
			GetQuestObjectives = function(id) warms[id] = (warms[id] or 0) + 1 end,
		},
	}, {__index = _G})
	for _, path in ipairs({"EveryQuest/QuestApiOverlay.lua", "EveryQuest/Options.lua"}) do
		local chunk = assert(loadfile(path))
		setfenv(chunk, env)
		chunk()
	end
	return addon, frame, titles, calls, warms, messages, env, function() return redraws end
end

local addon, frame, titles, calls, warms, messages, env, redrawCount = harness()
assert(addon:GetQuestApiOverlayLabel(1) == "")
assert(next(calls) == nil and frame.OnUpdate == nil, "off must not query or poll")
addon:HandleSlash("  API OVERLAY  ")
assert(redrawCount() == 1 and messages[1]:find("enabled", 1, true))
titles[1] = "Cached quest"
assert(addon:GetQuestApiOverlayLabel(1) == "" and warms[1] == nil)
assert(addon:GetQuestApiOverlayLabel(2) == "")
assert(addon:GetQuestApiOverlayLabel("2") == "")
assert(calls[2] == 1 and warms[2] == 1, "duplicate IDs share pending work")
titles[3] = ""
assert(addon:GetQuestApiOverlayLabel(3) == "")
titles[4] = false
assert(addon:GetQuestApiOverlayLabel(4) == "")
assert(addon:GetQuestApiOverlayLabel(nil) == "")
assert(addon:GetQuestApiOverlayLabel(-1) == "")
assert(addon:GetQuestApiOverlayLabel(1.5) == "")
frame.OnUpdate(frame, 9)
assert(calls[2] == 1 and addon:GetQuestApiOverlayLabel(3) == "")
titles[2] = "Arrived from server"
frame.OnUpdate(frame, 1)
assert(addon:GetQuestApiOverlayLabel(2) == "")
assert(addon:GetQuestApiOverlayLabel(3) == "[?]")
assert(addon:GetQuestApiOverlayLabel(4) == "")
assert(frame.OnUpdate == nil and redrawCount() == 2, "retry redraws once then stops")
assert(calls[2] == 2 and calls[3] == 2 and calls[4] == 1)

-- A newly rendered row starts its own bounded check; disabling cancels it.
assert(addon:GetQuestApiOverlayLabel(5) == "")
local oldUpdate = frame.OnUpdate
addon:HandleSlash("api overlay")
assert(frame.OnUpdate == nil and addon:GetQuestApiOverlayLabel(3) == "")
local afterDisable = redrawCount()
oldUpdate(frame, 20)
assert(calls[5] == 1 and redrawCount() == afterDisable)
addon:HandleSlash("api overlay")
titles[3] = "Now cached"
assert(addon:GetQuestApiOverlayLabel(3) == "" and calls[3] == 3, "enable refreshes stale results")

-- Errors in warming and retry never become missing results or flood chat.
env.C_QuestLog.GetQuestObjectives = function() error("warm failure") end
assert(addon:GetQuestApiOverlayLabel(6) == "")
assert(frame.OnUpdate == nil)
local warnings = #messages
assert(addon:GetQuestApiOverlayLabel(7) == "" and #messages == warnings)
env.C_QuestLog.GetQuestObjectives = function() end
addon:GetQuestApiOverlayLabel(8)
titles[8] = false
frame.OnUpdate(frame, 10)
assert(addon:GetQuestApiOverlayLabel(8) == "" and frame.OnUpdate == nil)

-- Disabling still works if the API disappears; enabling fails closed.
env.C_QuestLog = {}
addon:HandleSlash("api overlay")
addon:HandleSlash("api overlay")
assert(messages[#messages]:find("unavailable", 1, true))
assert(addon:GetQuestApiOverlayLabel(3) == "" and frame.OnUpdate == nil)
local fresh, freshFrame = harness()
assert(fresh:GetQuestApiOverlayLabel(3) == "" and freshFrame.OnUpdate == nil, "reload defaults to off")
print("Quest API overlay tests passed.")
