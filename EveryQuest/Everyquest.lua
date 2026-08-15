--[[
Quest Status:
-2 = Unavailable (display-only)
-1 = Failed, Abandoned
0 = In Progress
1 = Completed
2 = Turned In

Rock("LibRockConfig-1.0").OpenConfigMenu(EveryQuest)
--]]

local EveryQuest, self = EveryQuest, EveryQuest
local L = EveryQuest_Locale
local questdisplay = {}
local sorta = {}
local sortb = {}
local SECOND = 1
local MINUTE = 60
local HOUR = 3600
local DAY = 86400
local clickedID
local sessionvars = {}
local QuestMenuFrame
local zonemenu = { -- Dropdown Zone list
	["Eastern Kingdoms"] = {
		{36,"Alterac Mountains"},
		{45,"Arathi Highlands"},
		{3,"Badlands"},
		{25,"Blackrock Mountain"},
		{4,"Blasted Lands"},
		{46,"Burning Steppes"},
		{279,"Dalaran"},
		{41,"Deadwind Pass"},
		{2257,"Deeprun Tram"},
		{1,"Dun Morogh"},
		{10,"Duskwood"},
		{139,"Eastern Plaguelands"},
		{12,"Elwynn Forest"},
		{3430,"Eversong Woods"},
		{3433,"Ghostlands"},
		{267,"Hillsbrad Foothills"},
		{1537,"Ironforge"},
		{4080,"Isle of Quel'Danas"},
		{38,"Loch Modan"},
		{44,"Redridge Mountains"},
		{51,"Searing Gorge"},
		{3487,"Silvermoon City"},
		{130,"Silverpine Forest"},
		{1519,"Stormwind City"},
		{33,"Stranglethorn Vale"},
		{8,"Swamp of Sorrows"},
		{47,"The Hinterlands"},
		{85,"Tirisfal Glades"},
		{1497,"Undercity"},
		{28,"Western Plaguelands"},
		{40,"Westfall"},
		{11,"Wetlands"},
	},
	["Kalimdor"] = {
		{331,"Ashenvale"},
		{16,"Azshara"},
		{3524,"Azuremyst Isle"},
		{3525,"Bloodmyst Isle"},
		{148,"Darkshore"},
		{1657,"Darnassus"},
		{405,"Desolace"},
		{14,"Durotar"},
		{15,"Dustwallow Marsh"},
		{361,"Felwood"},
		{357,"Feralas"},
		{493,"Moonglade"},
		{215,"Mulgore"},
		{1637,"Orgrimmar"},
		{1377,"Silithus"},
		{406,"Stonetalon Mountains"},
		{440,"Tanaris"},
		{141,"Teldrassil"},
		{17,"The Barrens"},
		{3557,"The Exodar"},
		{400,"Thousand Needles"},
		{1638,"Thunder Bluff"},
		{1216,"Timbermaw Hold"},
		{490,"Un'Goro Crater"},
		{618,"Winterspring"},
	},
	["Outland"] = {
		{3522,"Blade's Edge Mountains"},
		{3483,"Hellfire Peninsula"},
		{3518,"Nagrand"},
		{3523,"Netherstorm"},
		{3520,"Shadowmoon Valley"},
		{3703,"Shattrath City"},
		{3679,"Skettis"},
		{3519,"Terokkar Forest"},
		{3521,"Zangarmarsh"},
	},
	["Dungeons"] = {
		{3790,"Auchenai Crypts"},
		{719,"Blackfathom Deeps"},
		{1584,"Blackrock Depths"},
		{1583,"Blackrock Spire"},
		{1941,"Caverns of Time"},
		{3905,"Coilfang Reservoir"},
		{2557,"Dire Maul"},
		{133,"Gnomeregan"},
		{3562,"Hellfire Ramparts"},
		{4095,"Magisters' Terrace"},
		{3792,"Mana-Tombs"},
		{2100,"Maraudon"},
		{2367,"Old Hillsbrad Foothills"},
		{2437,"Ragefire Chasm"},
		{722,"Razorfen Downs"},
		{491,"Razorfen Kraul"},
		{796,"Scarlet Monastery"},
		{2057,"Scholomance"},
		{3791,"Sethekk Halls"},
		{3789,"Shadow Labyrinth"},
		{209,"Shadowfang Keep"},
		{2017,"Stratholme"},
		{1417,"Sunken Temple"},
		{3845,"Tempest Keep"},
		{3846,"The Arcatraz"},
		{2366,"The Black Morass"},
		{3713,"The Blood Furnace"},
		{3847,"The Botanica"},
		{1581,"The Deadmines"},
		{3849,"The Mechanar"},
		{3714,"The Shattered Halls"},
		{3717,"The Slave Pens"},
		{3715,"The Steamvault"},
		{717,"The Stockade"},
		{3716,"The Underbog"},
		{1337,"Uldaman"},
		{718,"Wailing Caverns"},
		{978,"Zul'Farrak"},
	},
	["Raids"] = {
		{2677,"Blackwing Lair"},
		{3606,"Hyjal Summit"},
		{2562,"Karazhan"},
		{3836,"Magtheridon's Lair"},
		{2717,"Molten Core"},
		{3456,"Naxxramas"},
		{2159,"Onyxia's Lair"},
		{3429,"Ruins of Ahn'Qiraj"},
		{3428,"Temple of Ahn'Qiraj"},
		{3840,"The Black Temple"},
		{3842,"The Eye"},
		{3805,"Zul'Aman"},
		{19,"Zul'Gurub"},
	},
	["Classes"] = {
		{-263,"Druid"},
		{-261,"Hunter"},
		{-161,"Mage"},
		{-141,"Paladin"},
		{-262,"Priest"},
		{-162,"Rogue"},
		{-82,"Shaman"},
		{-61,"Warlock"},
		{-81,"Warrior"},
	},
	["Professions"] = {
		{-181,"Alchemy"},
		{-121,"Blacksmithing"},
		{-304,"Cooking"},
		{-201,"Engineering"},
		{-324,"First Aid"},
		{-101,"Fishing"},
		{-24,"Herbalism"},
		{-182,"Leatherworking"},
		{-264,"Tailoring"},
	},
	["Battlegrounds"] = {
		{-25,"Battlegrounds"},
		{3358,"Arathi Basin"},
		{2597,"Alterac Valley"},
		{3820,"Eye of the Storm"},
		{3277,"Warsong Gulch"},
	},
	["Seasonal"] = {
		{-370,"Brewfest"},
		{-1002,"Children's Week"},
		{-364,"Darkmoon Faire"},
		{-1003,"Hallow's End"},
		{-1005,"Harvest Festival"},
		{-1004,"Love is in the Air"},
		{-366,"Lunar Festival"},
		{-369,"Midsummer Fire Festival"},
		{-1006,"New Year's Eve"},
		{-1001,"Winter Veil"},
	},
	["Miscellaneous"] = {
		{-365,"Ahn'Qiraj War Effort"},
		{-1,"Epic"},
		{-344,"Legendary"},
		{-367,"Reputation"},
		{-368,"Scourge Invasion"},
		{-22,"Seasonal"},
	},
}
local zoneGroupOrder = {
	"Eastern Kingdoms",
	"Kalimdor",
	"Outland",
	"Dungeons",
	"Raids",
	"Classes",
	"Professions",
	"Battlegrounds",
	"Seasonal",
	"Miscellaneous",
}

local function concat(var)
	if type(var) == "number" then
		return var
	elseif type(var) == "string" then
		return var
	elseif type(var) == "table" then
		return "table"
	else
		return "nil"
	end
end

