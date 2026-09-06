local function harness(character)
	local frames, messages, calls, attempts = {}, {}, {}, {}
	local env = setmetatable({SlashCmdList = {}, EveryQuestDBPC = {schemaVersion = 1, char = character or {}}}, {__index = _G})
	env._G = env
	env.CreateFrame = function()
		local frame = {}
		function frame:SetScript(name, callback) self[name] = callback end
		function frame:RegisterEvent() end
		frames[#frames + 1] = frame
		return frame
	end
	env.GetBuildInfo = function() return "2.5.6", "69546", "date", 20506 end
	env.GetLocale = function() return "enUS" end
	env.time = function() return 123456 end
	env.C_AddOns = {GetAddOnMetadata = function() return "2026.3.6" end}
	env.C_QuestLog = {
		GetQuestInfo = function(id)
			calls[#calls + 1] = id
			attempts[id] = (attempts[id] or 0) + 1
			if env.titleProbe then return env.titleProbe(id, attempts[id]) end
			return "Same title"
		end,
		GetQuestObjectives = function(id) if env.warmProbe then env.warmProbe(id) end end,
	}
	for _, path in ipairs({"EveryQuest/Core.lua", "EveryQuest/Options.lua", "EveryQuest/QuestApiDiscovery.lua"}) do
		local chunk = assert(loadfile(path))
		setfenv(chunk, env)
		chunk()
	end
	local addon = env.EveryQuest
	addon.Print = function(_, message) messages[#messages + 1] = message end
	addon:OnInitialize()
	local frame = frames[#frames]
	local function tick(elapsed) assert(frame.OnUpdate)(frame, elapsed or 0.1) end
	local function finish()
		local count = 0
		while frame.OnUpdate do
			tick(1)
			count = count + 1
			assert(count < 20000)
		end
	end
	return addon, env, frame, calls, messages, tick, finish
end

local old = {old = true}
local char = {questApiAudit = {audit = true}, questApiDiscovery = old, history = {[1] = {status = 2}}}
local a, env, frame, calls, messages, tick, finish = harness(char)
assert(frame.OnUpdate == nil and #calls == 0)
assert(env.EveryQuestDBPC.schemaVersion == 1)
for _, input in ipairs({"", "1", "0 2", "2 1", "1.5 2", "1e2 200", "-1 2", "+1 2", "1 2 extra", "1 100001", "2147483647 2147483648"}) do
	assert(a:StartQuestApiDiscovery(input) == false, input)
	assert(char.questApiDiscovery == old and #calls == 0)
end
assert(a:StartQuestApiDiscovery("1 100000"))
a:HandleQuestApiDiscoveryCommand("cancel")
assert(a:StartQuestApiDiscovery("2147483647 2147483647"))
finish()
assert(char.questApiDiscovery.titles[2147483647] == "Same title")
char.questApiDiscovery = old
assert(a:StartQuestApiDiscovery("1 41"))
assert(not a:StartQuestApiDiscovery("1 2"))
a:HandleQuestApiDiscoveryCommand("clear")
assert(char.questApiDiscovery == old)
local before = #calls
tick(0.09)
assert(#calls == before)
tick(0.02)
assert(#calls == before + 20)
tick(10)
assert(#calls == before + 40, "slow frame must not catch up")
a:HandleQuestApiDiscoveryCommand("status")
assert(messages[#messages]:find("40/41", 1, true))
finish()
local report = char.questApiDiscovery
assert(report.total == 41 and report.found == 41 and report.missing == 0 and report.errors == 0)
assert(report.titles[1] == report.titles[2])
assert(report.formatVersion == 1 and report.interface == 20506 and report.locale == "enUS")
assert(report.clientBuild == "69546" and report.addonVersion == "2026.3.6")
assert(report.startedAt == 123456 and report.completedAt == 123456)
assert(char.questApiAudit.audit and char.history[1].status == 2)
local reloaded, reloadEnv, reloadFrame = harness(char)
assert(reloadEnv.EveryQuestDBPC.schemaVersion == 1 and reloaded.db.char.questApiDiscovery == report)
assert(reloadFrame.OnUpdate == nil and reloaded.db.char.history == char.history)

a, env, frame, calls, messages, tick = harness()
env.titleProbe = function(id, attempt)
	if id == 1 and attempt == 2 then return "Recovered" end
	if id == 2 then return "" end
	if id == 3 and attempt == 2 then error("retry\nerror") end
	if id == 4 then error("first pass error") end
end
env.warmProbe = function(id) if id == 5 then error("warm error") end end
assert(a:StartQuestApiDiscovery("1 5"))
tick()
assert(#calls == 5)
a:HandleQuestApiDiscoveryCommand("status")
assert(messages[#messages]:find("waiting 10 seconds", 1, true))
tick(9.99)
assert(#calls == 5)
tick(0.02)
assert(#calls == 5)
tick()
report = a.db.char.questApiDiscovery
assert(report.total == 5 and report.found == 1 and report.missing == 1 and report.errors == 3)
assert(report.titles[1] == "Recovered" and not report.titles[2])
assert(report.probeErrors[1].id == 3 and report.probeErrors[3].id == 5)
assert(not report.probeErrors[1].reason:find("\n", 1, true))
assert(frame.OnUpdate == nil)

for _, phase in ipairs({"probe", "warmup", "retry"}) do
	a, env, frame, calls, messages, tick = harness({questApiDiscovery = old})
	env.titleProbe = function() return nil end
	assert(a:StartQuestApiDiscovery("1 21"))
	if phase ~= "probe" then tick(); tick() end
	if phase == "retry" then tick(10); tick() end
	local late = frame.OnUpdate
	a:HandleQuestApiDiscoveryCommand("cancel")
	assert(messages[#messages]:find("cancelled", 1, true))
	local count = #calls
	late(frame, 100)
	assert(#calls == count and frame.OnUpdate == nil and a.db.char.questApiDiscovery == old)
	a:HandleQuestApiDiscoveryCommand("clear")
	assert(a.db.char.questApiDiscovery == nil)
end

a, env = harness({questApiDiscovery = old})
env.C_QuestLog = {}
assert(not a:StartQuestApiDiscovery("1 2") and a.db.char.questApiDiscovery == old)
a.db = nil
assert(not a:StartQuestApiDiscovery("1 2"))

-- Production router: case/space handling, legacy rejection, ordinary commands.
a = harness()
local routed, toggles = {}, 0
a.HandleQuestApiAuditCommand = function(_, input) routed.audit = input end
a.HandleQuestApiDiscoveryCommand = function(_, input) routed.discover = input end
a.ToggleQuestApiOverlay = function() routed.overlay = (routed.overlay or 0) + 1 end
a.Toggle = function() toggles = toggles + 1 end
for _, action in ipairs({"status", "cancel", "clear"}) do
	a:HandleSlash(" API AUDIT " .. action .. " ")
	assert(routed.audit == action)
	a:HandleSlash("api discover " .. action)
	assert(routed.discover == action)
end
a:HandleSlash("api discover 1 20")
assert(routed.discover == "1 20")
a:HandleSlash("api overlay")
a:HandleSlash("api overlay")
assert(routed.overlay == 2)
a.PrintUsage = function() routed.help = (routed.help or 0) + 1 end
a:HandleSlash("audit-api")
a:HandleSlash("apioverlay")
a:HandleSlash("help")
assert(routed.help == 3 and routed.overlay == 2)
a:HandleSlash("")
a:HandleSlash("debug")
assert(toggles == 1 and a.db.profile.debug == true)
print("Quest API discovery and grouped command tests passed.")
