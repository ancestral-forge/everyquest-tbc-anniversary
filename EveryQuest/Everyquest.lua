--[[
Quest Status:
-1 = Failed, Abandoned
0 = In Progress
1 = Completed
2 = Turned In

Rock("LibRockConfig-1.0").OpenConfigMenu(EveryQuest)
--]]

local EveryQuest, self = EveryQuest, EveryQuest
local EveryQuestQ, EveryQuestQ = EveryQuestQ, EveryQuestQ
local EveryQuestdewdrop = AceLibrary("Dewdrop-2.0")
local L = AceLibrary("AceLocale-2.2"):new("EveryQuest")
local questdisplay = {}
local sorta = {}
local sortb = {}
local SECOND = 1
local MINUTE = 60
local HOUR = 3600
local DAY = 86400
local clickedID
local sessionvars = {}
local QuestMenu = { -- Rightclick quest menu
	type = 'group',
	args = {
		turnedin = {
			type = 'toggle',
			name = L["Turned In"],
			desc = L["Turned In"],
			order = 1,
			get = function() if EveryQuest:GetStatus(clickedID, 2) then return true else return false end end,
			set = function() EveryQuest:UpdateStatus(clickedID, 2) end,
		},
		completed = {
			type = 'toggle',
			name = L["Completed"],
			desc = L["Completed"],
			order = 3,
			get = function() if EveryQuest:GetStatus(clickedID, 1) then return true else return false end end,
			set = function() EveryQuest:UpdateStatus(clickedID, 1) end,
		},
		inprogress = {
			type = 'toggle',
			name = L["In Progress"],
			desc = L["In Progress"],
			order = 5,
			get = function() if EveryQuest:GetStatus(clickedID, 0) then return true else return false end end,
			set = function() EveryQuest:UpdateStatus(clickedID, 0) end,
		},
		abandoned = {
			type = 'toggle',
			name = L["Abandoned"],
			desc = L["Abandoned"],
			order = 7,
			get = function() if EveryQuest:GetStatus(clickedID, -1) then return true else return false end end,
			set = function() EveryQuest:UpdateStatus(clickedID, -1) end,
		},
		failed = {
			type = 'toggle',
			name = L["Failed"],
			desc = L["Failed"],
			order = 9,
			get = function() if EveryQuest:GetStatus(clickedID, -1) then return true else return false end end,
			set = function() EveryQuest:UpdateStatus(clickedID, -1) end,
		},
		close = {
			type = 'execute',
			name = L["Close"],
			desc = L["Close"],
			order = 10,
			func = function() EveryQuestdewdrop:Close() end,
		},
	},
}
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
	return EveryQuest.ZoneListMenu or getglobal("EveryQuestdewdropZoneListMenu")
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
	EveryQuest.ListToggleButton = EveryQuest.ListToggleButton or getglobal("EveryQuestListToggleButton") or CreateFrame("Button", "EveryQuestListToggleButton", EveryQuestFrame, "UIPanelButtonTemplate")
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
		if not IsAddOnLoaded("beql") then
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
	local button = getglobal("EveryQuestTitle1") or CreateFrame("Button", "EveryQuestTitle1", EveryQuestFrame,"EveryQuestTitleButtonTemplate")
	button:SetID(1)
	button:Hide()
	raiseFrame(button)
	button:ClearAllPoints()
	button:SetPoint("TOPLEFT", EveryQuestFrame, "TOPLEFT", 19, -75)
	for i = 2, 27 do
		button = getglobal("EveryQuestTitle" .. i) or CreateFrame("Button", "EveryQuestTitle" .. i, EveryQuestFrame,"EveryQuestTitleButtonTemplate")
		button:SetID(i)
		button:Hide()
		raiseFrame(button)
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", getglobal("EveryQuestTitle" .. (i-1)), "BOTTOMLEFT", 0, 1)
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
	EveryQuest.ZoneListMenu = getZoneListMenu() or CreateFrame("Frame", "EveryQuestdewdropZoneListMenu", EveryQuestFrame, "UIDropDownMenuTemplate")
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
	local zoneListMenuButton = getglobal(EveryQuest.ZoneListMenu:GetName().."Button") or EveryQuest.ZoneListMenu.Button
	if zoneListMenuButton then
		zoneListMenuButton:SetScript("OnClick", function() if EveryQuestdewdrop:IsOpen() then EveryQuestdewdrop:Close() else EveryQuestdewdrop:Open(EveryQuest.zonemenuloc) end end)
	end
	
	-- Create the point where the zone menu will open and display itself
	EveryQuest.zonemenuloc = CreateFrame("Frame", nil, EveryQuestFrame)
	EveryQuest.zonemenuloc:SetWidth(2)
	EveryQuest.zonemenuloc:SetHeight(2)
	EveryQuest.zonemenuloc:ClearAllPoints()
	EveryQuest.zonemenuloc:SetPoint("BOTTOMRIGHT", zoneListMenuButton or EveryQuest.ZoneListMenu)
	
	local info = {
		type = 'group',
		args = {},
	}
	
	setZoneListText(L["-- Select --"])
	
	local i, j = 0, 0
	for k, v in pairs (zonemenu) do 
		i = i +1
		info.args[i] = {
			type = 'group',
			name = k,
			desc = k,
			order = 1,
			args = {}
		}
		for zk, zv in pairs (zonemenu[k]) do
			j = j +1
			info.args[i].args[j] = {
				type = 'toggle',
				name = zv[2],
				desc = zv[2],
				get = function() if sessionvars.zoneid == zv[1] then return true else return false end end,
				set = function() sessionvars.zoneid = zv[1] sessionvars.zonegroup = k self:Debug("Menuclick - zoneid:"..concat(sessionvars.zoneid).." zonegroup:"..concat(sessionvars.zonegroup)) setZoneListText(zv[2]) EveryQuestdewdrop:Close() self:UpdateFrame() end,
			}
		end
		j = 0
	end
	info.args[i+1] = {
			type = 'execute',
			name = L["Close"],
			desc = L["Close"],
			order = 10,
			func = function() EveryQuestdewdrop:Close() end,
		}
	EveryQuestdewdrop:Register(EveryQuest.zonemenuloc, 'children', function() EveryQuestdewdrop:FeedAceOptionsTable(info) end)
