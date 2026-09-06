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

local groupByAddon = {}
for _, module in ipairs(DATA_MODULES) do
	groupByAddon[module.addon] = module.group
end

local function dataForIDs(questIDs)
	local data = {}
	for _, module in ipairs(DATA_MODULES) do
		data[module.group] = {[1] = {}}
	end
	for _, questID in ipairs(questIDs) do
		table.insert(data.Battlegrounds[1], {id = questID, n = "Quest " .. tostring(questID)})
	end
	if questIDs[1] then
		for index = 2, #DATA_MODULES do
			local group = DATA_MODULES[index].group
			table.insert(data[group][1], {id = questIDs[1], n = "Duplicate"})
		end
	end
	return data
end

local function copyData(source)
	local target = {}
	for group, zones in pairs(source) do
		target[group] = zones
	end
	return target
end

local function newHarness(options)
	options = options or {}
	local messages = {}
	local frames = {}
	local probeCalls = {}
	local probeCounts = {}
	local loadCalls = {}
	local clock = 1700000000
	local data = copyData(options.data or dataForIDs({1}))

	local environment = {
		EveryQuestData = data,
		Enum = {
			AddOnEnableState = {
				None = 0,
			},
		},
	}
	environment._G = environment
	setmetatable(environment, {__index = _G})

	local character = {
		history = {
			[1] = {
				[77] = {id = 77, status = 2},
			},
		},
		saved = {sentinel = true},
		zoneid = 1,
		zonegroup = "Kalimdor",
	}
	environment.EveryQuest = {
		db = {
			char = character,
			profile = {debug = false},
		},
	}
	function environment.EveryQuest:Print(message)
		table.insert(messages, tostring(message))
	end
	function environment.EveryQuest:LoadQuestData()
		error("quest API audit must not call the mutating LoadQuestData path")
	end

	environment.CreateFrame = function()
		local frame = {scripts = {}}
		function frame:SetScript(name, handler)
			self.scripts[name] = handler
		end
		table.insert(frames, frame)
		return frame
	end
	environment.UnitName = function()
		return "Auditor"
	end
	environment.GetBuildInfo = function()
		return "2.5.6", "69546", "Sep 4 2026", 20506
	end
	environment.GetLocale = function()
		return "enUS"
	end
	environment.time = function()
		clock = clock + 1
		return clock
	end

	environment.C_AddOns = {
		IsAddOnLoaded = function(addon)
			if options.loaded and options.loaded[addon] ~= nil then
				return options.loaded[addon]
			end
			return environment.EveryQuestData[groupByAddon[addon]] ~= nil
		end,
		DoesAddOnExist = function(addon)
			return not (options.missing and options.missing[addon])
		end,
		GetAddOnEnableState = function(addon)
			if options.disabled and options.disabled[addon] then
				return environment.Enum.AddOnEnableState.None
			end
			return 2
		end,
		LoadAddOn = function(addon)
			table.insert(loadCalls, addon)
			if options.loadThrows and options.loadThrows[addon] then
				error(options.loadThrows[addon])
			end
			if options.loadFailures and options.loadFailures[addon] then
				return false, options.loadFailures[addon]
			end
			if options.loadData and options.loadData[addon] then
				environment.EveryQuestData[groupByAddon[addon]] = options.loadData[addon]
			end
			return true
		end,
		GetAddOnMetadata = function(addon, field)
			assert(addon == "EveryQuest" and field == "Version")
			return "2026.3.6"
		end,
		EnableAddOn = function()
			error("scanner must not enable data modules")
		end,
	}

	if options.apiUnavailable then
		environment.C_QuestLog = {}
	else
		environment.C_QuestLog = {
			GetQuestInfo = function(questID)
				table.insert(probeCalls, questID)
				probeCounts[questID] = (probeCounts[questID] or 0) + 1
				if options.probe then
					return options.probe(questID, probeCounts[questID])
				end
				return "Quest " .. tostring(questID)
			end,
		}
	end

	local chunk = assert(loadfile("EveryQuest/QuestApiAudit.lua"))
	setfenv(chunk, environment)
	chunk()

	return {
		env = environment,
		frame = assert(frames[1]),
		messages = messages,
		probeCalls = probeCalls,
		probeCounts = probeCounts,
		loadCalls = loadCalls,
		character = character,
	}
