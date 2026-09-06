local EveryQuest = EveryQuest

local BATCH_SIZE = 50
local RETRY_WARMUP_SECONDS = 10
local REPORT_FORMAT_VERSION = 1
local DATA_MODULES = {
	{group = "Battlegrounds", addon = "EveryQuest_Battlegrounds"},
	{group = "Classes", addon = "EveryQuest_Classes"},
	{group = "Dungeons", addon = "EveryQuest_Dungeons"},
	{group = "Eastern Kingdoms", addon = "EveryQuest_Eastern_Kingdoms"},
	{group = "Kalimdor", addon = "EveryQuest_Kalimdor"},
	{group = "Miscellaneous", addon = "EveryQuest_Miscellaneous"},
	{group = "Outland", addon = "EveryQuest_Outland"},
	{group = "Professions", addon = "EveryQuest_Professions"},
	{group = "Raids", addon = "EveryQuest_Raids"},
	{group = "Seasonal", addon = "EveryQuest_Seasonal"},
}

local auditFrame = CreateFrame("Frame")
local currentRun

local function shortenError(reason)
	local text = tostring(reason or "UNKNOWN")
	text = text:gsub("[%c]+", " ")
	return text:sub(1, 160)
end

local function failCollection(module, reason)
	return nil, {
		addon = module.addon,
		group = module.group,
		reason = reason,
	}
end

local function loadDataModule(module)
	if type(EveryQuestData[module.group]) == "table" then
		return true
	end

	if type(C_AddOns) ~= "table"
		or type(C_AddOns.IsAddOnLoaded) ~= "function"
		or type(C_AddOns.DoesAddOnExist) ~= "function"
		or type(C_AddOns.GetAddOnEnableState) ~= "function"
		or type(C_AddOns.LoadAddOn) ~= "function" then
		return false, "ADDON_API_UNAVAILABLE"
	end

	if not C_AddOns.IsAddOnLoaded(module.addon) then
		if not C_AddOns.DoesAddOnExist(module.addon) then
			return false, "MISSING"
		end

		local playerName = UnitName("player")
		local enabledState = C_AddOns.GetAddOnEnableState(module.addon, playerName)
		if Enum and Enum.AddOnEnableState and enabledState == Enum.AddOnEnableState.None then
			return false, "DISABLED"
		end

		local callOK, loaded, reason = pcall(C_AddOns.LoadAddOn, module.addon)
		if not callOK then
			return false, "LOAD_ERROR: " .. shortenError(loaded)
		end
		if not loaded then
			return false, shortenError(reason or "LOAD_FAILED")
		end
	end

	if type(EveryQuestData[module.group]) ~= "table" then
		return false, "NO_DATA"
	end
	return true
end

local function collectQuestIDs()
	local seen = {}
	for _, module in ipairs(DATA_MODULES) do
		local loaded, reason = loadDataModule(module)
		if not loaded then
			return failCollection(module, reason)
		end

		for _, quests in pairs(EveryQuestData[module.group]) do
			if type(quests) == "table" then
				for _, quest in pairs(quests) do
					if type(quest) == "table" then
						local questID = quest.id
						if type(questID) == "number" and questID > 0 and questID == math.floor(questID) then
							seen[questID] = true
						end
					end
				end
			end
		end
	end

	local questIDs = {}
	for questID in pairs(seen) do
		table.insert(questIDs, questID)
	end
	table.sort(questIDs)
	return questIDs
end

local function getAddonVersion()
	if C_AddOns and type(C_AddOns.GetAddOnMetadata) == "function" then
		return C_AddOns.GetAddOnMetadata("EveryQuest", "Version") or "unknown"
	end
	return "unknown"
end

local function captureMetadata()
	local clientVersion, clientBuild, _, interfaceVersion = _G.GetBuildInfo()
	return {
		addonVersion = getAddonVersion(),
		clientVersion = clientVersion,
		clientBuild = clientBuild,
		interface = interfaceVersion,
		locale = _G.GetLocale(),
		startedAt = time(),
	}
end

