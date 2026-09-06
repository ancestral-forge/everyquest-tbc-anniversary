local EveryQuest = EveryQuest

local RETRY_SECONDS = 10
local frame = CreateFrame("Frame")
local enabled = false
local results = {}
local pending = {}
local warned = false

local function warnProbeError()
	if not warned then
		warned = true
		EveryQuest:Print("EveryQuest API overlay: API error; affected quests remain unmarked.")
	end
end

local function probe(questID)
	local ok, title = pcall(C_QuestLog.GetQuestInfo, questID)
	if not ok then
		warnProbeError()
		return "error"
	end
	if type(title) == "string" and title ~= "" then
		return "resolved"
	end
	return "missing"
end

local function update(_, elapsed)
	if not enabled then return end
	local changed = false
	for questID, remaining in pairs(pending) do
		remaining = remaining - elapsed
		if remaining <= 0 then
			pending[questID] = nil
			results[questID] = probe(questID)
			changed = true
		else
			pending[questID] = remaining
		end
	end
	if not next(pending) then
		frame:SetScript("OnUpdate", nil)
	end
	if changed then
		EveryQuest:UpdateFrame()
	end
end

function EveryQuest:GetQuestApiOverlayLabel(questID)
	if not enabled then return "" end
	questID = tonumber(questID)
	if not questID or questID <= 0 or questID ~= math.floor(questID) then return "" end
	if not results[questID] then
		results[questID] = probe(questID)
		if results[questID] == "missing" then
			-- Classic quest data is asynchronous; warm the cache before retrying.
			local ok = pcall(C_QuestLog.GetQuestObjectives, questID)
			if not ok then
				results[questID] = "error"
				warnProbeError()
			else
				results[questID] = "pending"
				pending[questID] = RETRY_SECONDS
				frame:SetScript("OnUpdate", update)
			end
		end
	end
	return results[questID] == "missing" and "[?]" or ""
end

function EveryQuest:ToggleQuestApiOverlay()
	if not enabled and (type(C_QuestLog) ~= "table"
		or type(C_QuestLog.GetQuestInfo) ~= "function"
		or type(C_QuestLog.GetQuestObjectives) ~= "function") then
		self:Print("EveryQuest API overlay: required quest APIs are unavailable; overlay remains off.")
		return
	end
	enabled = not enabled
	results = {}
	pending = {}
	warned = false
	frame:SetScript("OnUpdate", nil)
	if enabled then
		self:Print("EveryQuest API overlay enabled: [?] means no API title after a 10-second retry, not quest unavailability.")
	else
		self:Print("EveryQuest API overlay disabled.")
	end
	self:UpdateFrame()
end
