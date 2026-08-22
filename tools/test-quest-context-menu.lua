local sourceFile = assert(io.open("EveryQuest/Everyquest.lua", "r"))
local source = sourceFile:read("*a")
sourceFile:close()

local menuSource = assert(source:match("(local function initializeQuestDropdown.-)\nfunction EveryQuest:ButtonClick"))
local calls = {}
local menuFrame = {}
local EveryQuest = {}

function EveryQuest:BuildQuestMenu(displayID)
	assert(displayID == 8)
	return {
		{text = "Change Status", isTitle = true},
		{},
		{text = "Turned In", checked = true},
	}
end

local environment = {
	EveryQuest = EveryQuest,
	UIParent = {},
	ipairs = ipairs,
	CreateFrame = function(frameType, name, parent, template)
		assert(frameType == "Frame")
		assert(name == "EveryQuestStatusMenu")
		assert(parent ~= nil)
		assert(template == "UIDropDownMenuTemplate")
		calls.created = (calls.created or 0) + 1
		return menuFrame
	end,
	UIDropDownMenu_Initialize = function(frame, initializer, displayMode, level, menuItems)
		assert(frame == menuFrame)
		assert(displayMode == "MENU")
		assert(level == nil)
		calls.menuItems = menuItems
		initializer(frame, 1)
	end,
	UIDropDownMenu_AddButton = function(item, level)
		assert(level == 1)
		calls[#calls + 1] = item
	end,
	ToggleDropDownMenu = function(level, value, frame, anchor, x, y, menuItems)
		assert(level == 1 and value == nil)
		assert(frame == menuFrame)
		assert(anchor == "cursor" and x == 0 and y == 0)
		assert(menuItems == calls.menuItems)
		calls.toggled = true
	end,
}

local loader = assert(loadstring("local QuestMenuFrame\n" .. menuSource))
setfenv(loader, environment)
loader()

EveryQuest:OpenQuestMenu(8)
assert(calls.created == 1, "quest context menu frame must be created")
assert(menuFrame.displayMode == "MENU", "quest context menu must use menu styling")
assert(menuFrame.menuItems == calls.menuItems, "quest context menu items must be available to the initializer")
assert(calls.toggled, "quest context menu must be shown at the cursor")
assert(#calls == 2, "only menu entries with text must be added")
assert(calls[1].index == 1 and calls[2].index == 3, "menu entry indexes must match their source positions")

EveryQuest:OpenQuestMenu(8)
assert(calls.created == 1, "quest context menu frame must be reused")

print("Quest context menu tests passed.")
