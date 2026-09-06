local function harness(available)
	local messages, delegated = {}, {}
	local env = setmetatable({EveryQuest = {}}, {__index = _G})
	env._G = env
	env.EveryQuest.Print = function(_, message) messages[#messages + 1] = message end
	env.EveryQuest.HandleSlash = function() error("Tab must not execute commands") end
	if available then
		env.ChatEdit_CustomTabPressed = function(box, argument)
			delegated[#delegated + 1] = {box, argument}
			return "original", 42
		end
	end
	local chunk = assert(loadfile("EveryQuest/CommandCompletion.lua"))
	setfenv(chunk, env)
	chunk()
	return env, messages, delegated
end

local env, messages, delegated = harness(true)
local function tab(text, position)
	local box = {text = text, position = position or #text, selected = true}
	function box:GetText() return self.text end
	function box:GetCursorPosition() return self.position end
	function box:SetText(value) self.text = value end
	function box:ClearHighlightText() self.selected = false end
	function box:SetCursorPosition(value) self.position = value end
	local result, second = env.ChatEdit_CustomTabPressed(box, "argument")
	return box, result, second
end

for _, case in ipairs({
	{"/everyquest", "/everyquest "},
	{"/everyquest a", "/everyquest api "},
	{"/everyquest api au", "/everyquest api audit "},
	{"/everyquest api d", "/everyquest api discover "},
	{"/everyquest api ov", "/everyquest api overlay "},
	{"/EVERYQUEST  API  Au", "/EVERYQUEST  API  audit "},
	{"/everyquest api audit st", "/everyquest api audit status "},
	{"/everyquest api discover can", "/everyquest api discover cancel "},
	{"/everyquest api discover cl", "/everyquest api discover clear "},
}) do
	local box, result = tab(case[1])
	assert(result == true and box.text == case[2], case[1])
	assert(box.position == #box.text and not box.selected)
end
assert(#delegated == 0)

for _, text in ipairs({"/everyquest api ", "/everyquest api audit c", "/everyquest api discover ", "/everyquest api discover 100", "/everyquest api discover 100 "}) do
	local count = #messages
	local box, result = tab(text)
	assert(result == true and box.text == text and #messages == count + 1)
end
assert(messages[#messages]:find("<first> <last>", 1, true))

for _, text in ipairs({"hello", "/w Name", "/everyquestish api au", "/other api au", "", "/everyquest debug ", "/everyquest api overlay "}) do
	local count = #delegated
	local box, result, second = tab(text)
	assert(result == "original" and second == 42 and box.text == text and box.selected)
	assert(#delegated == count + 1 and delegated[#delegated][2] == "argument")
end
local box, result = tab("/everyquest api au", 5)
assert(result == "original" and box.text == "/everyquest api au" and box.selected)

-- Any edit box, including temporary chat, uses the same scoped extension.
box, result = tab("/everyquest api dis")
assert(result == true and box.text == "/everyquest api discover ")
local missing, warnings = harness(false)
assert(missing.ChatEdit_CustomTabPressed == nil and #warnings == 1)
assert(missing.EveryQuest:CompleteCommandText("/everyquest api au"))
print("Command completion tests passed.")
