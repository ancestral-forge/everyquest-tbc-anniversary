std = "lua51"
max_line_length = false

exclude_files = {
	".git",
	".github",
}

ignore = {
	"212/self",
	"212/event",
	"212/arrayid",
	"21./_.*",
}

globals = {
	"EveryQuest",
	"EveryQuestData",
	"EveryQuestDB",
	"EveryQuestDBPC",
	"EveryQuest_Locale",
	"EveryQuest_OnShow",
	"EveryQuest_ScrollFrame_Update",
	"BINDING_HEADER_eqTITLE",
	"BINDING_NAME_eqTOGGLE",
	"SlashCmdList",
}

read_globals = {
	-- WoW Lua aliases
	"date",
	"time",

	-- Addon lifecycle and UI
	"C_AddOns",
	"C_QuestLog",
	"CloseDropDownMenus",
	"CreateFrame",
	"DEFAULT_CHAT_FRAME",
	"EasyMenu",
	"Enum",
	"FauxScrollFrame_GetOffset",
	"FauxScrollFrame_Update",
	"GameFontNormal",
	"GameTooltip",
	"GameTooltip_SetDefaultAnchor",
	"GetNumQuestLogEntries",
	"GetQuestLogTitle",
	"GetRealZoneText",
	"GetScreenWidth",
	"GetTitleText",
	"hooksecurefunc",
	"IsModifiedClick",
	"ToggleDropDownMenu",
	"UIParent",
	"UISpecialFrames",
	"UIDROPDOWNMENU_OPEN_MENU",
	"UIDropDownMenu_AddButton",
	"UIDropDownMenu_CreateInfo",
	"UIDropDownMenu_Initialize",
	"UIDropDownMenu_SetButtonWidth",
	"UIDropDownMenu_SetText",
	"UIDropDownMenu_SetWidth",
	"UnitFactionGroup",
	"UnitLevel",
	"UnitName",

	-- Chat links
	"ChatEdit_GetActiveWindow",
	"ChatEdit_InsertLink",

	-- XML-created frames
	"EveryQuestExitButton",
	"EveryQuestFrame",
	"EveryQuestListScrollFrame",
	"EveryQuestTitleText",
	"QuestLogFrame",
}