end
function EveryQuest:RegisterEvents()
	self:Debug("RegisterEvents")
	-- Register Events
	self:RegisterEvent("QUEST_PROGRESS")
	--self:RegisterEvent("QUEST_COMPLETE")
    self:RegisterEvent("Quixote_Quest_Complete")
	self:RegisterEvent("Quixote_Quest_Failed")
	self:RegisterEvent("Quixote_Quest_Gained")

	-- fuax self:RegisterEvent("ABANDON_QUEST")
	local function hookAbandonPopup(name)
		local popup = StaticPopupDialogs and StaticPopupDialogs[name]
		if not popup then return end
		popup.OnAccept = function()
			EveryQuest:QUEST_ABANDON(GetAbandonQuestName())
			AbandonQuest()
			EveryQuest_PlaySound("IG_QUEST_LOG_ABANDON_QUEST", "igQuestLogAbandonQuest")
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
	local frame = getglobal("EveryQuestTitle1")
	if frame then
		frame:SetNormalTexture("")
		frame:SetText(message)
		frame:SetTextColor(self:GetColor("FFFFFF"))
		frame:Show()
	end
	for j = 2, 27, 1 do
		local listFrame = getglobal("EveryQuestTitle"..j)
		if listFrame then
			listFrame:Hide()
		end
	end
end

function EveryQuest:LoadQuestData(group)
	if group ~= nil then
		
		local varname = "EveryQuest_"..gsub(group, " ", "_")
		--local varname = "EveryQuest_"..group.." Quests"
		self:Debug("Loading single module: "..concat(varname))
		--local addonname = ("EveryQuest__%s%s_Data"):format(faction:sub(1,1), questtype)
		local _, _, _, enabled = GetAddOnInfo(varname)
		--if questdata and questdata[varname] then return varname end
		if not EveryQuestData[group] then
			
			self:Debug("Module "..concat(group).." not loaded")
			if enabled then
				EveryQuest:Print(L["Loading "] .. group .. L[" Quest Data"])
				local succ,reason = LoadAddOn(varname)
				if not succ then
					EveryQuest:Print(L["Could not load "] .. group .. L[" Quest Data"], reason)
					return false
				end
				collectgarbage("collect")
			else
				EveryQuest:Print(L["Requires LOD Module: "] .. varname)
				return false
			end
		else
			self:Debug("Module "..concat(group).." is loaded")
		end
		--for k,v in pairs(EveryQuestData) do self:Debug(k) end
		--questdata[varname] = getglobal(varname)
		return EveryQuestData[group] --questdata[varname] and varname
	else
		
	end
	return false
