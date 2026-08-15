local MINOR_VERSION = tonumber(("$Revision: 13 $"):match("%d+"))

EveryQuest = EveryQuest or {}
local EveryQuest, self = EveryQuest, EveryQuest
EveryQuestData = {}
EveryQuest.version = MINOR_VERSION
EveryQuest.revision = MINOR_VERSION
EveryQuest.eventFrame = EveryQuest.eventFrame or CreateFrame("Frame")
EveryQuest.registeredEvents = EveryQuest.registeredEvents or {}


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

local function registerSlash(name, index, command)
	_G["SLASH_" .. name .. index] = command
end

local function handleEveryQuestSlash(input)
	if EveryQuest.HandleSlash then
		EveryQuest:HandleSlash(input)
	else
		toggleEveryQuest()
	end
end

SlashCmdList = SlashCmdList or {}
SlashCmdList.EVERYQUEST = handleEveryQuestSlash
registerSlash("EVERYQUEST", 1, "/eq")
registerSlash("EVERYQUEST", 2, "/everyquest")

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

local function copyDefaults(value)
	if type(value) ~= "table" then
		return value
	end

	local target = {}
	for key, child in pairs(value) do
		target[key] = copyDefaults(child)
	end
	return target
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

function EveryQuest:SetupDatabase()
	EveryQuestDB = EveryQuestDB or {}
	EveryQuestDBPC = EveryQuestDBPC or {}

	local profile = EveryQuestDB.profile
	if not profile and EveryQuestDB.profiles then
		profile = EveryQuestDB.profiles.Default
	end
	if not profile then
		profile = EveryQuestDB
	end

	local char = EveryQuestDBPC.char or EveryQuestDBPC
	if profile ~= EveryQuestDB then
		EveryQuestDB.profile = profile
	end
	if char ~= EveryQuestDBPC then
		EveryQuestDBPC.char = char
	end

	self.db = {
		profile = profile,
		char = char,
		raw = {
			profile = EveryQuestDB,
			char = EveryQuestDBPC,
		},
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

-- Hook escape key so it closes EveryQuestFrame, credit: Ckknight (LibRockConfig-1.0)
local orig_CloseSpecialWindows = _G.CloseSpecialWindows
function _G.CloseSpecialWindows()
	local found = orig_CloseSpecialWindows and orig_CloseSpecialWindows()
	if EveryQuestFrame and EveryQuestFrame:IsShown() then
		EveryQuestFrame:Hide()
		return true
	end
	return found
end

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