local function getZoneListMenu()
	return EveryQuest.ZoneListMenu or _G.EveryQuestZoneListMenu
end

local function getQuestTitleText(button)
	if not button then return end
	local name = button.GetName and button:GetName()
	local text = button.eqTitleText or (name and _G[name.."NormalText"]) or (button.GetFontString and button:GetFontString())
	if not text and button.CreateFontString then
		text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	end
	if not text then return end

	button.eqTitleText = text
	if button.SetFontString and (not button.GetFontString or button:GetFontString() ~= text) then
		button:SetFontString(text)
	end
	if GameFontNormal and text.SetFontObject then
		text:SetFontObject(GameFontNormal)
	end
	if text.SetDrawLayer then
		text:SetDrawLayer("OVERLAY", 1)
	end
	text:ClearAllPoints()
	text:SetPoint("LEFT", button, "LEFT", 4, 0)
	text:SetPoint("RIGHT", button, "RIGHT", -4, 0)
	text:SetHeight(16)
	text:SetJustifyH("LEFT")
	if text.SetJustifyV then
		text:SetJustifyV("MIDDLE")
	end
	text:Show()
	return text
end

local function setupQuestTitleButton(button)
	if not button then return end
	if button.SetSize then
		button:SetSize(300, 16)
	else
		button:SetWidth(300)
		button:SetHeight(16)
	end
	getQuestTitleText(button)
end

local function setButtonText(button, value)
	if not button then return end
	local text = getQuestTitleText(button)
	if text then
		text:SetText(value or "")
	else
		button:SetText(value or "")
	end
end

local function setButtonTextColor(button, ...)
	local text = getQuestTitleText(button)
	if text and text.SetTextColor then
		text:SetTextColor(...)
	end
end

local function clearButtonTexture(button)
	if not button then return end
	if button.SetNormalTexture then
		button:SetNormalTexture("")
	end
end

local completedQuestFlags
local completedQuestFlagsLoaded = false

local function normalizeCompletedQuestFlags(completedQuestData)
	local completedQuestMap = {}
	for questKey, questValue in pairs(completedQuestData or {}) do
		if questValue == true or questValue == 1 then
			completedQuestMap[tonumber(questKey) or questKey] = true
		elseif type(questValue) == "number" then
			completedQuestMap[questValue] = true
		end
	end
	return completedQuestMap
end

local function getCompletedQuestFlags()
	if completedQuestFlagsLoaded then
		return completedQuestFlags
	end

	completedQuestFlagsLoaded = true
	local completedQuestData = {}
	if GetQuestsCompleted then
		local completedQuestIDs = GetQuestsCompleted(completedQuestData)
		if type(completedQuestIDs) == "table" then
			completedQuestData = completedQuestIDs
		end
		completedQuestFlags = normalizeCompletedQuestFlags(completedQuestData)
		return completedQuestFlags
	end

	if C_QuestLog and C_QuestLog.GetAllCompletedQuestIDs then
		local completedQuestIDs = C_QuestLog.GetAllCompletedQuestIDs(completedQuestData)
		if type(completedQuestIDs) == "table" then
			completedQuestData = completedQuestIDs
		end
		completedQuestFlags = normalizeCompletedQuestFlags(completedQuestData)
		return completedQuestFlags
	end

	return nil
end

local function resetCompletedQuestFlags()
	completedQuestFlags = nil
	completedQuestFlagsLoaded = false
end

local function isQuestFlaggedCompleted(questid)
	questid = tonumber(questid)
	if not questid then
		return false
	end

	local completedQuestMap = getCompletedQuestFlags()
	if completedQuestMap then
		return completedQuestMap[questid] == true
	end

	if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
		return C_QuestLog.IsQuestFlaggedCompleted(questid)
	end
	if IsQuestFlaggedCompleted then
		return IsQuestFlaggedCompleted(questid)
	end
	return false
end

local function isQuestUnavailable(quest)
	local requiredLevel = tonumber(quest and quest.r)
	if not requiredLevel or requiredLevel <= 0 or not UnitLevel then
		return false
	end

	local playerLevel = UnitLevel("player") or 0
	return playerLevel > 0 and playerLevel < requiredLevel
end

local function loadQuestDataAddon(addon)
	if C_AddOns.IsAddOnLoaded(addon) then
		return true
	end
	if not C_AddOns.DoesAddOnExist(addon) then
		return false, "MISSING"
	end

	local playerName = UnitName("player")
	if C_AddOns.GetAddOnEnableState(addon, playerName) == Enum.AddOnEnableState.None then
		C_AddOns.EnableAddOn(addon)
	end

	return C_AddOns.LoadAddOn(addon)
end

local function getQuestLogInfo(index)
	local title, level, questTag, isHeader, isCollapsed, isComplete, frequency, questID = GetQuestLogTitle(index)
	if not title and C_QuestLog.GetInfo then
		return C_QuestLog.GetInfo(index)
	end
	return {
		title = title,
		level = level,
		questTag = questTag,
		isHeader = isHeader,
		isCollapsed = isCollapsed,
		isComplete = isComplete,
		frequency = frequency,
		questID = questID,
	}
end

local function getQuestLogQuestID(index)
	local info = getQuestLogInfo(index)
	return info and tonumber(info.questID)
end

local function isDailyQuest(frequency)
	return frequency == Enum.QuestFrequency.Daily
end

local function setZoneListText(text)
	local zoneListMenu = getZoneListMenu()
	if zoneListMenu and UIDropDownMenu_SetText then
		UIDropDownMenu_SetText(zoneListMenu, text)
	end
end

local function raiseFrame(frame)
	if frame and EveryQuestFrame and frame.SetFrameLevel and EveryQuestFrame.GetFrameLevel then
		frame:SetFrameLevel(EveryQuestFrame:GetFrameLevel() + 2)
	end
end

local function selectZone(group, zone)
	sessionvars.zoneid = zone[1]
	sessionvars.zonegroup = group
	setZoneListText(zone[2])
end

