AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Energon Cube"
ENT.Author = "Nova Astral"
ENT.Category = "Transformers Entities"
ENT.Contact	= "https://github.com/NovaAstral"
ENT.Purpose	= "its for storing energon"
ENT.Instructions = "just use it"

ENT.Spawnable = false

if CLIENT then
    function ENT:Draw()
        self.Entity:DrawModel()
    end
else -- server

function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create("energon_cube")
	ent:SetPos(tr.HitPos)
	ent:SetVar("Owner",ply)
	ent:Spawn()
	return ent
end 

function ENT:Initialize()
	util.PrecacheModel("models/props_combine/combine_mortar01b.mdl")
	self.Entity:SetModel("models/props_combine/combine_mortar01b.mdl")
	
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)

	self.Entity:SetUseType(SIMPLE_USE)

	self.Entity:DrawShadow(false)
	
	local phys = self.Entity:GetPhysicsObject()
	
	if(phys:IsValid()) then
		phys:SetMass(100)
		phys:EnableGravity(true)
		phys:Wake()
		phys:EnableMotion(false)
	end

	if(WireLib != nil) then
		self.WireDebugName = "Energon Cube"

		self.Inputs = WireLib.CreateSpecialOutputs(self.Entity,{"Energon"},{"NORMAL"})
	end

	self.Energon = 0
	self.MaxEnergon = 100

	self.Entity:SetNWInt("energon",self.Energon)
end

function ENT:Think()
	if(self.Active == 1) then
		if(EnCrys.Energon > 0 and self.Energon < 100) then
			EnCrys:SetEnergon(EnCrys.Energon-1)
			self.Energon = self.Energon+1

			self.Entity:SetNWInt("energon",self.Energon)
			self.Entity:SetNWInt("crystal_energon",EnCrys.Energon)
		else
			self.Active = 0
		end
	end
end

end