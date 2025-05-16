AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Space Bridge Controller"
ENT.Author = "Nova Astral"
ENT.Category = ""
ENT.Contact	= "https://github.com/NovaAstral"
ENT.Purpose	= "nyoom"
ENT.Instructions = "https://www.youtube.com/watch?v=EfXJ6S9VPbI"

ENT.Spawnable = false

if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local ent = ents.Create("space_bridge_controller")
		ent:SetPos(tr.HitPos + Vector(0, 0, 20))
		ent:SetVar("Owner",ply)
		ent:Spawn()
		return ent 
	end
end

--This should allow any old ground bridge controllers in dupes to spawn as space bridge controllers instead

--replace this with ENTITY:PreEntityCopy as that seems to be able to properly replace?