function EveryQuest:EveryQuestInit()
	if sessionvars.initialized then
		return
	end
	self:RegisterEvents()

	EveryQuestTitleText:SetText(L["EveryQuest Log"])

	self:CreateZoneMenu()

	-- Create the "EQ" toggle button for the questlog frame
	EveryQuest.EveryQuestToggleButton = EveryQuest.EveryQuestToggleButton or CreateFrame("Button", nil, QuestLogFrame or UIParent, "UIPanelButtonTemplate")
	EveryQuest.EveryQuestToggleButton:SetWidth(28)
	EveryQuest.EveryQuestToggleButton:SetHeight(18)
	EveryQuest.EveryQuestToggleButton:SetText("EQ")
	EveryQuest.EveryQuestToggleButton:Show()
	EveryQuest.EveryQuestToggleButton:ClearAllPoints()

	-- Create the List toggle button to toggle between quest history and quests in a category
	EveryQuest.ListToggleButton = EveryQuest.ListToggleButton or _G.EveryQuestListToggleButton or CreateFrame("Button", "EveryQuestListToggleButton", EveryQuestFrame, "UIPanelButtonTemplate")
	EveryQuest.ListToggleButton:SetWidth(122)
	EveryQuest.ListToggleButton:SetHeight(21)
	EveryQuest.ListToggleButton:SetText(" ")
	EveryQuest.ListToggleButton:Show()
	raiseFrame(EveryQuest.ListToggleButton)
	EveryQuest.ListToggleButton:ClearAllPoints()
	EveryQuest.ListToggleButton:SetPoint("BOTTOMLEFT",EveryQuestFrame, "BOTTOMLEFT",18,5)
	EveryQuest.ListToggleButton:SetScript("OnClick", function() EveryQuest:List("toggle") end)

	-- Attach the list toggle button in the right place depending on if beql is installed and loaded
	if QuestLogFrame then
		if not C_AddOns.IsAddOnLoaded("beql") then
			EveryQuest.EveryQuestToggleButton:SetPoint("TOPLEFT",QuestLogFrame, "TOPLEFT",72,-15)
		else
			EveryQuest.EveryQuestToggleButton:SetPoint("TOPLEFT",QuestLogFrame, "TOPLEFT",75,-15)
		end
	else
		EveryQuest.EveryQuestToggleButton:Hide()
	end
	EveryQuest.EveryQuestToggleButton:SetScript("OnClick", function() EveryQuest:Toggle()	end)

	-- Set the binding text for the key binding window
	BINDING_HEADER_eqTITLE = L["EveryQuest"]
	BINDING_NAME_eqTOGGLE = L["Toggle Frame"]

	-- Create the 27 "lines" (buttons) in to display text in the main frame
	local button = _G.EveryQuestTitle1 or CreateFrame("Button", "EveryQuestTitle1", EveryQuestFrame,"EveryQuestTitleButtonTemplate")
	button:SetID(1)
	button:Hide()
	raiseFrame(button)
	setupQuestTitleButton(button)
	button:ClearAllPoints()
	button:SetPoint("TOPLEFT", EveryQuestFrame, "TOPLEFT", 19, -75)
	for i = 2, 27 do
		button = _G["EveryQuestTitle" .. i] or CreateFrame("Button", "EveryQuestTitle" .. i, EveryQuestFrame,"EveryQuestTitleButtonTemplate")
		button:SetID(i)
		button:Hide()
		raiseFrame(button)
		setupQuestTitleButton(button)
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", _G["EveryQuestTitle" .. (i-1)], "BOTTOMLEFT", 0, 1)
	end

	-- If the quest log has been scaled, lets scale our frame to match
	if QuestLogFrame and QuestLogFrame.GetScale then
		EveryQuestFrame:SetScale(QuestLogFrame:GetScale())
	end

	local faction = UnitFactionGroup("player")
	if faction == "Alliance" then
		sessionvars.faction = 1
	else
		sessionvars.faction = 2
	end
	if self.db.profile.view == "history" and (not self.db.char.history or not next(self.db.char.history)) then
		self.db.profile.view = "zone"
	end

	self:SelectInitialZone()

	self:ScanQuestLog(true)

	-- Load the saved view
	EveryQuest:List(self.db.profile.view)
	sessionvars.initialized = true
end

function EveryQuest:SelectInitialZone()
	if sessionvars.zoneid and sessionvars.zonegroup then
		return
	end
	local currentZone = GetRealZoneText and GetRealZoneText()
	if currentZone and currentZone ~= "" then
		for group, zones in pairs(zonemenu) do
			for _, zone in pairs(zones) do
				if zone[2] == currentZone then
					selectZone(group, zone)
					return
				end
			end
		end
	end

	local fallbackGroup, fallbackID = "Eastern Kingdoms", 12
	if sessionvars.faction == 2 then
		fallbackGroup, fallbackID = "Kalimdor", 14
	end
	for _, zone in pairs(zonemenu[fallbackGroup]) do
		if zone[1] == fallbackID then
			selectZone(fallbackGroup, zone)
			return
		end
	end
end

function EveryQuest:CreateZoneMenu()
	-- Zone Menu creation
	EveryQuest.ZoneListMenu = getZoneListMenu() or CreateFrame("Frame", "EveryQuestZoneListMenu", EveryQuestFrame, "UIDropDownMenuTemplate")
	EveryQuest.ZoneListMenu:Show()
	raiseFrame(EveryQuest.ZoneListMenu)
	EveryQuest.ZoneListMenu:ClearAllPoints()
	EveryQuest.ZoneListMenu:SetPoint("TOPLEFT",EveryQuestFrame, "TOPLEFT", 115,-40)
	if UIDropDownMenu_SetWidth then
		UIDropDownMenu_SetWidth(EveryQuest.ZoneListMenu, 150)
	end
	if UIDropDownMenu_SetButtonWidth then
		UIDropDownMenu_SetButtonWidth(EveryQuest.ZoneListMenu, 20)
	end
	local zoneListMenuButton = _G[EveryQuest.ZoneListMenu:GetName().."Button"] or EveryQuest.ZoneListMenu.Button
	if zoneListMenuButton then
		zoneListMenuButton:SetScript("OnClick", function()
			ToggleDropDownMenu(1, nil, EveryQuest.ZoneListMenu, EveryQuest.ZoneListMenu, 0, 0)
		end)
	end

	setZoneListText(L["-- Select --"])

	UIDropDownMenu_Initialize(EveryQuest.ZoneListMenu, function(_, level, menuList)
		EveryQuest:InitializeZoneDropdown(level, menuList)
	end)
end

function EveryQuest:InitializeZoneDropdown(level, menuList)
	level = level or 1
	if level == 1 then
		for _, group in ipairs(zoneGroupOrder) do
			if zonemenu[group] then
				local info = UIDropDownMenu_CreateInfo()
				info.text = group
				info.hasArrow = true
				info.menuList = group
				info.notCheckable = true
				UIDropDownMenu_AddButton(info, level)
			end
		end
		local closeInfo = UIDropDownMenu_CreateInfo()
		closeInfo.text = L["Close"]
		closeInfo.notCheckable = true
		closeInfo.func = CloseDropDownMenus
		UIDropDownMenu_AddButton(closeInfo, level)
		return
	end

	local group = menuList
	for _, zone in ipairs(zonemenu[group] or {}) do
		local info = UIDropDownMenu_CreateInfo()
		info.text = zone[2]
		info.checked = sessionvars.zoneid == zone[1]
		info.arg1 = group
		info.arg2 = zone
		info.func = function(_, selectedGroup, selectedZone)
			selectZone(selectedGroup, selectedZone)
			self:Debug("Menuclick - zoneid:"..concat(sessionvars.zoneid).." zonegroup:"..concat(sessionvars.zonegroup))
			if CloseDropDownMenus then
				CloseDropDownMenus()
			end
			self:UpdateFrame()
		end
		UIDropDownMenu_AddButton(info, level)
	end
end

function EveryQuest:RegisterEvents()
	if sessionvars.eventsRegistered then
		return
	end
	sessionvars.eventsRegistered = true
	self:Debug("RegisterEvents")
	-- Register Events
	self:RegisterEvent("QUEST_PROGRESS")
	self:RegisterEvent("QUEST_ACCEPTED")
	self:RegisterEvent("QUEST_COMPLETE")
	self:RegisterEvent("QUEST_FAILED")
	self:RegisterEvent("QUEST_LOG_UPDATE")
	self:RegisterEvent("QUEST_REMOVED")
	self:RegisterEvent("QUEST_TURNED_IN")

	-- fuax self:RegisterEvent("ABANDON_QUEST")
	local function hookAbandonPopup(name)
		local popup = StaticPopupDialogs and StaticPopupDialogs[name]
		if not popup then return end
		popup.OnAccept = function()
			EveryQuest:QUEST_ABANDON(GetAbandonQuestName())
			AbandonQuest()
			PlaySound(SOUNDKIT.IG_QUEST_LOG_ABANDON_QUEST)
		end
	end
	hookAbandonPopup("ABANDON_QUEST")
	hookAbandonPopup("ABANDON_QUEST_WITH_ITEMS")

	-- Hooks
	if QuestFrameCompleteQuestButton then
		QuestFrameCompleteQuestButton:SetScript("OnClick", function() EveryQuest:Hooks_QuestCompleted() end)
	end
	--self:Hook("QuestFrameCompleteQuestButton_OnClick", "Hooks_QuestCompleted", true)
