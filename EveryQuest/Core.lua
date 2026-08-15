local MINOR_VERSION = tonumber(("$Revision: 13 $"):match("%d+"))

EveryQuest = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceHook-2.1", "AceDB-2.0", "AceConsole-2.0")
EveryQuestQ = AceLibrary("Quixote-1.0")
local L = AceLibrary("AceLocale-2.2"):new("EveryQuest")
local EveryQuest, self = EveryQuest, EveryQuest
EveryQuestData = {}
EveryQuest.version = MINOR_VERSION
EveryQuest.revision = MINOR_VERSION


-- Debug Function
-- #NODOC
function EveryQuest:Print(text)
    DEFAULT_CHAT_FRAME:AddMessage(tostring(text))
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

local function registerSlash(index, command)
	setglobal("SLASH_EVERYQUEST" .. index, command)
	if hash_SlashCmdList then
		hash_SlashCmdList[command:upper()] = "EVERYQUEST"
	end
end

SlashCmdList = SlashCmdList or {}
SlashCmdList.EVERYQUEST = toggleEveryQuest
registerSlash(1, "/everyquest")
registerSlash(2, "/eq")

-- Addon functions

function EveryQuest:OnInitialize()
	EveryQuest:RegisterDB("EveryQuestDB","EveryQuestDBPC")
	EveryQuest:CreateOptions()
	EveryQuest:SetupDefaults()
end

function EveryQuest:OnEnable()
    if Expo then self.debugFrame = Expo:ReturnDebugFrame() end
	EveryQuest:EveryQuestInit()
end

function EveryQuest:OnDisable()
	EveryQuest:UnhookAll()
end

-- Internal for setting default values for the variables
-- #NODOC
function EveryQuest:SetupDefaults()
	
	EveryQuest:RegisterDefaults("char", {
		zoneid = nil,
		zonegroup = nil,
		saved = {},
		history = {},
	})
	
	EveryQuest:RegisterDefaults("profile", {
		disabled = {},
		
		locked = true,
		debug = false,
		
		view = "zone",
	})
	
end

-- Hook escape key so it closes EveryQuestFrame, credit: Ckknight (LibRockConfig-1.0)
local orig_CloseSpecialWindows = _G.CloseSpecialWindows
function _G.CloseSpecialWindows()
	local found = orig_CloseSpecialWindows()
	if EveryQuestFrame and EveryQuestFrame:IsShown() then
		EveryQuestFrame:Hide()
		return true
	end
	return found
end


--- EOF ---
