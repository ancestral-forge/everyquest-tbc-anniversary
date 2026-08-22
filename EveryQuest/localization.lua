EveryQuest_Locale = {
		["Change Status"] = true,
		["Completed"] = true,
		["Ready to Turn In"] = true,
		["In Progress"] = true,
		["Unavailable"] = true,
		["Unknown"] = true,
	["Clear Status"] = true,
	["Abandoned"] = true,
	["Failed"] = true,
	["Close"] = true,

	["EveryQuest Log"] = true,
	["EveryQuest"] = true,
	["Toggle Frame"] = true,
	["Current Zone"] = true,

	["-- Select --"] = true,
	["Select a zone to show quests"] = true,
	["No quests to display"] = true,
	["Show Quest History"] = true,
	["Show Zone Quests"] = true,
	["Loading "] = true,
	["Could not load "] = true,
	["Failed or Abandoned"] = true,

	["Failed: "] = true,
	["Abandoned: "] = true,
	["Completed: "] = true,
	["Status: "] = true,

	[" days "] = true,
	[" day "] = true,
	[" hr "] = true,
	["ago"] = true,
	[" min "] = true,
	[" minutes ago"] = true,
	["1 minute ago"] = true,
	[" seconds ago"] = true,
	[" second ago"] = true,
	[" Quest Data"] = true,

	["Requires LOD Module: "] = true,
	["Missing LOD Module: "] = true,
	["Disabled LOD Module: "] = true,
	["G"] = true,
	["Group"] = true,
	["R"] = true,
	["Raid"] = true,
	["H"] = true,
	["Heroic"] = true,
	["D"] = true,
	["Dungeon"] = true,
	["E"] = true,
	["Escort"] = true,
		["P"] = true,
		["PvP"] = true,
		["Y"] = true,
		["Daily"] = true,
		["Times"] = true,
}

for key, value in pairs(EveryQuest_Locale) do
	if value == true then
		EveryQuest_Locale[key] = key
	end
end

setmetatable(EveryQuest_Locale, {
	__index = function(_, key)
		return key
	end
})