end

function EveryQuest:Toggle()
	if not sessionvars.initialized then
		self:EveryQuestInit()
	end
	if EveryQuestFrame:IsShown() then
		EveryQuestFrame:Hide()
	else
		EveryQuestFrame:Show()	
	end
end

function EveryQuest:SavePosition()
	local Left = EveryQuestFrame:GetLeft()
	local Top = EveryQuestFrame:GetTop()
	if Left and Top then
		self.db.char.saved.eqlogposx = Left
		self.db.char.saved.eqlogposy = Top
	end
end

function EveryQuest_OnShow()
	if self.db.char.saved.eqlogposx and self.db.char.saved.eqlogposy then
		EveryQuestFrame:ClearAllPoints()
		EveryQuestFrame:SetPoint("TOPLEFT","UIParent", "BOTTOMLEFT", self.db.char.saved.eqlogposx, self.db.char.saved.eqlogposy)
	end
	EveryQuest:UpdateFrame()
end

function EveryQuest:NewZone()
	if sessionvars.zoneid ~= nil and sessionvars.zonegroup ~= nil then
		self:Debug("NewZone view:"..concat(self.db.profile.view).." zoneid:"..concat(sessionvars.zoneid).." zonegroup:"..concat(sessionvars.zonegroup))
	else
		self:Debug("NewZone - zoneid and zonegroup are empty")
	end
	if EveryQuestListScrollFrame then
		EveryQuestListScrollFrame:SetVerticalScroll(0)
	end
	self:UpdateFrame()
end

---------------------------------------------------------------------------------------------------------------------------- 

function EveryQuest:GetEveryQuestCount()
	local k,v,j,l
	--local debugg
	local n = 0
	if self.db.profile.view ~= "history" then
		--debugg = "showall"
		if questlist and questlist[questzone] then
			for k, v in pairs (questlist[questzone]) do
				n = n +1
			end
		end
	else
		--debugg = "else"
		for k, v in pairs (self.db.char.history) do
			n = n +1
			if not self.db.char.history[k].Collapsed then
				for j, l in pairs (self.db.char.history[k]) do
					if j ~= "Collapsed" then
						n = n +1
					end
				end
			end
		end
	end
	--if self.db.profile.debug then self:Print("EveryQuest:GetEveryQuestCount("..n..") - "..debugg) end
	return n
end

function EveryQuest_ScrollFrame_Update()
	--self:Debug("ScrollFrame_Update")
	EveryQuest:UpdateFrame()
end

function EveryQuest:timeDiff(timestamp)
    local now = time()
	local amount = now - timestamp
	local value
	local seconds, minutes, hours, days
    --If the difference is positive "ago" - negative "away"

	--amount = amount + DAY + HOUR*5
	
	if amount >= (DAY * 10) then
		return date("%m/%d/%y %I%p", timestamp)
	end
	
	if (amount >= DAY) and (amount < (DAY * 10)) then
		-- between one day and 30 days
		days = math.floor(amount/DAY)
		if days ~= 1 then days = days .. L[" days "] else days = days .. L[" day "] end
		hours = amount%DAY
		hours = math.floor(hours/HOUR)
		if hours ~= 0 then hours = hours .. L[" hr "] else hours = "" end
		return days .. hours .. L["ago"]
		--return "between one day and 30 days"
	end
  
	if (amount < DAY) and (amount >= HOUR) then
		-- between one hour and one day
		--value = string.format("%H hr %M min ago", amount)
		hours = math.floor(amount/HOUR)
		minutes = amount%HOUR
		minutes = math.floor(minutes/MINUTE +.5)
		if minutes ~= 0 then minutes = minutes .. L[" min "] else minutes = "" end
		return hours .. L[" hr "] .. minutes .. L["ago"]
		--return  .. " between one hour and one day"
	end
	
	if (amount < HOUR and amount >= MINUTE) then
		-- between one minute and one hour
		if EveryQuest:round(amount / MINUTE) > 1 then
			return EveryQuest:round(amount / MINUTE) .. L[" minutes ago"]
		else
			return L["1 minute ago"]
		end
	end
	
	if amount > 1 then
		return amount .. L[" seconds ago"]
	else
		return amount .. L[" second ago"]
	end
end

function EveryQuest:round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

-- Get a Quest Data from a LOD module and return the table and the Category
function EveryQuest:GetQuestData(questid, category)
	self:Debug("GetQuestData - questid:"..concat(questid).." category:"..concat(category))
	local zonegroup, zoneid
	
	for k,v in pairs(zonemenu) do -- for each top level category
		for ak,av in pairs(v) do -- for each category
			if av[2] == category then
				zonegroup = k
				zoneid = av[1]
				self:Debug("GetQuestData - zonegroup:"..concat(zonegroup).." zoneid:"..concat(zoneid))
			end
		end
	end
	if zonegroup ~= nil or zoneid ~= nil then
		self:Debug("1GetQuestData - zonegroup:"..concat(zonegroup).." zoneid:"..concat(zoneid))
		quests = self:GetQuestZoneData(zonegroup, zoneid, "zone")
		if quests == false then
			return false
		end
		for k,quest in pairs(quests) do
			--for kt,vt in pairs(quest) do self:Print(kt .. " - " .. vt) end
			if quest.id == questid then
				if self.db.char.history[zoneid] and self.db.char.history[zoneid][questid] then
					self:Debug("GetQuestData (Expanded) - from history - questid:"..concat(questid).." zonegroup:"..concat(zonegroup).." zoneid:"..concat(zoneid))
					return self.db.char.history[zoneid][questid], zoneid
				else
					self:Debug("GetQuestData (Expanded) - from data - questid:"..concat(questid).." zonegroup:"..concat(zonegroup).." zoneid:"..concat(zoneid))
					return quest, zoneid
				end
			end
		end
	end
	-- try an expanded search
	if zonegroup ~= nil then
		local moduledata = self:LoadQuestData(zonegroup)
		if moduledata == false then
			return false
		end
		for k,part in pairs(moduledata) do
			for kt,quest in pairs(part) do
				--for kt,vt in pairs(quest) do self:Print(kt .. " - " .. vt) end
				if quest.id == questid then
					if self.db.char.history[zoneid] and self.db.char.history[zoneid][questid] then
						self:Debug("GetQuestData (Expanded) - from history - questid:"..concat(questid).." zonegroup:"..concat(zonegroup).." zoneid:"..concat(zoneid))
						return self.db.char.history[zoneid][questid], zoneid
					else
						self:Debug("GetQuestData (Expanded) - from data - questid:"..concat(questid).." zonegroup:"..concat(zonegroup).." zoneid:"..concat(zoneid))
						return quest, zoneid
					end
				end
			end
		end
	else
		self:Debug("Expanded Search")
		groups = {"Battlegrounds", "Classes", "Dungeons", "Kalimdor", "Eastern Kingdoms", "Miscellaneous", "Outland", "Professions", "Raids", "Seasonal"}
		for k,v in pairs(groups) do
			local moduledata = self:LoadQuestData(v)
			if moduledata ~= false then
				for k,part in pairs(moduledata) do
					for kt,quest in pairs(part) do
						--for kt,vt in pairs(quest) do self:Print(kt .. " - " .. vt) end
						if quest.id == questid then
							if self.db.char.history[k] and self.db.char.history[k][questid] then
								self:Debug("GetQuestData (Expanded 2x) - from history - questid:"..concat(questid).." zonegroup:"..concat(v).." zoneid:"..concat(k))
								return self.db.char.history[k][questid], k
							else
								self:Debug("GetQuestData (Expanded 2x) - from data - questid:"..concat(questid).." zonegroup:"..concat(v).." zoneid:"..concat(k))
								return quest, k
							end
						end
					end
				end
			end
		end
		
	end
	return false
