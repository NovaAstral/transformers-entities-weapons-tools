AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile()
include('shared.lua')

DEFINE_BASECLASS("base_gmodentity")

ENT.WireDebugName = "Ground Bridge Portal"

function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create("ground_bridge_portal")
	ent:SetPos(tr.HitPos + Vector(0, 0, 20))
	ent:Spawn()
	return ent 
end 

function ENT:Initialize()
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

	self.Entity:SetNWBool("On",false)
end

function ENT:OnRemove()
	self:StopSound("ambience/dronemachine3.wav")
end