local function probeQuest(questID)
	local ok, title = pcall(C_QuestLog.GetQuestInfo, questID)
	if not ok then
		return "error", shortenError(title)
	end
	if type(title) == "string" and title ~= "" then
		return "available"
	end
	return "missing"
end

local function stopFrame()
	auditFrame:SetScript("OnUpdate", nil)
end

local function finishRun()
	local run = currentRun
	if not run then
		return
	end

	table.sort(run.probeErrors, function(left, right)
		return left.id < right.id
	end)

	local unavailableCount = #run.unavailableIds
	local errorCount = #run.probeErrors
	if run.available + unavailableCount + errorCount ~= #run.questIDs then
		stopFrame()
		currentRun = nil
		EveryQuest:Print("EveryQuest audit: internal count mismatch; previous report preserved.")
		return
	end

	if not EveryQuest.db or type(EveryQuest.db.char) ~= "table" then
		stopFrame()
		currentRun = nil
		EveryQuest:Print("EveryQuest audit: character database is unavailable; previous report preserved.")
		return
	end

	local report = {
		formatVersion = REPORT_FORMAT_VERSION,
		startedAt = run.metadata.startedAt,
		completedAt = time(),
		addonVersion = run.metadata.addonVersion,
		clientVersion = run.metadata.clientVersion,
		clientBuild = run.metadata.clientBuild,
		interface = run.metadata.interface,
		locale = run.metadata.locale,
		total = #run.questIDs,
		available = run.available,
		unavailable = unavailableCount,
		errors = errorCount,
		unavailableIds = run.unavailableIds,
		probeErrors = run.probeErrors,
	}

	EveryQuest.db.char.questApiAudit = report
	stopFrame()
	currentRun = nil
	EveryQuest:Print(("EveryQuest audit complete: %d total, %d available, %d unavailable, %d errors. Use /reload to flush SavedVariables."):format(
		report.total,
		report.available,
		report.unavailable,
		report.errors
	))
end