end

function EveryQuest:GetQuestZoneData(zonegroup, zoneid, view)
	if view == nil then
		view = self.db.profile.view
	end
	if view == "zone" then
		groupdata = self:LoadQuestData(zonegroup)
		if groupdata ~= false then
			return groupdata[zoneid]
		else
			return false
		end
	else
		if self.db.char.history and self.db.char.history[zoneid] then
			return self.db.char.history[zoneid]
		else
			return false
		end
	end
	return false
end

function EveryQuest:ShowListMessage(message)
	for j = 1, 27, 1 do
		questdisplay[j] = nil
	end
	local frame = _G.EveryQuestTitle1
	if frame then
		clearButtonTexture(frame)
		setButtonText(frame, message)
		setButtonTextColor(frame, self:GetColor("FFFFFF"))
		frame:Show()
	end
	for j = 2, 27, 1 do
		local listFrame = _G["EveryQuestTitle"..j]
		if listFrame then
			listFrame:Hide()
		end
	end
end

function EveryQuest:SyncCompletedQuestFlagsForGroup(group, reportStatus)
	if not group or not EveryQuestData or not EveryQuestData[group] then
		return 0, 0, 0, 0
	end

	sessionvars.completedSyncGroups = sessionvars.completedSyncGroups or {}
	if sessionvars.completedSyncGroups[group] then
		return 0, 0, 0, 0
	end
	sessionvars.completedSyncGroups[group] = true

	if self.db.char.history == nil then
		self.db.char.history = {}
	end

	local checked, completed, added, changed = 0, 0, 0, 0
	for zoneid, quests in pairs(EveryQuestData[group]) do
		if type(quests) == "table" then
			for _, quest in pairs(quests) do
				local questid = tonumber(quest and quest.id)
				if questid then
					checked = checked + 1
					if isQuestFlaggedCompleted(questid) then
						completed = completed + 1
						if self.db.char.history[zoneid] == nil then
							self.db.char.history[zoneid] = {}
						end
						local history = self.db.char.history[zoneid][questid]
						if history == nil then
							self.db.char.history[zoneid][questid] = quest
							history = self.db.char.history[zoneid][questid]
							added = added + 1
						elseif history.status ~= 2 then
							changed = changed + 1
						end
						history.status = 2
					end
				end
			end
		end
	end

	if reportStatus then
		self:Print(("EveryQuest: %s completed quest sync: %d checked, %d completed, %d added, %d changed."):format(group, checked, completed, added, changed))
	end
	return checked, completed, added, changed
end

function EveryQuest:LoadQuestData(group)
	if group == nil then
		return false
	end

	local varname = "EveryQuest_"..gsub(group, " ", "_")
	--local varname = "EveryQuest_"..group.." Quests"
	self:Debug("Loading single module: "..concat(varname))
	--local addonname = ("EveryQuest__%s%s_Data"):format(faction:sub(1,1), questtype)
	--if questdata and questdata[varname] then return varname end
	if not EveryQuestData[group] then
		self:Debug("Module "..concat(group).." not loaded")
		EveryQuest:Print(L["Loading "] .. group .. L[" Quest Data"])
		local succ, reason = loadQuestDataAddon(varname)
		if not succ then
			if reason == "MISSING" then
				EveryQuest:Print(L["Requires LOD Module: "] .. varname)
			else
				EveryQuest:Print(L["Could not load "] .. group .. L[" Quest Data"] .. ": " .. concat(reason))
			end
			return false
		end
		collectgarbage("collect")
		if not EveryQuestData[group] then
			EveryQuest:Print(L["Could not load "] .. group .. L[" Quest Data"] .. ": NO_DATA")
			return false
		end
	else
		self:Debug("Module "..concat(group).." is loaded")
	end
	self:SyncCompletedQuestFlagsForGroup(group, true)
	--for k,v in pairs(EveryQuestData) do self:Debug(k) end
	return EveryQuestData[group] --questdata[varname] and varname
end

function EveryQuest:GetStatus(displayid, queststatus)
	local quest = displayid and questdisplay[displayid]
	local zoneid = sessionvars.zoneid
	if quest and zoneid and self.db.char.history[zoneid] and self.db.char.history[zoneid][quest.id] then
		return self.db.char.history[zoneid][quest.id].status == queststatus
	elseif quest and quest.status and quest.status == queststatus then
		return true
	else
		return false
	end
end

local function getNumQuestLogEntries()
	local numEntries = GetNumQuestLogEntries()
	return numEntries or 0
end

local function statusFromQuestLog(isComplete)
	if isComplete == 1 or isComplete == true then
		return 1
	elseif isComplete == -1 then
		return -1
	end
	return 0
end

function EveryQuest:FindQuestLogEntryByID(questid)
	questid = tonumber(questid)
	if not questid then return end

	local category
	for index = 1, getNumQuestLogEntries() do
		local info = getQuestLogInfo(index)
		if info and info.title then
			if info.isHeader then
				category = info.title
			else
				local currentQuestID = tonumber(info.questID)
				if currentQuestID == questid then
					return index, category, info.title, statusFromQuestLog(info.isComplete), isDailyQuest(info.frequency)
				end
			end
		end
	end
end

function EveryQuest:FindQuestLogEntryByName(questName)
	if not questName then return end

	local category
	for index = 1, getNumQuestLogEntries() do
		local info = getQuestLogInfo(index)
		if info and info.title then
			if info.isHeader then
				category = info.title
			elseif info.title == questName then
				local questid = tonumber(info.questID)
				return index, category, questid, statusFromQuestLog(info.isComplete), isDailyQuest(info.frequency)
			end
		end
	end
end

function EveryQuest:GetHistoryByQuestID(questid)
	questid = tonumber(questid)
	if not questid then return end

	for zoneid, quests in pairs(self.db.char.history or {}) do
		if type(quests) == "table" and quests[questid] then
			return quests[questid], zoneid
		end
	end
end

function EveryQuest:AddQuestByID(questid, category, qstatus)
	if self.db.char.history == nil then
		self.db.char.history = {}
	end
	questid = tonumber(questid)
	if not questid then
		return false
	end

	local _, foundCategory, _, foundStatus = self:FindQuestLogEntryByID(questid)
	category = category or foundCategory
	if qstatus == nil then
		qstatus = foundStatus
	end

	local quest, zoneid = self:GetQuestData(questid, category)
	if quest == false then
		return false
	end
	self:Debug("AddQuestByID - questid:"..concat(questid) .. " zoneid:"..concat(zoneid))
	if zoneid ~= nil then
		if self.db.char.history[zoneid] == nil then
			self.db.char.history[zoneid] = {}
		end
		if quest ~= nil then
			if self.db.char.history[zoneid][questid] == nil then
				self.db.char.history[zoneid][questid] = quest
			end
			if qstatus ~= nil then
				self.db.char.history[zoneid][questid].status = qstatus
			end
			self:UpdateFrame()
			return questid, zoneid, self.db.char.history[zoneid][questid].d
		else
			return false
		end
	else
		self:UpdateFrame()
		return false
	end
end

