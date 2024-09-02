AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Energon Ore"
ENT.Author = "Nova Astral"
ENT.Category = "Transformers Entities"
ENT.Contact	= "https://github.com/NovaAstral"
ENT.Purpose	= "its for being mined"
ENT.Instructions = "just mine it"

ENT.Spawnable = true
ENT.AdminSpawnable = true

if CLIENT then
    language.Add( "Cleanup_energon_crystal", "Cleanup Energon Ore")
    language.Add( "Cleaned_energon_crystal", "Cleaned Energon Ore")

    function ENT:Draw()
        self:DrawEntityOutline( 0.0 )
        self.Entity:DrawModel()
    end

    function ENT:DrawEntityOutline() return end
else -- server

function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create("energon_ore")
	ent:SetPos(tr.HitPos)
	ent:SetVar("Owner",ply)
	ent:Spawn()
	return ent
end 

function ENT:Initialize()
	if(!util.IsValidModel("models/cybertron/energon_crystal.mdl")) then
		self.Entity.Owner:SendLua("GAMEMODE:AddNotify(\"Missing Energon Ore Model! Check your chat!\", NOTIFY_ERROR, 8); surface.PlaySound( \"buttons/button2.wav\" )")
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

    self.Scale = math.random(1,5)

    self:SetModelScale(self.Scale,0.000001)

    self.RawEnergon = 25*self.Scale
    self.MiningProgress = 0
end

function ENT:SpawnRawEnergon()
    if(self.RawEnergon > 0 and self.MiningProgress == 0) then
        local rawore = ents.Create("raw_energon")
        rawore:SetPos(self:GetPos() + Vector(0,0,35*self.Scale))
    end
end

function ENT:Think()
    if(self:GetModelScale() ~= self.Scale) then
        self.Scale = self:GetModelScale()

        self.RawEnergon = 25*self.Scale
    end
end

end