AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Energon Extractor"
ENT.Author = "Nova Astral"
ENT.Category = "Transformers Entities"
ENT.Contact	= "https://github.com/NovaAstral"
ENT.Purpose	= "its for extracting"
ENT.Instructions = "just use it"

ENT.Spawnable = true
ENT.AdminSpawnable = true

if CLIENT then
    language.Add( "Cleanup_energon_extractor", "Energon Extractor")
    language.Add( "Cleaned_energon_extractor", "Energon Extractor")

    function ENT:Draw()
        self:DrawEntityOutline( 0.0 )
        self.Entity:DrawModel()
    end

    function ENT:DrawEntityOutline() return end
else -- server

function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create("energon_extractor")
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
		self.WireDebugName = "Energon Extractor"

		self.Inputs = WireLib.CreateSpecialInputs(self.Entity,{"Activate"},{"NORMAL"})
	end

	self.Active = 0

	self.Energon = 0
	self.MaxEnergon = 100

	self.Entity:SetNWInt("energon",self.Energon)
	self.Entity:SetNWInt("crystal_energon",0)
end

function ENT:TurnOn()
	local tr = util.QuickTrace(self.Entity:GetPos(),self.Entity:GetUp()*25)

	local tr = util.TraceLine({
		start = self.Entity:GetPos(),
		endpos = self.Entity:GetPos()+self.Entity:GetUp()*25,
		filter = self.Entity
	})

	EnCrys = tr.Entity

	if(IsValid(EnCrys) and EnCrys:GetClass() == "energon_crystal" and self.Active == 0) then
		if(EnCrys.Energon > 0 and self.Energon < 100) then
			self.Active = 1
		end
	end
end

function ENT:Use(ply)
	if(self.Active == 1) then
		self.Active = 0
	else
		self:TurnOn()
	end
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

function ENT:TriggerInput(iname, value)
	if(iname == "Activate") then
		self.Entity:EmitSound("ground_bridge/ground_bridge_lever.wav")

		
		if(value >= 1) then
			self:TurnOn()

			timer.Simple(0.1,function()
				self:WireTriggerBridge(value)
			end)
		else
			self:WireTriggerBridge(value)
		end
	end
end

end