function EveryQuest:MarkQuestByID(questid, status, timestampField, category)
	local savedQuestID, zoneid = self:AddQuestByID(questid, category, status)
	if savedQuestID ~= nil and savedQuestID ~= false and zoneid ~= nil then
		local history = self.db.char.history[zoneid][savedQuestID]
		history.status = status
		if timestampField then
			history[timestampField] = time()
		end
		self:Debug("MarkQuestByID - questid:"..concat(savedQuestID).." zoneid:"..concat(zoneid).." status:"..concat(status))
		self:UpdateFrame()
		return savedQuestID, zoneid
	end
	return false
end

function EveryQuest:MarkQuestByName(questName, status, timestampField)
	local questindex, category, questid = self:FindQuestLogEntryByName(questName)
	if questid then
		return self:MarkQuestByID(questid, status, timestampField, category)
	elseif questindex then
		local savedQuestID, zoneid = self:AddQuest(questindex, category, status)
		if savedQuestID and zoneid then
			local history = self.db.char.history[zoneid][savedQuestID]
			history.status = status
			if timestampField then
				history[timestampField] = time()
			end
			self:UpdateFrame()
			return savedQuestID, zoneid
		end
	end
	return false
end

function EveryQuest:ScanQuestLog(reportStatus)
	local category
	local scanned, added, changed, missing = 0, 0, 0, 0
	local missingQuests = {}
	if reportStatus then
		self:Print("EveryQuest: updating quest history from the quest log...")
	end
	for index = 1, getNumQuestLogEntries() do
		local info = getQuestLogInfo(index)
		if info and info.title then
			if info.isHeader then
				category = info.title
			else
				local questid = tonumber(info.questID)
				if questid then
					scanned = scanned + 1
					local status = statusFromQuestLog(info.isComplete)
					local history = self:GetHistoryByQuestID(questid)
					local oldStatus = history and history.status
					local savedQuestID, zoneid = self:AddQuestByID(questid, category, status)
					if savedQuestID ~= nil and savedQuestID ~= false and zoneid ~= nil then
						if history == nil then
							added = added + 1
						elseif oldStatus ~= status then
							changed = changed + 1
						end
					else
						missing = missing + 1
						table.insert(missingQuests, {
							id = questid,
							title = info.title,
							category = category,
						})
					end
				end
			end
		end
	end
	if reportStatus then
		self:Print(("EveryQuest: quest history updated: %d active, %d added, %d changed, %d missing from database."):format(scanned, added, changed, missing))
		for _, missingQuest in ipairs(missingQuests) do
			local categoryText = missingQuest.category and (" (" .. missingQuest.category .. ")") or ""
			self:Print(("EveryQuest: missing quest %d - %s%s"):format(missingQuest.id, missingQuest.title or L["Unknown"], categoryText))
		end
	end
	return scanned, added, changed, missing
end

function EveryQuest:QUEST_ACCEPTED(questLogIndex, questid)
	questid = tonumber(questid)
	if not questid and questLogIndex then
		questid = getQuestLogQuestID(questLogIndex) or tonumber(questLogIndex)
	end
	if not questid then
		self:ScanQuestLog()
		return
	end

	local _, category = self:FindQuestLogEntryByID(questid)
	local savedQuestID, zoneid = self:AddQuestByID(questid, category, 0)
	if savedQuestID ~= nil and savedQuestID ~= false and zoneid ~= nil then
		self:Debug("QUEST_ACCEPTED - questid:"..concat(savedQuestID).." zoneid:"..concat(zoneid))
	else
		self:Error("Gained Quest: Unable to get Quest Information from DB")
	end
end

function EveryQuest:QUEST_COMPLETE()
	local questtitle = GetTitleText and GetTitleText()
	if questtitle then
		local questid, zoneid = self:MarkQuestByName(questtitle, 1)
		if questid then
			self:Debug("QUEST_COMPLETE - questid:"..concat(questid).." zoneid:"..concat(zoneid))
		end
	end
end

function EveryQuest:QUEST_FAILED(questName)
	questName = questName or (GetTitleText and GetTitleText())
	if questName then
		local questid, zoneid = self:MarkQuestByName(questName, -1, "failed")
		if questid then
			self:Debug("QUEST_FAILED - questid:"..concat(questid).." zoneid:"..concat(zoneid))
		end
	end
end

function EveryQuest:QUEST_ABANDON(questName)
	if questName then
		local questid, zoneid = self:MarkQuestByName(questName, -1, "abandoned")
		if questid then
			self:Debug("QUEST_ABANDON - questid:"..concat(questid).." zoneid:"..concat(zoneid))
		else
			self:Error("Abandon Quest: Unable to get Quest Information from DB")
		end
	end
	self:UpdateFrame()
end

function EveryQuest:QUEST_REMOVED(questid)
	local history = self:GetHistoryByQuestID(questid)
	if history and history.status == 2 then
		return
	end
	self:MarkQuestByID(questid, -1, "abandoned")
end

function EveryQuest:QUEST_TURNED_IN(questid)
	if questid then
		self:QuestTurnedIn(nil, questid)
	end
end

function EveryQuest:QUEST_LOG_UPDATE()
	self:ScanQuestLog()
end

function EveryQuest:QUEST_PROGRESS()
	local questtitle = GetTitleText and GetTitleText()
	if questtitle then
		local questid, zoneid = self:MarkQuestByName(questtitle, 0)
		self:Debug("QUEST_PROGRESS - questid:"..concat(questid).." zoneid:"..concat(zoneid))
	end
end

function EveryQuest:Hooks_QuestCompleted()
	self:Debug("Hooks_QuestCompleted")
	if ( QuestFrameRewardPanel.itemChoice == 0 and GetNumQuestChoices() > 0 ) then
		QuestChooseRewardError();
	else
		self:Debug("Hooks_QuestCompleted success")
		EveryQuest:QuestTurnedIn(GetTitleText())
		GetQuestReward(QuestFrameRewardPanel.itemChoice);
		PlaySound(SOUNDKIT.IG_QUEST_LIST_COMPLETE);
	end
end

function EveryQuest:QuestTurnedIn(questName, questid)
	-- history: Update Status: Quest completed, add completed timestamp
	resetCompletedQuestFlags()
	local category
	if not questid and questName then
		local _, foundCategory, foundQuestID = self:FindQuestLogEntryByName(questName)
		category = foundCategory
		questid = foundQuestID
	end
	if questid then
		local savedQuestID, zoneid, daily = EveryQuest:AddQuestByID(questid, category, 2)
		if savedQuestID ~= nil and savedQuestID ~= false and zoneid ~= nil then
			self:Debug("QuestTurnedIn - questid:"..concat(savedQuestID).." zoneid:"..concat(zoneid))
			self.db.char.history[zoneid][savedQuestID].status = 2
			self.db.char.history[zoneid][savedQuestID].completed = time()
			if daily then
				if self.db.char.history[zoneid][savedQuestID].count ~= nil then
					self.db.char.history[zoneid][savedQuestID].count = self.db.char.history[zoneid][savedQuestID].count +1
				else
					self.db.char.history[zoneid][savedQuestID].count = 1
				end
			end
		else
			self:Error("Turn In Quest: Unable to get Quest Information from DB")
		end
	end
	self:UpdateFrame()
end

function EveryQuest:AddQuest(questindex, category, qstatus)
	if self.db.char.history == nil then
		self.db.char.history = {} 
	end
	if questindex then
		local questid = self:GetQID(questindex)
		if qstatus == nil then
			local _, _, _, foundStatus = self:FindQuestLogEntryByID(questid)
			qstatus = foundStatus
		end
		return self:AddQuestByID(questid, category, qstatus)
	end
end

