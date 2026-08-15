-- Compatibility glue for modern Classic clients that moved addon helpers under C_AddOns.
if not getglobal then
	getglobal = function(name)
		return _G[name]
	end
end

if not setglobal then
	setglobal = function(name, value)
		_G[name] = value
	end
end

if not gcinfo and collectgarbage then
	gcinfo = function()
		return collectgarbage("count"), 0
	end
end

if not loadstring and load then
	loadstring = load
end

if not IsAddOnLoadOnDemand then
	IsAddOnLoadOnDemand = function(addon)
		if not addon or not C_AddOns or not C_AddOns.IsAddOnLoadOnDemand then
			return false
		end
		local ok, isLoadOnDemand = pcall(C_AddOns.IsAddOnLoadOnDemand, addon)
		return ok and isLoadOnDemand or false
	end
end

local function getAddOnEnableState(addon)
	if not addon or not C_AddOns or not C_AddOns.GetAddOnEnableState then
		return true
	end
	local playerName = UnitName and UnitName("player") or nil
	local ok, state = pcall(C_AddOns.GetAddOnEnableState, addon, playerName)
	if not ok then
		ok, state = pcall(C_AddOns.GetAddOnEnableState, addon)
	end
	return ok and state and state > 0 or false
end

if not GetAddOnInfo then
	GetAddOnInfo = function(addon)
		if C_AddOns and C_AddOns.GetAddOnInfo then
			local name, title, notes, loadable, reason, security, newVersion = C_AddOns.GetAddOnInfo(addon)
			if name then
				return name, title, notes, getAddOnEnableState(addon), loadable, reason, security, newVersion
			end
		end
		return nil
	end
end

if not GetAddOnMetadata then
	GetAddOnMetadata = function(addon, field)
		if C_AddOns and C_AddOns.GetAddOnMetadata then
			return C_AddOns.GetAddOnMetadata(addon, field)
		end
		return nil
	end
end

if not GetNumAddOns then
	GetNumAddOns = function()
		if C_AddOns and C_AddOns.GetNumAddOns then
			return C_AddOns.GetNumAddOns()
		end
		return 0
	end
end

if not IsAddOnLoaded then
	IsAddOnLoaded = function(addon)
		if C_AddOns and C_AddOns.IsAddOnLoaded then
			return C_AddOns.IsAddOnLoaded(addon)
		end
		return false
	end
end

if not LoadAddOn then
	LoadAddOn = function(addon)
		if C_AddOns and C_AddOns.LoadAddOn then
			return C_AddOns.LoadAddOn(addon)
		end
		return false, "MISSING"
	end
end

if not EnableAddOn then
	EnableAddOn = function(addon)
		if C_AddOns and C_AddOns.EnableAddOn then
			return C_AddOns.EnableAddOn(addon)
		end
	end
end

if not DisableAddOn then
	DisableAddOn = function(addon)
		if C_AddOns and C_AddOns.DisableAddOn then
			return C_AddOns.DisableAddOn(addon)
		end
	end
end

local function validQuestID(questID)
	questID = tonumber(questID)
	if questID and questID > 0 then
		return questID
	end
end

local function isModernQuestLogTitle(third, fourth)
	return type(fourth) == "boolean" or type(third) == "number"
end

local function isDailyQuestLogFrequency(frequency)
	if not frequency then
		return false
	end
	if LE_QUEST_FREQUENCY_DAILY and frequency == LE_QUEST_FREQUENCY_DAILY then
		return true
	end
	return frequency == 2
end

local function isDailyQuestInfoFrequency(frequency)
	if not frequency then
		return false
	end
	if Enum and Enum.QuestFrequency and Enum.QuestFrequency.Daily then
		return frequency == Enum.QuestFrequency.Daily
	end
	return frequency == 1
end

local function getQuestTagName(questID)
	if not questID then
		return nil
	end
	if C_QuestLog and C_QuestLog.GetQuestTagInfo then
		local ok, tagInfo, tagName = pcall(C_QuestLog.GetQuestTagInfo, questID)
		if ok then
			if type(tagInfo) == "table" then
				return tagInfo.tagName
			elseif type(tagInfo) == "string" then
				return tagInfo
			elseif type(tagName) == "string" then
				return tagName
			end
		end
	end
	if GetQuestTagInfo then
		local ok, tagID, tagName = pcall(GetQuestTagInfo, questID)
		if ok then
			if type(tagID) == "string" then
				return tagID
			elseif type(tagName) == "string" then
				return tagName
			end
		end
	end
	return nil
end

function EveryQuest_GetQuestLogTitle(index)
	if GetQuestLogTitle then
		local title, level, third, fourth, fifth, sixth, seventh, eighth, ninth = GetQuestLogTitle(index)
		if isModernQuestLogTitle(third, fourth) then
			local questID = validQuestID(eighth)
			return title, level, getQuestTagName(questID), third, fourth, fifth, sixth, isDailyQuestLogFrequency(seventh), questID
		end
		return title, level, third, fourth, fifth, sixth, seventh, eighth, ninth
	end

	if C_QuestLog and C_QuestLog.GetInfo then
		local info = C_QuestLog.GetInfo(index)
		if not info then
			return nil
		end
		local questID = validQuestID(info.questID)
		return info.title, info.level, getQuestTagName(questID), info.suggestedGroup, info.isHeader, info.isCollapsed, info.isComplete, isDailyQuestInfoFrequency(info.frequency), questID
	end
end

function EveryQuest_GetQuestLogQuestID(index)
	if not index then
		return nil
	end
	if C_QuestLog and C_QuestLog.GetInfo then
		local info = C_QuestLog.GetInfo(index)
		local questID = info and validQuestID(info.questID)
		if questID then
			return questID
		end
	end
	if GetQuestLogTitle then
		local _, _, third, fourth, _, _, _, eighth, ninth = GetQuestLogTitle(index)
		local questID
		if isModernQuestLogTitle(third, fourth) then
			questID = eighth
		else
			questID = ninth
		end
		questID = validQuestID(questID)
		if questID then
			return questID
		end
	end
	return nil
end

function EveryQuest_PlaySound(soundKitKey, legacySoundName)
	if not PlaySound then
		return
	end
	if SOUNDKIT and soundKitKey and SOUNDKIT[soundKitKey] then
		PlaySound(SOUNDKIT[soundKitKey])
	elseif not SOUNDKIT and legacySoundName then
		PlaySound(legacySoundName)
	end
end