local function beginRetryPass(run)
	run.phase = "retry"
	run.index = 1
	run.warmupRemaining = nil
	EveryQuest:Print(("EveryQuest audit: retrying %d quest IDs with no title."):format(#run.retryIds))
end

local function beginRetryWarmup(run)
	run.phase = "warmup"
	run.warmupRemaining = RETRY_WARMUP_SECONDS
	EveryQuest:Print(("EveryQuest audit: pass 1 complete; waiting %d seconds before retrying %d quest IDs."):format(
		RETRY_WARMUP_SECONDS,
		#run.retryIds
	))
end

local function finishPass(run)
	if run.phase == "probe" and #run.retryIds > 0 then
		beginRetryWarmup(run)
	else
		finishRun()
	end
end

local function processBatch(run)
	local questIDs = run.phase == "probe" and run.questIDs or run.retryIds
	local processed = 0
	while processed < BATCH_SIZE and run.index <= #questIDs do
		local questID = questIDs[run.index]
		local result, reason = probeQuest(questID)
		if result == "available" then
			run.available = run.available + 1
		elseif result == "missing" then
			if run.phase == "probe" then
				table.insert(run.retryIds, questID)
			else
				table.insert(run.unavailableIds, questID)
			end
		else
			table.insert(run.probeErrors, {id = questID, reason = reason})
		end
		run.index = run.index + 1
		processed = processed + 1
	end

	if run.index > #questIDs then
		finishPass(run)
	end
end

local function updateAudit(_, elapsed)
	local run = currentRun
	if not run then
		stopFrame()
		return
	end

	if run.phase == "warmup" then
		local elapsedSeconds = tonumber(elapsed) or 0
		if elapsedSeconds > 0 then
			run.warmupRemaining = run.warmupRemaining - elapsedSeconds
		end
		if run.warmupRemaining > 0 then
			return
		end
		beginRetryPass(run)
	end

	processBatch(run)
end

auditFrame:SetScript("OnUpdate", nil)

function EveryQuest:StartQuestApiAudit()
	if currentRun then
		self:Print("EveryQuest audit: an audit is already running.")
		return false
	end
	if not self.db or type(self.db.char) ~= "table" then
		self:Print("EveryQuest audit: character database is unavailable.")
		return false
	end
	if type(C_QuestLog) ~= "table" or type(C_QuestLog.GetQuestInfo) ~= "function" then
		self:Print("EveryQuest audit: C_QuestLog.GetQuestInfo is unavailable in this client; previous report preserved.")
		return false
	end

	currentRun = {
		phase = "collect",
		metadata = captureMetadata(),
	}
	local questIDs, failure = collectQuestIDs()
	if not questIDs then
		currentRun = nil
		self:Print(("EveryQuest audit: cannot load %s (%s); previous report preserved."):format(
			failure.addon,
			failure.reason
		))
		return false
	end

	currentRun.phase = "probe"
	currentRun.questIDs = questIDs
	currentRun.index = 1
	currentRun.available = 0
	currentRun.retryIds = {}
	currentRun.unavailableIds = {}
	currentRun.probeErrors = {}

	auditFrame:SetScript("OnUpdate", updateAudit)
	self:Print(("EveryQuest audit started: %d unique quest IDs, %d probes per frame."):format(#questIDs, BATCH_SIZE))
	return true
end

function EveryQuest:PrintQuestApiAuditStatus()
	if currentRun then
		if currentRun.phase == "warmup" then
			self:Print(("EveryQuest audit: waiting %d seconds before pass 2; %d retry candidates, %d available, %d errors."):format(
				math.ceil(currentRun.warmupRemaining),
				#currentRun.retryIds,
				currentRun.available,
				#currentRun.probeErrors
			))
			return
		end

		local questIDs = currentRun.phase == "probe" and currentRun.questIDs or currentRun.retryIds
		local pass = currentRun.phase == "probe" and 1 or 2
		local processed = currentRun.index - 1
		self:Print(("EveryQuest audit: pass %d, %d/%d processed; %d available, %d retrying, %d unavailable, %d errors."):format(
			pass,
			processed,
			#questIDs,
			currentRun.available,
			#currentRun.retryIds,
			#currentRun.unavailableIds,
			#currentRun.probeErrors
		))
		return
	end

	local report = self.db and self.db.char and self.db.char.questApiAudit
	if report then
		self:Print(("EveryQuest audit: last complete report for %s build %s (%s): %d total, %d available, %d unavailable, %d errors."):format(
			tostring(report.clientVersion),
			tostring(report.clientBuild),
			tostring(report.locale),
			tonumber(report.total) or 0,
			tonumber(report.available) or 0,
			tonumber(report.unavailable) or 0,
			tonumber(report.errors) or 0
		))
	else
		self:Print("EveryQuest audit: no audit is running and no complete report is saved.")
	end
end

function EveryQuest:CancelQuestApiAudit()
	if not currentRun then
		self:Print("EveryQuest audit: no audit is running.")
		return false
	end
	stopFrame()
	currentRun = nil
	self:Print("EveryQuest audit cancelled; previous complete report preserved.")
	return true
end

function EveryQuest:ClearQuestApiAudit()
	if currentRun then
		self:Print("EveryQuest audit: cancel the active audit before clearing its saved report.")
		return false
	end
	if not self.db or type(self.db.char) ~= "table" then
		self:Print("EveryQuest audit: character database is unavailable.")
		return false
	end
	self.db.char.questApiAudit = nil
	self:Print("EveryQuest audit: saved report cleared.")
	return true
end

function EveryQuest:HandleQuestApiAuditCommand(input)
	local action = string.lower((input or ""):match("^%s*(%S*)") or "")
	if action == "" then
		self:StartQuestApiAudit()
	elseif action == "status" then
		self:PrintQuestApiAuditStatus()
	elseif action == "cancel" then
		self:CancelQuestApiAudit()
	elseif action == "clear" then
		self:ClearQuestApiAudit()
	else
		self:Print("EveryQuest maintainer audit: /everyquest api audit [status|cancel|clear]")
	end
end
