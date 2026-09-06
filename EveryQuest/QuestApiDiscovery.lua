local EveryQuest = EveryQuest
local frame = CreateFrame("Frame")
local run
local BATCH_SIZE, INTERVAL, WARMUP = 20, 0.1, 10
local USAGE = "EveryQuest: /everyquest api discover <first> <last> | status | cancel | clear (1..2147483647, at most 100000 IDs)"

local function stop()
	frame:SetScript("OnUpdate", nil)
	run = nil
end

local function recordError(id, reason)
	local message = tostring(reason):gsub("[%c]+", " "):sub(1, 160)
	table.insert(run.report.probeErrors, {id = id, reason = message})
	run.report.errors = run.report.errors + 1
end

local function probe(id)
	local ok, title = pcall(C_QuestLog.GetQuestInfo, id)
	if not ok then
		recordError(id, title)
	elseif type(title) == "string" and title ~= "" then
		run.report.titles[id] = title
		run.report.found = run.report.found + 1
	elseif run.phase == "probe" then
		local warmed, reason = pcall(C_QuestLog.GetQuestObjectives, id)
		if warmed then
			table.insert(run.retry, id)
		else
			recordError(id, reason)
		end
	else
		run.report.missing = run.report.missing + 1
	end
end

local function finish()
	local report = run.report
	if report.total ~= report.found + report.missing + report.errors
		or not EveryQuest.db or type(EveryQuest.db.char) ~= "table" then
		stop()
		EveryQuest:Print("EveryQuest discovery failed: invalid counts or character database; previous report preserved.")
		return
	end
	table.sort(report.probeErrors, function(a, b) return a.id < b.id end)
	report.completedAt = time()
	EveryQuest.db.char.questApiDiscovery = report
	stop()
	EveryQuest:Print(("EveryQuest discovery complete: %d total, %d found, %d missing, %d errors. Use /reload to save the report."):format(
		report.total, report.found, report.missing, report.errors))
end

local function update(_, elapsed)
	if not run then return end
	if run.phase == "warmup" then
		run.remaining = run.remaining - elapsed
		if run.remaining > 0 then return end
		run.phase, run.index, run.elapsed = "retry", 1, 0
		return
	end
	run.elapsed = run.elapsed + elapsed
	if run.elapsed < INTERVAL then return end
	run.elapsed = 0 -- Do not catch up after a slow frame.
	local last = run.phase == "probe" and run.report.lastID or #run.retry
	for _ = 1, BATCH_SIZE do
		if run.index > last then break end
		probe(run.phase == "probe" and run.index or run.retry[run.index])
		run.index = run.index + 1
	end
	if run.index > last then
		if run.phase == "probe" and #run.retry > 0 then
			run.phase, run.remaining = "warmup", WARMUP
			EveryQuest:Print(("EveryQuest discovery: waiting 10 seconds before retrying %d IDs."):format(#run.retry))
		else
			finish()
		end
	end
end

function EveryQuest:StartQuestApiDiscovery(input)
	if run then
		self:Print("EveryQuest discovery: a run is already active.")
		return false
	end
	local first, last = (input or ""):match("^%s*(%d+)%s+(%d+)%s*$")
	first, last = tonumber(first), tonumber(last)
	if not first or not last or first < 1 or last > 2147483647 or first > last or last - first >= 100000 then
		self:Print(USAGE)
		return false
	end
	if not self.db or type(self.db.char) ~= "table" then
		self:Print("EveryQuest discovery: character database is unavailable; previous report preserved.")
		return false
	end
	if type(C_QuestLog) ~= "table" or type(C_QuestLog.GetQuestInfo) ~= "function"
		or type(C_QuestLog.GetQuestObjectives) ~= "function" then
		self:Print("EveryQuest discovery: required quest APIs are unavailable; previous report preserved.")
		return false
	end
	local version, build, _, interface = _G.GetBuildInfo()
	local addonVersion = C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata("EveryQuest", "Version")
	run = {
		phase = "probe", index = first, elapsed = 0, retry = {},
		report = {
			formatVersion = 1, firstID = first, lastID = last, startedAt = time(),
			addonVersion = addonVersion or "unknown", clientVersion = version, clientBuild = build,
			interface = interface, locale = _G.GetLocale(), total = last - first + 1,
			found = 0, missing = 0, errors = 0, titles = {}, probeErrors = {},
		},
	}
	frame:SetScript("OnUpdate", update)
	self:Print(("EveryQuest discovery started: %d..%d. Titles are observations, not proof of quest availability."):format(first, last))
	return true
end

function EveryQuest:HandleQuestApiDiscoveryCommand(input)
	input = (input or ""):match("^%s*(.-)%s*$")
	local action = string.lower(input)
	if action == "status" then
		if run then
			if run.phase == "warmup" then
				self:Print(("EveryQuest discovery: waiting %d seconds; %d retry candidates."):format(math.ceil(run.remaining), #run.retry))
			else
				local processed = run.index - (run.phase == "probe" and run.report.firstID or 1)
				local total = run.phase == "probe" and run.report.total or #run.retry
				self:Print(("EveryQuest discovery: %s %d/%d; %d found, %d missing, %d errors."):format(
					run.phase, processed, total, run.report.found, run.report.missing, run.report.errors))
			end
		else
			local report = self.db and self.db.char and self.db.char.questApiDiscovery
			if report then
				self:Print(("EveryQuest discovery: last complete range %d..%d, %d found, %d missing, %d errors (%s build %s, %s)."):format(
					report.firstID, report.lastID, report.found, report.missing, report.errors,
					tostring(report.clientVersion), tostring(report.clientBuild), tostring(report.locale)))
			else
				self:Print("EveryQuest discovery: no active run or complete report.")
			end
		end
	elseif action == "cancel" then
		local active = run ~= nil
		stop()
		self:Print(active and "EveryQuest discovery cancelled; previous report preserved." or "EveryQuest discovery: no active run.")
	elseif action == "clear" then
		if run then
			self:Print("EveryQuest discovery: cancel the active run before clearing.")
		elseif self.db and type(self.db.char) == "table" then
			self.db.char.questApiDiscovery = nil
			self:Print("EveryQuest discovery: saved report cleared.")
		else
			self:Print("EveryQuest discovery: character database is unavailable.")
		end
	else
		self:StartQuestApiDiscovery(input)
	end
end
