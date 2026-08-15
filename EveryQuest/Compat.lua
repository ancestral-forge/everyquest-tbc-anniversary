-- Compatibility glue for modern Classic clients that moved addon helpers under C_AddOns.
if C_AddOns then
	if not GetAddOnInfo and C_AddOns.GetAddOnInfo then
		GetAddOnInfo = C_AddOns.GetAddOnInfo
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
