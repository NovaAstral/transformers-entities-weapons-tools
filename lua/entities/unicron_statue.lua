AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Sacrificial Unicron Statue"
ENT.Author = "Nova Astral"
ENT.Category = "Transformers Entities"
ENT.Contact	= "https://github.com/NovaAstral"
ENT.Purpose	= "its for extracting life energy"
ENT.Instructions = "Kill someone near it"

ENT.Spawnable = true

if CLIENT then
    function ENT:Draw()
        self.Entity:DrawModel()
    end
else -- server

function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create("unicron_statue")
	ent:SetPos(tr.HitPos)
	ent:SetVar("Owner",ply)
	ent:Spawn()
	return ent
end 

function ENT:Initialize()
	util.PrecacheModel("models/props_c17/statue_horse.mdl")
	self.Entity:SetModel("models/props_c17/statue_horse.mdl")
	
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

    timer.Simple(1,function()
        if(IsValid(self)) then
            hook.Add("PlayerDeath","Unicron_Death_Check"..self.Entity:EntIndex(),function(victim,inflictor,attacker)
                self:Sacrificed(victim,inflictor,attacker)
            end)
        end
    end)
end

function ENT:Sacrificed(victim,inflictor,attacker)
    print("sac")
    if(victim:GetPos():Distance(self.Entity:GetPos()) <= 500) then
        bufftar = ents.FindInSphere(self.Entity:GetPos(),500)

        for k,v in pairs(bufftar) do
            if(v:IsPlayer() and v:Alive()) then
                randnorm = math.random(1,1)
                randrare = math.random(1,25)
                randextrare = math.random(1,100)

                if(randextrare == 1) then --kill the unlucky fucker
                    local direction = (v:GetPos()+Vector(0,0,25) - self.Entity:GetPos()):GetNormalized()
                    local GibEnt = ents.Create("prop_physics")

                    GibEnt:SetModel("models/cybertron/energon/energon_cube_gib_3.mdl")

                    GibEnt:PhysicsInit(SOLID_VPHYSICS)
                    GibEnt:SetMoveType(MOVETYPE_VPHYSICS)
                    GibEnt:SetSolid(SOLID_VPHYSICS)

                    local Phys = GibEnt:GetPhysicsObject()

                    if(Phys:IsValid()) then
                        Phys:SetMass(100)
                        Phys:EnableGravity(true)
                        Phys:Wake()
                    end

                    GibEnt:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
                    GibEnt:SetPos(self.Entity:GetPos()+Vector(0,0,25))

                    if(IsValid(Phys)) then
                        Phys:SetVelocity(direction * 5000)
                    end
                    
                    timer.Simple(10,function()
                        if(IsValid(GibEnt)) then
                            GibEnt:Remove()
                        end
                    end)

                    v:ChatPrint("You have gained the curse of shrapnel in your general direction!")
                elseif(randrare == 1) then --5min godmode, 1/25 chance
                    if(v:IsPlayer() and v:Alive()) then
                        v:GodEnable()

                        timer.Simple(300,function()
                            if(v:HasGodMode()) then
                                v:GodDisable()

                                v:ChatPrint("Your godmode has run out!")
                            end
                        end)

                        v:ChatPrint("You have gained the boon of Godmode for 5 minutes!")
                    end
                elseif(randnorm == 1) then
                    local hp = v:GetMaxHealth()*2
                    v:SetHealth(hp)
                    v:ChatPrint("You have gained the boon of "..hp.." health!")
                elseif(randnorm == 2) then
                    v:ChatPrint("You have gained the boon of WIP")
                elseif(randnorm == 3) then
                    v:ChatPrint("You have gained the boon of WIP")
                elseif(randnorm == 4) then
                    v:ChatPrint("You have gained the boon of WIP")
                elseif(randnorm == 5) then
                    v:ChatPrint("You have gained the boon of WIP")
                elseif(randnorm == 6) then
                    v:ChatPrint("You have gained the boon of WIP")
                end
                --battery shield
                --better knife maybe
                --money
            end
        end
    end
end

function ENT:OnRemove()
	hook.Remove("PlayerDeath","Unicron_Death_Check"..self.Entity:EntIndex())
end

end