end

local function runOneFrame(harness, elapsed)
	local handler = assert(harness.frame.scripts.OnUpdate, "audit frame is not active")
	handler(harness.frame, elapsed or 0.016)
end

local function runUntilComplete(harness)
	local frames = 0
	while harness.frame.scripts.OnUpdate do
		runOneFrame(harness, 1)
		frames = frames + 1
		assert(frames < 100, "audit did not complete")
	end
end

local function assertList(actual, expected, message)
	assert(#actual == #expected, (message or "list length mismatch") .. ": " .. #actual .. " ~= " .. #expected)
	for index, value in ipairs(expected) do
		assert(actual[index] == value, (message or "list mismatch") .. " at " .. index)
	end
end

local function hasMessage(harness, expected)
	for _, message in ipairs(harness.messages) do
		if string.find(message, expected, 1, true) then
			return true
		end
	end
	return false
end

local testsRun = 0
local function test(name, callback)
	local ok, reason = pcall(callback)
	if not ok then
		error(name .. ": " .. tostring(reason), 0)
	end
	testsRun = testsRun + 1
end

test("collects positive unique IDs in stable order without startup probes", function()
	local data = dataForIDs({3})
	data.Battlegrounds = {
		[8] = {
			{id = 9},
			{id = 3},
			{id = 0},
			{id = -1},
			{id = 2.5},
			{id = "7"},
			{name = "missing id"},
		},
	}
	data.Classes = {[2] = {{id = 7}, {id = 3}}}
	local harness = newHarness({data = data})
	local history = harness.character.history
	assert(#harness.probeCalls == 0, "loading the scanner must not start an audit")
	assert(harness.env.EveryQuest:StartQuestApiAudit() == true)
	runUntilComplete(harness)
	assertList(harness.probeCalls, {3, 7, 9}, "collector must filter, de-duplicate, and sort IDs")
	assert(harness.character.history == history and history[1][77].status == 2, "audit must preserve history")
	assert(harness.character.zoneid == 1 and harness.character.zonegroup == "Kalimdor")
end)

test("loads enabled LOD data without using the history loader", function()
	local data = dataForIDs({10})
	local outland = data.Outland
	data.Outland = nil
	local harness = newHarness({
		data = data,
		loadData = {EveryQuest_Outland = outland},
	})
	assert(harness.env.EveryQuest:StartQuestApiAudit() == true)
	assertList(harness.loadCalls, {"EveryQuest_Outland"})
	runUntilComplete(harness)
	assert(harness.character.questApiAudit.total == 1)
end)

test("aborts cleanly for missing, disabled, failed, and empty modules", function()
	local cases = {
		{
			name = "missing",
			options = {missing = {EveryQuest_Raids = true}},
			reason = "MISSING",
		},
		{
			name = "disabled",
			options = {disabled = {EveryQuest_Raids = true}},
			reason = "DISABLED",
		},
		{
			name = "load failed",
			options = {loadFailures = {EveryQuest_Raids = "CORRUPT"}},
			reason = "CORRUPT",
		},
		{
			name = "no data",
			options = {},
			reason = "NO_DATA",
		},
	}
	for _, case in ipairs(cases) do
		local data = dataForIDs({1})
		data.Raids = nil
		case.options.data = data
		local harness = newHarness(case.options)
		local previous = {case = case.name}
		harness.character.questApiAudit = previous
		assert(harness.env.EveryQuest:StartQuestApiAudit() == false)
		assert(#harness.probeCalls == 0, case.name .. " must abort before probing")
		assert(harness.character.questApiAudit == previous, case.name .. " must preserve the previous report")
		assert(harness.frame.scripts.OnUpdate == nil, case.name .. " must not leave the frame active")
		assert(hasMessage(harness, "EveryQuest_Raids") and hasMessage(harness, case.reason))
	end
end)

test("processes a bounded batch and reports progress", function()
	local questIDs = {}
	for questID = 1, 60 do
		table.insert(questIDs, questID)
	end
	local harness = newHarness({data = dataForIDs(questIDs)})
	assert(harness.env.EveryQuest:StartQuestApiAudit() == true)
	runOneFrame(harness)
	assert(#harness.probeCalls == 50, "one frame must process only the configured batch")
	assert(harness.frame.scripts.OnUpdate ~= nil, "remaining IDs must stay scheduled")
	harness.env.EveryQuest:PrintQuestApiAuditStatus()
	assert(hasMessage(harness, "50/60 processed"), "status must expose bounded progress")
	runUntilComplete(harness)
	assert(harness.character.questApiAudit.total == 60)
end)

test("retries missing titles and keeps errors distinct", function()
	local harness = newHarness({
		data = dataForIDs({1, 2, 3, 4, 5}),
		probe = function(questID, attempt)
			if questID == 1 then
				return "Available"
			elseif questID == 2 and attempt == 2 then
				return "Recovered"
			elseif questID == 4 then
				error("first pass failure")
			elseif questID == 5 and attempt == 2 then
				error("second pass\nfailure")
			end
			return nil
		end,
	})
	local previous = {old = true}
	harness.character.questApiAudit = previous
	local history = harness.character.history
	assert(harness.env.EveryQuest:StartQuestApiAudit() == true)
	runOneFrame(harness)
	assert(harness.character.questApiAudit == previous, "first pass must not replace the complete report")
	assert(hasMessage(harness, "retrying 3 quest IDs"))
	runUntilComplete(harness)

	local report = harness.character.questApiAudit
	assert(report ~= previous, "completion must atomically replace the report")
	assert(report.formatVersion == 1)
	assert(report.addonVersion == "2026.3.6")
	assert(report.clientVersion == "2.5.6" and report.clientBuild == "69546")
	assert(report.interface == 20506 and report.locale == "enUS")
	assert(report.completedAt > report.startedAt)
	assert(report.total == 5 and report.available == 2 and report.unavailable == 1 and report.errors == 2)
	assertList(report.unavailableIds, {3})
	assert(report.probeErrors[1].id == 4 and report.probeErrors[2].id == 5, "probe errors must be sorted")
	assert(not string.find(report.probeErrors[2].reason, "\n", 1, true), "error reasons must be single-line")
	assert(#report.probeErrors[2].reason <= 160, "error reasons must be compact")
	assert(harness.probeCounts[1] == 1 and harness.probeCounts[4] == 1)
	assert(harness.probeCounts[2] == 2 and harness.probeCounts[3] == 2 and harness.probeCounts[5] == 2)
	assert(harness.character.history == history and history[1][77].status == 2)
	assert(harness.character.saved.sentinel == true, "unrelated character data must survive")
	harness.env.EveryQuest:PrintQuestApiAuditStatus()
	assert(hasMessage(harness, "last complete report for 2.5.6 build 69546"))
end)

test("waits ten seconds before retry and remains cancellable", function()
	local harness = newHarness({
		data = dataForIDs({1, 2}),
		probe = function(questID, attempt)
			if attempt == 2 then
				return "Recovered " .. tostring(questID)
			end
			return nil
		end,
	})
	local previous = {old = true}
	harness.character.questApiAudit = previous
	assert(harness.env.EveryQuest:StartQuestApiAudit() == true)
	runOneFrame(harness)
	assert(#harness.probeCalls == 2, "first pass must probe each collected ID once")
	assert(harness.character.questApiAudit == previous, "warm-up must preserve the previous report")
	harness.env.EveryQuest:PrintQuestApiAuditStatus()
	assert(hasMessage(harness, "waiting 10 seconds before pass 2"), "status must expose warm-up time")

	runOneFrame(harness, 9.999)
	assert(#harness.probeCalls == 2, "warm-up must issue no retry probes before ten seconds")
	assert(harness.character.questApiAudit == previous)
	runOneFrame(harness, 0.01)
	assert(#harness.probeCalls == 4, "retry must start when ten elapsed seconds have accumulated")
	assert(harness.character.questApiAudit.available == 2)
	assert(harness.character.questApiAudit.unavailable == 0)

	local cancelled = newHarness({
		data = dataForIDs({3}),
		probe = function()
			return nil
		end,
	})
	local cancelledPrevious = {old = "preserved"}
	cancelled.character.questApiAudit = cancelledPrevious
	assert(cancelled.env.EveryQuest:StartQuestApiAudit() == true)
	runOneFrame(cancelled)
	assert(cancelled.env.EveryQuest:CancelQuestApiAudit() == true)
	assert(cancelled.frame.scripts.OnUpdate == nil)
	assert(cancelled.character.questApiAudit == cancelledPrevious, "warm-up cancellation must preserve the previous report")
	assert(#cancelled.probeCalls == 1, "warm-up cancellation must stop retry probes")
end)

test("preserves reports when the Anniversary title API is unavailable", function()
	local harness = newHarness({apiUnavailable = true})
	local previous = {old = true}
	harness.character.questApiAudit = previous
	assert(harness.env.EveryQuest:StartQuestApiAudit() == false)
	assert(harness.character.questApiAudit == previous)
	assert(#harness.loadCalls == 0 and #harness.probeCalls == 0)
	assert(hasMessage(harness, "C_QuestLog.GetQuestInfo is unavailable"))
end)

test("prevents duplicate runs and preserves data across cancel and clear", function()
	local questIDs = {}
	for questID = 1, 60 do
		table.insert(questIDs, questID)
	end
	local harness = newHarness({data = dataForIDs(questIDs)})
	local previous = {old = true}
	harness.character.questApiAudit = previous
	assert(harness.env.EveryQuest:StartQuestApiAudit() == true)
	assert(harness.env.EveryQuest:StartQuestApiAudit() == false)
	assert(hasMessage(harness, "already running"))
	assert(harness.env.EveryQuest:ClearQuestApiAudit() == false)
	assert(harness.character.questApiAudit == previous)
	runOneFrame(harness)
	assert(harness.env.EveryQuest:CancelQuestApiAudit() == true)
	assert(harness.frame.scripts.OnUpdate == nil)
	assert(harness.character.questApiAudit == previous)
	assert(harness.env.EveryQuest:CancelQuestApiAudit() == false)
	assert(harness.env.EveryQuest:ClearQuestApiAudit() == true)
	assert(harness.character.questApiAudit == nil)
	assert(harness.character.history[1][77].status == 2 and harness.character.saved.sentinel == true)
	harness.env.EveryQuest:PrintQuestApiAuditStatus()
	assert(hasMessage(harness, "no complete report is saved"))
end)

test("routes the hidden maintainer command without changing player help", function()
	local harness = newHarness()
	local routed
	harness.env.EveryQuest.HandleQuestApiAuditCommand = function(_, arguments)
		routed = arguments
	end
	harness.env.EveryQuest.Toggle = function()
		error("toggle must not run for audit commands")
	end
	harness.env.EveryQuest_Locale = {EveryQuest = "EveryQuest"}
	local optionsChunk = assert(loadfile("EveryQuest/Options.lua"))
	setfenv(optionsChunk, harness.env)
	optionsChunk()

	harness.env.EveryQuest:HandleSlash(" api audit   cancel ")
	assert(routed == "cancel")
	harness.env.EveryQuest:CreateOptions()
	assert(harness.env.EveryQuest.options["api audit"] == nil, "audit must not appear in options")
	harness.env.EveryQuest:PrintUsage()
	assert(not hasMessage(harness, "api audit"), "player help must not advertise the audit")
end)

print(("Quest API audit tests passed (%d scenarios)."):format(testsRun))
