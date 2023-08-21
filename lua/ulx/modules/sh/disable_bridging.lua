function ulx.disablebridging(calling_ply,target_plys)
	local affected_plys = {}

	for i=1, #target_plys do
		local v = target_plys[i]

		if ulx.getExclusive(v, calling_ply) then
			ULib.tsayError(calling_ply,ulx.getExclusive(v,calling_ply),true)
		else
			v:SetNWBool("TFNoBridging",true)
			table.insert(affected_plys,v)
		end
	end

	ulx.fancyLogAdmin(calling_ply,"#A Disabled Ground Bridging for #T",affected_plys)
end

local disablebridge = ulx.command("Transformers","ulx disablebridge",ulx.disablebridging,{"!nobridge","!disablebridge"})
disablebridge:addParam{type=ULib.cmds.PlayersArg}
disablebridge:defaultAccess(ULib.ACCESS_ADMIN)
disablebridge:help("Disables Ground Bridging for the selected player")

function ulx.enablebridging(calling_ply,target_plys)
	local affected_plys = {}

	for i=1, #target_plys do
		local v = target_plys[i]

		if ulx.getExclusive(v, calling_ply) then
			ULib.tsayError(calling_ply,ulx.getExclusive(v,calling_ply),true)
		else
			v:SetNWBool("TFNoBridging",false)
			table.insert(affected_plys,v)
		end
	end

	ulx.fancyLogAdmin(calling_ply,"#A Enabled Ground Bridging for #T",affected_plys)
end

local enablebridge = ulx.command("Transformers","ulx enablebridge",ulx.enablebridging,{"!yesbridge","!enablebridge"})
enablebridge:addParam{type=ULib.cmds.PlayersArg}
enablebridge:defaultAccess(ULib.ACCESS_ADMIN)
enablebridge:help("Enables Ground Bridging for the selected player")