end

function EveryQuest:GetStatus(displayid, queststatus)
	local quest = displayid and questdisplay[displayid]
	if quest and quest.status and quest.status == queststatus then
		return true
	else
		return false
	end
end
function EveryQuest:Quixote_Quest_Complete(questname, questindex)
	-- history: Update Status: Quest Finished, not turned in
	local _, _, _, _, _, _, category = EveryQuestQ:GetQuestById(questindex)
	local questid, zoneid = EveryQuest:AddQuest(questindex, category)
	if questid ~= nil and questid ~= false and zoneid ~= nil then
		self.db.char.history[zoneid][questid].status = 1
		self:Debug("Quixote_Quest_Complete - questid:"..concat(questid).." zoneid:"..concat(zoneid))
		self:UpdateFrame()
	else
		self:Error("Complete Quest: Unable to get Quest Information from DB")
	end
end

function EveryQuest:Quixote_Quest_Gained(questname, questindex, numObjectives)
	-- history: Add Quest to history, update Status: In Progress
	local _, _, _, _, _, _, category = EveryQuestQ:GetQuestById(questindex)
	local questid, zoneid = EveryQuest:AddQuest(questindex, category)
	
	if questid ~= nil and questid ~= false and zoneid ~= nil then
		self:Debug("Quixote_Quest_Gained - questid:"..concat(questid).." zoneid:"..concat(zoneid))
		if questid then
			self.db.char.history[zoneid][questid].status = 0
			self:Debug("Quixote_Quest_Gained - set status")--..questid.." zoneid:"..zoneid)
		else
			self:Debug("Quixote_Quest_Gained - !!failed!!")
		end
		self:UpdateFrame()
	else
		self:Error("Gained Quest: Unable to get Quest Information from DB")
	end
end

function EveryQuest:Quixote_Quest_Failed(questname, questindex)
	-- history: Update Status: Failed, failed counter +1
	local _, _, _, _, _, _, category = EveryQuestQ:GetQuestById(questindex)
	local questid, zoneid = EveryQuest:AddQuest(questindex, category)
	if questid ~= nil and questid ~= false and zoneid ~= nil then
		self.db.char.history[zoneid][questid].status = -1
		self.db.char.history[zoneid][questid].failed = time()
		self:Debug("Quixote_Quest_Failed - questid:"..concat(questid).." zoneid:"..concat(zoneid))
		self:UpdateFrame()
	else
		self:Error("Failed Quest: Unable to get Quest Information from DB")
	end
end

function EveryQuest:QUEST_ABANDON(questName)
	local _, _, _, _, _, _, category, questindex = EveryQuestQ:GetQuestByName(questName)
	if questindex then
		local questid, zoneid = EveryQuest:AddQuest(questindex, category)
		if questid ~= nil and questid ~= false and zoneid ~= nil then
			self:Debug("QUEST_ABANDON - questid:"..concat(questid).." zoneid:"..concat(zoneid))
			self.db.char.history[zoneid][questid].status = -1
			self.db.char.history[zoneid][questid].abandoned = time()
		else
			self:Error("Abandon Quest: Unable to get Quest Information from DB")
		end
	end
	self:UpdateFrame()
end

function EveryQuest:QUEST_PROGRESS()
	local questtitle = GetTitleText()
	local _, _, _, _, _, _, category, questindex = EveryQuestQ:GetQuestByName(questtitle)
	if questindex then
		local questid, zoneid = EveryQuest:AddQuest(questindex, category)
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
		EveryQuest_PlaySound("IG_QUEST_LIST_COMPLETE", "igQuestListComplete");
	end
end

function EveryQuest:QuestTurnedIn(questName)
	local _, _, _, _, _, _, category, questindex = EveryQuestQ:GetQuestByName(questName)
	-- history: Update Status: Quest completed, add completed timestamp
	if questindex then
		local questid, zoneid, daily = EveryQuest:AddQuest(questindex, category)
		if questid ~= nil and questid ~= false and zoneid ~= nil then
			self:Debug("QuestTurnedIn - questid:"..concat(questid).." zoneid:"..concat(zoneid))
			self.db.char.history[zoneid][questid].status = 2
			self.db.char.history[zoneid][questid].completed = time()
			if daily then
				if self.db.char.history[zoneid][questid].count ~= nil then
					self.db.char.history[zoneid][questid].count = self.db.char.history[zoneid][questid].count +1
				else
					self.db.char.history[zoneid][questid].count = 1
				end
			end
		else
			self:Error("Turn In Quest: Unable to get Quest Information from DB")
		end
	end
	self:UpdateFrame()
