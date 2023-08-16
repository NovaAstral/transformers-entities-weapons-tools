AddCSLuaFile()
if CLIENT then
    hook.Add( "PreDrawHalos", "GroundBridgeHalo", function()
	    halo.Add(ents.FindByClass("ground_bridge_portal"),Color(0,255,158),2,2,2,true,false)
    end)
end