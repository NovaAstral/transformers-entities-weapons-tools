AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Energon Crystal"
ENT.Author = "Nova Astral"
ENT.Category = "Transformers Entities"
ENT.Contact	= "https://github.com/NovaAstral"
ENT.Purpose	= "its for being mined"
ENT.Instructions = "just mine it"

ENT.Spawnable = false

if CLIENT then
    function ENT:Draw()
        self.Entity:DrawModel()
    end
else -- server

function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create("raw_energon")
	ent:SetPos(tr.HitPos)
	ent:SetVar("Owner",ply)
	ent:Spawn()
	return ent
end 

function ENT:Initialize()
	if(!util.IsValidModel("models/cybertron/energon_crystal.mdl")) then
		self.Entity.Owner:SendLua("GAMEMODE:AddNotify(\"Missing Energon Crystal Model! Check your chat!\", NOTIFY_ERROR, 8); surface.PlaySound( \"buttons/button2.wav\" )")
		self.Entity.Owner:PrintMessage(HUD_PRINTTALK,"The Server is missing the Cybertronian Model Pack addon, install it at https://steamcommunity.com/sharedfiles/filedetails/?id=1747440216")
		self.Entity:Remove()

		return
	end
    
	util.PrecacheModel("models/cybertron/energon_crystal.mdl")
	self.Entity:SetModel("models/cybertron/energon_crystal.mdl")
	
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	self.Entity:DrawShadow(false)
	
	local phys = self.Entity:GetPhysicsObject()
	
	if(phys:IsValid()) then
		phys:SetMass(100)
		phys:EnableGravity(true)
		phys:Wake()
		phys:EnableMotion(false)
	end

	self.Energon = 50
	self.Entity:SetNWInt("energon",self.Energon)
end

function ENT:SetEnergon(num)
	self.Energon = num
	self.Entity:SetNWInt("energon",num)
end

function ENT:Think()
	Col = self:GetColor().r - 4
	self:SetColor(Color(Col,Col,Col))
end

end