end

function EveryQuest:AddQuest(questindex, category)
	if self.db.char.history == nil then
		self.db.char.history = {} 
	end
	if questindex then
		local questid = self:GetQID(questindex)
		local quest, zoneid = self:GetQuestData(questid, category)
		if quest == false then
			return false
		end
		self:Debug("AddQuest - questid:"..concat(questid) .. " zoneid:"..concat(zoneid))
		if zoneid ~= nil then
			if self.db.char.history[zoneid] == nil then
				self.db.char.history[zoneid] = {}
			end
			if quest ~= nil then
				if self.db.char.history[zoneid][questid] == nil then
					local _, _, _, _, qstatus = EveryQuestQ:GetQuestById(questindex)
					self.db.char.history[zoneid][questid] = quest
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
			ListFrame = getglobal("EveryQuestTitle"..j)
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
		ListFrame = getglobal("EveryQuestTitle"..buttonid)
		ListFrame:SetNormalTexture("")
		ListFrame:SetText("")
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
		ListFrame:SetText("["..level..qTag.."] "..quest["n"])
		--r,g,b = EveryQuest:GetQuestColor(zonelist.value, j)
		if self.db.char.history[sessionvars.zoneid] and self.db.char.history[sessionvars.zoneid][quest["id"]] then
			local history = self.db.char.history[sessionvars.zoneid][quest["id"]]
			if history["status"] == 1 then -- Completed
				ListFrame:SetTextColor(self:GetColor(1))
			elseif history["status"] == -1 then -- Failed/Abandoned
				ListFrame:SetTextColor(self:GetColor(-1))
			elseif history["status"] == 2 then -- Turned in
				ListFrame:SetTextColor(self:GetColor(2))
			elseif history["status"] == 0 then -- In Progress (Yellow)
				ListFrame:SetTextColor(self:GetColor(0))
			elseif not history["status"] then
				ListFrame:SetTextColor(self:GetColor("FFFFFF"))
			elseif history["status"] == nil then
				ListFrame:SetTextColor(self:GetColor("FFFFFF"))
			end
		else
			ListFrame:SetTextColor(self:GetColor("FFFFFF"))
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
	local queststatus = "Unknown"
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

function EveryQuest:ButtonClick(frame, button)
	clickedID = frame:GetID()
	local quest = questdisplay[clickedID]
	if not quest or not quest.id then return end
	if button == "LeftButton" then
		if ( IsModifiedClick() ) then
			if ( IsModifiedClick("CHATLINK") and ChatFrameEditBox:IsVisible() ) then
				local questLink = self:CreateQuestLink(quest.id, quest.n, quest.l);
				if ( questLink ) then
					ChatEdit_InsertLink(questLink);
				end
			end
		else
			-- open lightheaded if enabled
			if IsAddOnLoaded("Lightheaded") then
				if IsAddOnLoaded("beql") then
					beql:Minimize()
				end
				QuestLogFrame:Show()
				LightHeaded:UpdateFrame(quest.id, 1)
				QuestLogFrame:ClearAllPoints()
				QuestLogFrame:SetPoint("TOPLEFT",EveryQuestFrame, "TOPLEFT", 360, 0)
			end
		end
	elseif button == "RightButton" then
		-- open quest menu
		if not ddframe then
				ddframe = CreateFrame("Frame", nil, UIParent)
				ddframe:SetWidth(2)
				ddframe:SetHeight(2)
				ddframe:SetPoint("BOTTOMLEFT", GetCursorPosition())
				ddframe:SetClampedToScreen(true)
				EveryQuestdewdrop:Register(ddframe, 'dontHook', true, 'children', function() EveryQuestdewdrop:FeedAceOptionsTable(QuestMenu) end)
		end
		local x,y = GetCursorPosition()
		ddframe:SetPoint("BOTTOMLEFT", x / UIParent:GetScale(), y / UIParent:GetScale())
		EveryQuestdewdrop:Open(ddframe)
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
	--local index = GetQuestLogSelection()
	if not index then return end

	local questID = EveryQuest_GetQuestLogQuestID and EveryQuest_GetQuestLogQuestID(index)
	if questID then return questID end

	if not GetQuestLink then return end
	local link = GetQuestLink(index)
	if not link then return end

	return tonumber(link:match(":(%d+):"))
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
