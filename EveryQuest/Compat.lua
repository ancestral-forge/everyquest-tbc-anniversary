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
