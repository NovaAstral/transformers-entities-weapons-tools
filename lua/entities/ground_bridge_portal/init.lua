AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile()
include('shared.lua')

function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create("ground_bridge_portal")
	ent:SetPos(tr.HitPos + Vector(0, 0, 20))
	ent:SetVar("Owner",ply)
	ent:Spawn()
	return ent
end 

function ENT:Initialize()
	if(!util.IsValidModel("models/props_random/whirlpool22_narrow.mdl")) then
		self.Entity.Owner:SendLua("GAMEMODE:AddNotify(\"Missing Whirlpool Model! Check your chat!\", NOTIFY_ERROR, 8); surface.PlaySound( \"buttons/button2.wav\" )")
		self.Entity.Owner:PrintMessage(HUD_PRINTTALK,"The Server is missing the Whirlpool addon, install it at https://steamcommunity.com/sharedfiles/filedetails/?id=1524799867")
		self.Entity:Remove()

		return
	end

	util.AddNetworkString("GroundBridgeColor"..self:EntIndex())

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
		phys:EnableGravity(false)
		phys:Wake()
		phys:EnableMotion(false)
	end

	self.backprop = ents.Create("prop_physics")
	self.backprop:SetModel("models/props_random/whirlpool22_narrow.mdl")
	self.backprop:SetPos(self.Entity:GetPos())
	self.backprop:SetAngles(self.Entity:GetAngles()+Angle(180,0,0))
	self.backprop:Spawn()
	self.backprop:SetModelScale(-1,0)
	self.backprop:SetNotSolid(true)
	self.backprop:SetParent(self.Entity)

	timer.Simple(0.1,function()
		self.backprop:SetColor(self.Entity:GetColor())
	end)
	

	local backphys = self.backprop:GetPhysicsObject()
	if(backphys:IsValid()) then
		backphys:SetMass(100)
		backphys:EnableGravity(false)
		backphys:Wake()
		backphys:EnableMotion(false)
	end

	self.Entity:SetNWBool("On",true)

	timer.Create("BridgeIdleSound"..self:EntIndex(),1,1,function()
		if(IsValid(self.Entity)) then
			self.Entity:EmitSound("ambient/levels/citadel/field_loop2.wav",75,100,0.5)
		end
	end)
end

function ENT:OnRemove()
	timer.Remove("BridgeIdleSound")
	self:StopSound("ambient/levels/citadel/field_loop2.wav")
	self.backprop:Remove()
end