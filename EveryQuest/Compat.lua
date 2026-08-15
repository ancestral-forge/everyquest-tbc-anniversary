-- Compatibility glue for modern Classic clients that moved addon helpers under C_AddOns.
if C_AddOns then
	local function getAddOnEnableState(addon)
		if not addon or not C_AddOns.GetAddOnEnableState then
			return true
		end
		local playerName = UnitName and UnitName("player") or nil
		local ok, state = pcall(C_AddOns.GetAddOnEnableState, addon, playerName)
		if not ok then
			ok, state = pcall(C_AddOns.GetAddOnEnableState, addon)
		end
		return ok and state and state > 0 or false
	end

	if not GetAddOnInfo and C_AddOns.GetAddOnInfo then
		GetAddOnInfo = function(addon)
			local name, title, notes, loadable, reason, security, newVersion = C_AddOns.GetAddOnInfo(addon)
			if not name then
				return nil
			end
			return name, title, notes, getAddOnEnableState(addon), loadable, reason, security, newVersion
		end
	end
	if not GetAddOnMetadata and C_AddOns.GetAddOnMetadata then
		GetAddOnMetadata = C_AddOns.GetAddOnMetadata
	end
	if not GetNumAddOns and C_AddOns.GetNumAddOns then
		GetNumAddOns = C_AddOns.GetNumAddOns
	end
	if not IsAddOnLoaded and C_AddOns.IsAddOnLoaded then
		IsAddOnLoaded = C_AddOns.IsAddOnLoaded
	end
	if not IsAddOnLoadOnDemand then
		IsAddOnLoadOnDemand = function(addon)
			if not addon or not C_AddOns.IsAddOnLoadOnDemand then
				return false
			end
			local ok, isLoadOnDemand = pcall(C_AddOns.IsAddOnLoadOnDemand, addon)
			return ok and isLoadOnDemand or false
		end
	end
	if not LoadAddOn and C_AddOns.LoadAddOn then
		LoadAddOn = C_AddOns.LoadAddOn
	end
	if not EnableAddOn and C_AddOns.EnableAddOn then
		EnableAddOn = C_AddOns.EnableAddOn
	end
	if not DisableAddOn and C_AddOns.DisableAddOn then
		DisableAddOn = C_AddOns.DisableAddOn
	end
end
