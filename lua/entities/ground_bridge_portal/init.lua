AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile()
include('shared.lua')

if(WireLib == nil) then return end

ENT.WireDebugName = "Ground Bridge Portal"

function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create("ground_bridge_portal")
	ent:SetPos(tr.HitPos + Vector(0, 0, 20))
	ent:Spawn()
	return ent 
end 

function ENT:Initialize()
	if(!util.IsValidModel("models/props_random/whirlpool22_narrow.mdl")) then
		self.Entity.Owner:SendLua("GAMEMODE:AddNotify(\"Missing Whirlpool Model! Check your chat!\", NOTIFY_ERROR, 8); surface.PlaySound( \"buttons/button2.wav\" )")
		self.Entity.Owner:PrintMessage(HUD_PRINTTALK,"You're missing the Whirlpool addon, install it at https://steamcommunity.com/sharedfiles/filedetails/?id=1524799867")
		self.Entity:Remove()

		return
	end
	
	util.PrecacheModel("models/props_random/whirlpool22_narrow.mdl")
	
	self.Entity:SetModel("models/props_random/whirlpool22_narrow.mdl")
	
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
	
	self.Entity:DrawShadow(false)
	
	local phys = self.Entity:GetPhysicsObject()
	
	if(phys:IsValid()) then
		phys:SetMass(100)
		phys:EnableGravity(true)
		phys:Wake()
		phys:EnableMotion(false)
	end

	self.Entity:SetNWBool("On",true)

	timer.Create("BridgeIdleSound"..self:EntIndex(),1,1,function()
		self.Entity:EmitSound("ambience/dronemachine3.wav")
	end)
end

function ENT:OnRemove()
	self:StopSound("ambience/dronemachine3.wav")
end