function EveryQuest:UpdateStatus(displayid, queststatus)
	--questdisplay[displayid]
	local quest = questdisplay[displayid]
	if not quest then return end
	local questid = quest.id
	local zoneid = sessionvars.zoneid
	if not self.db.char.history[zoneid] then
		self.db.char.history[zoneid] = {}
	end
	if not self.db.char.history[zoneid][questid] then
		self.db.char.history[zoneid][questid] = quest
	end
	self.db.char.history[zoneid][questid].status = queststatus
	self:UpdateFrame()
end

function EveryQuest:UpdateFrame()
	if EveryQuestFrame:IsShown() then
		--self:Debug("UpdateFrame")
		local buttonid = 1
		local controli = 0
		local questlist
		if not sessionvars.zonegroup or not sessionvars.zoneid then
			FauxScrollFrame_Update(EveryQuestListScrollFrame,0,27,16)
			self:ShowListMessage(L["Select a zone to show quests"])
			return
		end
		--if self.db.profile.view == "zone" then
			--self:Debug("GetQuestData - zone zoneid:"..sessionvars["zoneid"].." zonegroup:"..sessionvars.zonegroup)
			questlist = self:GetQuestZoneData(sessionvars["zonegroup"], sessionvars["zoneid"])
		--else
			--self:Debug("GetQuestData - history zoneid:"..sessionvars.zoneid.." zonegroup:"..sessionvars.zonegroup)
		--	questlist = self.db.char.history[sessionvars.zoneid]
		--end
		--self:Debug("questlist is type:"..type(questlist))
		local questcount = 0
		local historylist = {}
		if questlist then
			for k, v in pairs (questlist) do
				if v.s then
					if v.s == sessionvars.faction or v.s == 3 or v.s == 0 then
						questcount = questcount +1
						table.insert(historylist, v.id)
					end
				end
			end
		end
		if questcount == 0 then
			FauxScrollFrame_Update(EveryQuestListScrollFrame,0,27,16)
			self:ShowListMessage(L["No quests to display"])
			return
		end
		if self.db.profile.view == "zone" then
			sort(questlist, function(a,b) return EveryQuest:SortTable(a,b) end)
		else
			sort(historylist, function(a,b) return EveryQuest:SortTable(a,b,questlist) end)
		end
		--self:Debug("QuestCount:"..questcount)
		FauxScrollFrame_Update(EveryQuestListScrollFrame,questcount,27,16)
		local scrolloffset = FauxScrollFrame_GetOffset(EveryQuestListScrollFrame)

		if questlist then
			if self.db.profile.view == "zone" then
				for k, quest in pairs (questlist) do
					if quest["s"] then
						if quest["s"] == sessionvars.faction or quest["s"] == 3 or quest["s"] == 0 then
							controli = controli + 1
							if controli > scrolloffset then
								if buttonid > 27 then
									break
								end
								self:UpdateButton(buttonid, quest, k)
								buttonid = buttonid +1
							end
						end
					end
				end
			else
				for k, id in pairs (historylist) do
					if questlist[id] and questlist[id]["s"] then
						if questlist[id]["s"] == sessionvars.faction or questlist[id]["s"] == 3 or questlist[id]["s"] == 0 then
							controli = controli + 1
							if controli > scrolloffset then
								if buttonid > 27 then
									break
								end
								self:UpdateButton(buttonid, questlist[id], k)
								buttonid = buttonid +1
							end
						end
					end
				end
			end
		end
		for j = buttonid, 27 ,1 do
			questdisplay[j] = nil
	ListFrame = _G["EveryQuestTitle"..j]
			ListFrame:Hide()
		end
	end
end

function EveryQuest:SortTable(a,b,questlist)
	if questlist ~= nil then
		--self:Debug("sort:history")
		sorta = questlist[a]
		sortb = questlist[b]
	else
		--self:Debug("sort:zone")
		sorta = a
		sortb = b
	end
	if sorta.d == nil then adaily = 0 else adaily = sorta.d end
	if sortb.d == nil then bdaily = 0 else bdaily = sortb.d end
	if sorta.t == nil then atype = 9999 else atype = sorta.t end
	if sortb.t == nil then btype = 9999 else btype = sortb.t end
	if sorta.l == nil then if sorta.r == nil then alevel = 0 else alevel = sorta.r end else alevel = sorta.l end
	if sortb.l == nil then if sortb.r == nil then blevel = 0 else blevel = sortb.r end else blevel = sortb.l end
	if adaily == bdaily then
		if atype == btype then
			if (alevel == blevel) then-- or (alevel == d.r) or (c.r == d.r) or (c.r == d.r) then
				if sorta.n == sortb.n then
					return false
				elseif sorta.n < sortb.n then
					return true
				elseif sorta.n > sortb.n then
					return false
				end
			elseif alevel > blevel then
				return true
			elseif alevel < blevel then
				return false
			end
		elseif atype < btype then
			return true
		elseif btype > atype then
			return false
		end
	elseif adaily > bdaily then
		return true
	elseif adaily < bdaily then
		return false
	end
end

function EveryQuest:UpdateButton(buttonid, quest, arrayid)
	if questtitle ~= "Collapsed" and self.db.profile.view == "history" or self.db.profile.view == "zone" then
		ListFrame = _G["EveryQuestTitle"..buttonid]
		clearButtonTexture(ListFrame)
		setButtonText(ListFrame, "")
		if not questdisplay[buttonid] then questdisplay[buttonid] = quest end
		if questdisplay[buttonid].id ~= quest.id then questdisplay[buttonid] = nil questdisplay[buttonid] = quest end
		--questdisplay[buttonid].arrayid = arrayid
		if quest["t"] then
			--self:Debug("questtype:"..quest.t)
			qTag = self:QuestType(quest["t"])
		else
			qTag = ""
		end
		if quest["d"] then
			--if qTag == nil then qTag = "" end
			qTag = qTag .. L["Y"]
		end
		local level
		if quest["l"] then
			level = quest["l"]
		else 
			if quest["r"] then
				level = "r"..quest["r"]
			else
				level = "--"
			end
		end
		setButtonText(ListFrame, "["..level..qTag.."] "..quest["n"])
		--r,g,b = EveryQuest:GetQuestColor(zonelist.value, j)
		if self.db.char.history and self.db.char.history[sessionvars.zoneid] and self.db.char.history[sessionvars.zoneid][quest["id"]] then
			local history = self.db.char.history[sessionvars.zoneid][quest["id"]]
			if history["status"] == 1 then -- Completed
				setButtonTextColor(ListFrame, self:GetColor(1))
			elseif history["status"] == -1 then -- Failed/Abandoned
				setButtonTextColor(ListFrame, self:GetColor(-1))
			elseif history["status"] == 2 then -- Turned in
				setButtonTextColor(ListFrame, self:GetColor(2))
			elseif history["status"] == 0 then -- In Progress (Yellow)
				setButtonTextColor(ListFrame, self:GetColor(0))
			elseif history["status"] == nil and isQuestUnavailable(quest) then
				setButtonTextColor(ListFrame, self:GetColor(-2))
			else
				setButtonTextColor(ListFrame, self:GetColor("FFFFFF"))
			end
		elseif isQuestUnavailable(quest) then
			setButtonTextColor(ListFrame, self:GetColor(-2))
		else
			setButtonTextColor(ListFrame, self:GetColor("FFFFFF"))
		end
		--ListFrame:SetTextColor(r,g,b) --ListFrame:SetTextColor(GetDifficultyColor(history[j].Level).r,GetDifficultyColor(history[j].Level).g,GetDifficultyColor(history[j].Level).b)
		ListFrame:Show()
	end
end

