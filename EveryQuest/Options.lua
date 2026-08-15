local EveryQuest = EveryQuest
local L = AceLibrary("AceLocale-2.2"):new("EveryQuest")

function EveryQuest:CreateOptions()

EveryQuest.options = { 
    type='group',
    args = {
		Spacing1 = {
			name = " ",
			type = "header",
		},
		toggle = {
			type = 'execute',
			name = "Toggle Frame",
			desc = "Toggle EveryQuest frame",
			func = function() EveryQuest:Toggle() end,
		},
		debug = {
			type = 'toggle',
			name = "Show Debugging Messages",
			desc = "Show Debugging Messages - *WARNING* Spams your default chat frame",
			set = function(newval) EveryQuest.db.profile.debug = newval end,
			get = function() return EveryQuest.db.profile.debug end,
		},
    },
}

end
