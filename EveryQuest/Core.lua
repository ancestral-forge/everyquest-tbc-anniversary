EveryQuest = EveryQuest or {}
local EveryQuest, self = EveryQuest, EveryQuest
EveryQuestData = {}
EveryQuest.eventFrame = EveryQuest.eventFrame or CreateFrame("Frame")
EveryQuest.registeredEvents = EveryQuest.registeredEvents or {}
local SAVED_VARIABLES_SCHEMA = 1


-- Debug Function
-- #NODOC
function EveryQuest:Print(text)
	if DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage(tostring(text))
	end
end

local function toggleEveryQuest()
	local ok, err = pcall(function()
		if EveryQuest.Toggle then
			EveryQuest:Toggle()
		elseif EveryQuestFrame then
			if EveryQuestFrame:IsShown() then
				EveryQuestFrame:Hide()
			else
				EveryQuestFrame:Show()
			end
		else
			EveryQuest:Print("EveryQuest frame is not loaded")
		end
	end)
	if not ok then
		EveryQuest:Print(err)
	end
end

local function handleEveryQuestSlash(input)
	if EveryQuest.HandleSlash then
		EveryQuest:HandleSlash(input)
	else
		toggleEveryQuest()
	end
end

SlashCmdList.EVERYQUEST = handleEveryQuestSlash
_G.SLASH_EVERYQUEST1 = "/everyquest"

-- Addon functions

function EveryQuest:OnInitialize()
	EveryQuest:SetupDatabase()
	EveryQuest:CreateOptions()
	EveryQuest:SetupDefaults()
end

function EveryQuest:OnEnable()
	EveryQuest:EveryQuestInit()
end

function EveryQuest:OnDisable()
	for event in pairs(self.registeredEvents) do
		self.eventFrame:UnregisterEvent(event)
		self.registeredEvents[event] = nil
	end
end

local function copyTable(value, seen)
	if type(value) ~= "table" then
		return value
	end

	seen = seen or {}
	if seen[value] then
		return seen[value]
	end

	local target = {}
	seen[value] = target
	for key, child in pairs(value) do
		target[key] = copyTable(child, seen)
	end
	return target
end

local function copyDefaults(value)
	return copyTable(value)
end

local function applyDefaults(target, defaults)
	for key, value in pairs(defaults) do
		if target[key] == nil then
			target[key] = copyDefaults(value)
		elseif type(target[key]) == "table" and type(value) == "table" then
			applyDefaults(target[key], value)
		end
	end
end

local function copyRootData(source, skipKeys)
	local target = {}
	for key, value in pairs(source) do
		if not skipKeys[key] then
			target[key] = copyTable(value)
		end
	end
	return target
end

local function clearTable(target)
	for key in pairs(target) do
		target[key] = nil
	end
end

local function getProfileDatabase()
	if EveryQuestDB.schemaVersion == SAVED_VARIABLES_SCHEMA and type(EveryQuestDB.profile) == "table" then
		return EveryQuestDB.profile
	end
	if type(EveryQuestDB.profile) == "table" and EveryQuestDB.profile ~= EveryQuestDB then
		return EveryQuestDB.profile
	end
	if type(EveryQuestDB.profiles) == "table" and type(EveryQuestDB.profiles.Default) == "table" then
		return copyTable(EveryQuestDB.profiles.Default)
	end
	if next(EveryQuestDB) then
		return copyRootData(EveryQuestDB, { schemaVersion = true, profile = true, profiles = true })
	end
	return {}
end

local function getCharacterDatabase()
	if EveryQuestDBPC.schemaVersion == SAVED_VARIABLES_SCHEMA and type(EveryQuestDBPC.char) == "table" then
		return EveryQuestDBPC.char
	end
	if type(EveryQuestDBPC.char) == "table" and EveryQuestDBPC.char ~= EveryQuestDBPC then
		return EveryQuestDBPC.char
	end
	if next(EveryQuestDBPC) then
		return copyRootData(EveryQuestDBPC, { schemaVersion = true, char = true })
	end
	return {}
end

function EveryQuest:SetupDatabase()
	if type(EveryQuestDB) ~= "table" then
		EveryQuestDB = {}
	end
	if type(EveryQuestDBPC) ~= "table" then
		EveryQuestDBPC = {}
	end

	local profile = getProfileDatabase()
	local char = getCharacterDatabase()

	clearTable(EveryQuestDB)
	EveryQuestDB.schemaVersion = SAVED_VARIABLES_SCHEMA
	EveryQuestDB.profile = profile

	clearTable(EveryQuestDBPC)
	EveryQuestDBPC.schemaVersion = SAVED_VARIABLES_SCHEMA
	EveryQuestDBPC.char = char

	self.db = {
		profile = profile,
		char = char,
	}
end

-- Internal for setting default values for the variables
-- #NODOC
function EveryQuest:SetupDefaults()
	applyDefaults(EveryQuest.db.char, {
		zoneid = nil,
		zonegroup = nil,
		saved = {},
		history = {},
	})

	applyDefaults(EveryQuest.db.profile, {
		disabled = {},

		locked = true,
		debug = false,

		view = "zone",
	})
end

function EveryQuest:RegisterEvent(event)
	local ok = pcall(self.eventFrame.RegisterEvent, self.eventFrame, event)
	if ok then
		self.registeredEvents[event] = true
	end
	return ok
end

function EveryQuest:UnregisterEvent(event)
	self.eventFrame:UnregisterEvent(event)
	self.registeredEvents[event] = nil
end

local function registerSpecialFrame(frameName)
	if not UISpecialFrames then
		return
	end

	for _, registeredFrameName in ipairs(UISpecialFrames) do
		if registeredFrameName == frameName then
			return
		end
	end

	table.insert(UISpecialFrames, frameName)
end

registerSpecialFrame("EveryQuestFrame")

EveryQuest.eventFrame:SetScript("OnEvent", function(_, event, ...)
	local handler = EveryQuest[event]
	if handler then
		handler(EveryQuest, ...)
	end
end)

function EveryQuest:ADDON_LOADED(addonName)
	if addonName ~= "EveryQuest" then
		return
	end
	self:OnInitialize()
	self:UnregisterEvent("ADDON_LOADED")
	self:RegisterEvent("PLAYER_LOGIN")
end

function EveryQuest:PLAYER_LOGIN()
	self:UnregisterEvent("PLAYER_LOGIN")
	self:OnEnable()
end

EveryQuest:RegisterEvent("ADDON_LOADED")

--- EOF ---