function EveryQuest:ButtonEnter(frame)
	local index = frame:GetID()
	local isCollected = false
	local quest = questdisplay[index]
	if not quest or not quest.id then return end
	local zoneid = sessionvars.zoneid
	if not zoneid then return end
	local questid = quest.id
	GameTooltip_SetDefaultAnchor(GameTooltip, frame)
	GameTooltip:SetHyperlink("quest:"..quest.id)
	local queststatus = L["Unknown"]
	local status = 99
	if self.db.char.history[zoneid] and self.db.char.history[zoneid][questid] then
		isCollected = true
		if self.db.char.history[zoneid][questid].status then
			--self:Debug("ButtonEnter - in history buttonid:"..index.." zoneid:"..zoneid.." questid:"..questid)
			status = self.db.char.history[zoneid][questid].status
			if status == -1 then
				queststatus = L["Failed or Abandoned"]
			elseif status == 0 then
				queststatus = L["In Progress"]
			elseif status == 1 then
				queststatus = L["Completed"]
			elseif status == 2 then
				queststatus = L["Turned In"]
			end
		end
	end
	if status == 99 and isQuestUnavailable(quest) then
		queststatus = L["Unavailable"]
		status = -2
	end
	GameTooltip:AddLine(" ", self:GetColor("FFFFFF"))
	--self:Debug("ButtonEnter - buttonid:"..index.." queststatus:"..queststatus.." status:"..status)
	GameTooltip:AddLine(L["Status: "] .. queststatus,self:GetColor(status))
	if isCollected then
		if self.db.char.history[zoneid][quest.id].completed then
			completedline = L["Completed"]
			if self.db.char.history[zoneid][quest.id].count then
				completedline = completedline .. " ("..self.db.char.history[zoneid][quest.id].count.." "..L["Times"]..")"
			end
			completedline = completedline .. ": "..EveryQuest:timeDiff(self.db.char.history[zoneid][quest.id].completed)
			GameTooltip:AddLine(completedline,self:GetColor("FFFFFF"))
			
		else
			if self.db.char.history[zoneid][quest.id].failed then
				GameTooltip:AddLine(L["Failed: "] .. EveryQuest:timeDiff(self.db.char.history[zoneid][quest.id].failed),self:GetColor("FFFFFF"))
			end
			if self.db.char.history[zoneid][quest.id].abandoned then
				GameTooltip:AddLine(L["Abandoned: "] .. EveryQuest:timeDiff(self.db.char.history[zoneid][quest.id].abandoned),self:GetColor("FFFFFF"))
			end
		end
	end
	GameTooltip:Show()
end

function EveryQuest:BuildQuestMenu()
	local function statusLine(text, status)
		return {
			text = text,
			checked = self:GetStatus(clickedID, status),
			isNotRadio = true,
			func = function()
				self:UpdateStatus(clickedID, status)
				if CloseDropDownMenus then
					CloseDropDownMenus()
				end
			end,
		}
	end

	return {
		{
			text = L["Change Status"],
			isTitle = true,
			notCheckable = true,
		},
		statusLine(L["Turned In"], 2),
		statusLine(L["Completed"], 1),
		statusLine(L["In Progress"], 0),
		statusLine(L["Abandoned"], -1),
		statusLine(L["Failed"], -1),
		{
			text = L["Close"],
			notCheckable = true,
			func = function()
				if CloseDropDownMenus then
					CloseDropDownMenus()
				end
			end,
		},
	}
end

function EveryQuest:OpenQuestMenu()
	QuestMenuFrame = QuestMenuFrame or CreateFrame("Frame", "EveryQuestStatusMenu", UIParent, "UIDropDownMenuTemplate")
	local menu = self:BuildQuestMenu()
	if EasyMenu then
		EasyMenu(menu, QuestMenuFrame, "cursor", 0, 0, "MENU")
		return
	end

	UIDropDownMenu_Initialize(QuestMenuFrame, function(_, level)
		for _, item in ipairs(menu) do
			UIDropDownMenu_AddButton(item, level)
		end
	end, "MENU")
	ToggleDropDownMenu(1, nil, QuestMenuFrame, "cursor", 0, 0)
end

function EveryQuest:ButtonClick(frame, button)
	clickedID = frame:GetID()
	local quest = questdisplay[clickedID]
	if not quest or not quest.id then return end

	if button == "LeftButton" then
		if IsModifiedClick() then
			local editBox = ChatEdit_GetActiveWindow and ChatEdit_GetActiveWindow() or ChatFrameEditBox
			if IsModifiedClick("CHATLINK") and editBox and editBox:IsVisible() then
				local questLink = self:CreateQuestLink(quest.id, quest.n, quest.l)
				if questLink then
					ChatEdit_InsertLink(questLink)
				end
			end
		elseif C_AddOns.IsAddOnLoaded("Lightheaded") then
			if C_AddOns.IsAddOnLoaded("beql") then
				beql:Minimize()
			end
			QuestLogFrame:Show()
			LightHeaded:UpdateFrame(quest.id, 1)
			QuestLogFrame:ClearAllPoints()
			QuestLogFrame:SetPoint("TOPLEFT",EveryQuestFrame, "TOPLEFT", 360, 0)
		end
	elseif button == "RightButton" then
		self:OpenQuestMenu()
	end
end

function EveryQuest:List(value)
	--self:Debug("List()")
	if value == "toggle" then
		if self.db.profile.view == "zone" then value = "history" elseif self.db.profile.view == "history" then value = "zone" end
	end
	if value == nil then
		if self.db.profile.view ~= nil then
			value = self.db.profile.view
		else
			value = "history"
		end
	end
	if value == "history" then
		self.db.profile.view = "history"
		self:Debug("ListToggle(history)")
		EveryQuest.ListToggleButton:SetText("Show Zone Quests")
		self:NewZone()
	elseif value == "zone" then
		self.db.profile.view = "zone"
		self:Debug("ListToggle(zone)")
		EveryQuest.ListToggleButton:SetText("Show Quest History")
		self:NewZone()
	end
end

function EveryQuest:GetQID(index)
	if not index then return end

	return getQuestLogQuestID(index)
end

function EveryQuest:CreateQuestLink(questid, questname, questlevel)
	if questlevel == nil then questlevel = 1 end
	self:Debug("CreateQuestLink - quest:"..concat(questid)..":"..concat(questlevel))
	return "\124cffffff00\124Hquest:"..questid..":"..questlevel.."\124h["..questname.."]\124h\124r"
end

function EveryQuest:Debug(string)
	if self.db.profile.debug then  
		self:Print("EveryQuest: "..string)
	end
end

function EveryQuest:Error(string)  
	self:Print("EveryQuest: "..string)
end

function EveryQuest:GetColor(hex)
	if hex == 1 then
		return 0,1,0
	elseif hex == -2 then
		return .5,.5,.5
	elseif hex == -1 then
		return 1,0,0
	elseif hex == 2 then
		return 0,.807,.019
	elseif hex == 0 then
		return 1,1,0
	elseif hex == 99 then -- Unknown
		return 1,1,1
	end
	local rhex, ghex, bhex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6)
	return tonumber(rhex, 16)/255, tonumber(ghex, 16)/255, tonumber(bhex, 16)/255
end

function EveryQuest:QuestType(qtype)
	if qtype == 1 then
		return L["G"], L["Group"]
	elseif qtype == 62 then
		return L["R"], L["Raid"]
	elseif qtype == 85 then
		return L["H"], L["Heroic"]
	elseif qtype == 81 then
		return L["D"], L["Dungeon"]
	elseif qtype == 41 then
		return L["P"], L["PvP"]
	end
end
