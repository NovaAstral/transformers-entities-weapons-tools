AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Space Bridge Controller"
ENT.Author = "Nova Astral"
ENT.Category = "Transformers Entities"
ENT.Contact	= "https://github.com/NovaAstral"
ENT.Purpose	= "nyoom"
ENT.Instructions = "https://www.youtube.com/watch?v=EfXJ6S9VPbI"

ENT.Spawnable = true

if CLIENT then
    function ENT:Draw()
       self.Entity:DrawModel()
    end
else --server

function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create("space_bridge_controller")
	ent:SetPos(tr.HitPos + Vector(0, 0, 20))
	ent:SetVar("Owner",ply)
	ent:Spawn()
	return ent 
end

function ENT:Initialize()
	if(!util.IsValidModel("models/props_random/whirlpool22_narrow.mdl")) then -- If Server is missing whirlpool adddon
		self.Entity.Owner:SendLua("GAMEMODE:AddNotify(\"Missing Whirlpool Model! Check your chat!\", NOTIFY_ERROR, 8); surface.PlaySound( \"buttons/button2.wav\" )")
		self.Entity.Owner:PrintMessage(HUD_PRINTTALK,"The Server is missing the Whirlpool addon, install it at https://steamcommunity.com/sharedfiles/filedetails/?id=1524799867")
		self.Entity:Remove()

		return
	end

	if(!util.IsValidModel("models/props_silo/desk_console2.mdl")) then -- If server is missing episode 2, use backup model
		self.Entity.Owner:SendLua("GAMEMODE:AddNotify(\"Missing Half Life 2: Episode 2! Using backup model.\", NOTIFY_ERROR, 8); surface.PlaySound( \"buttons/button2.wav\" )")
		self.Entity.Owner:PrintMessage(HUD_PRINTTALK,"The Server is missing Half Life 2: Episode 2, Using backup model.")

		util.PrecacheModel("models/props_combine/combine_interface001.mdl")
		self.Entity:SetModel("models/props_combine/combine_interface001.mdl")
	else --server has ep2
		util.PrecacheModel("models/props_silo/desk_console2.mdl")
		self.Entity:SetModel("models/props_silo/desk_console2.mdl")
	end

	util.PrecacheSound("ground_bridge/ground_bridge_lever.wav")
	self.LeverSound = "ground_bridge/ground_bridge_lever.wav"

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	self.Entity:DrawShadow(false)
		
	local phys = self.Entity:GetPhysicsObject()

	self.Bridge1Pos = Vector(0,0,0)
	self.Bridge1Ang = Angle(0,0,0)
	self.Bridge2Pos = Vector(0,0,0)
	self.Bridge2Ang = Angle(0,0,0)

	self.BridgeActive = false
	self.Size = 1
	self.Dist = 100
	self.Reset = 0

	self.BridgeColor = Vector(255,255,255)
		
	if(phys:IsValid()) then
		phys:SetMass(100)
		phys:EnableGravity(true)
		phys:Wake()
	end

	if(WireLib != nil) then
		self.WireDebugName = "Space Bridge Controller"

		self.Inputs = WireLib.CreateSpecialInputs(self.Entity,
		{"Activate","Bridge1 Pos","Bridge1 Angle","Bridge2 Pos","Bridge2 Angle","Reset","Color","Size","Distance"},
		{"NORMAL","VECTOR","ANGLE","VECTOR","ANGLE","NORMAL","VECTOR","NORMAL","NORMAL"})
	end
end

function ENT:TransformOffset(v, a1, a2)
	return (v:Dot(a1:Right()) * a2:Right() + v:Dot(a1:Up()) * (-a2:Up()) - v:Dot(a1:Forward()) * a2:Forward())
end

function ENT:OpenBridge()
	if(self.BridgeActive == true) then return end

	if(not util.IsInWorld(self.Bridge1Pos) or not util.IsInWorld(self.Bridge2Pos)) then
		self:EmitSound("buttons/button2.wav",75,100,0.5)
		return
	end

	self.BridgeActive = true

	if(!IsValid(self.Bridge1)) then
		self.Bridge1 = ents.Create("ground_bridge_portal")
		self.Bridge1:SetPos(self.Bridge1Pos)
		self.Bridge1:SetAngles(self.Bridge1Ang)
		self.Bridge1.OpenOnSpawn = false
		self.Bridge1.HasController = true
		self.Bridge1:Spawn()
	end

	if(!IsValid(self.Bridge2)) then
		self.Bridge2 = ents.Create("ground_bridge_portal")
		self.Bridge2:SetPos(self.Bridge2Pos)
		self.Bridge2:SetAngles(self.Bridge2Ang)
		self.Bridge2.OpenOnSpawn = false
		self.Bridge2.HasController = true
		self.Bridge2:Spawn()
	end

	if(IsValid(self.Bridge1) and IsValid(self.Bridge2)) then
		self.Bridge1.PortalLink = self.Bridge2
		self.Bridge2.PortalLink = self.Bridge1

		self.Bridge1:SetColor(Color(self.BridgeColor.x,self.BridgeColor.y,self.BridgeColor.z))
		self.Bridge1.backprop:SetColor(Color(self.BridgeColor.x,self.BridgeColor.y,self.BridgeColor.z))

		self.Bridge2:SetColor(Color(self.BridgeColor.x,self.BridgeColor.y,self.BridgeColor.z))
		self.Bridge2.backprop:SetColor(Color(self.BridgeColor.x,self.BridgeColor.y,self.BridgeColor.z))

		self.Bridge1:OpenPortal()
		self.Bridge2:OpenPortal()
	end
end

function ENT:CloseBridge()
	if(self.BridgeActive == false) then return end

	self.BridgeActive = false

	if(IsValid(self.Bridge1)) then
		self.Bridge1:ClosePortal()
	end

	if(IsValid(self.Bridge2)) then
		self.Bridge2:ClosePortal()
	end
end

function ENT:ResetBridge()
	if(IsValid(self.Bridge1)) then
		if(self.Bridge1:GetNWBool("On",false) == false) then
			self.Bridge1:Remove()

			self.BridgeActive = false
		else
			self.Bridge1:ClosePortal()

			timer.Simple(1,function()
				self.Bridge1:Remove()

				self.BridgeActive = false
			end)
		end
	end
	
	if(IsValid(self.Bridge2)) then
		if(self.Bridge2:GetNWBool("On",false) == false) then
			self.Bridge2:Remove()
		else
			self.Bridge2:ClosePortal()

			timer.Simple(1,function()
				self.Bridge2:Remove()
			end)
		end
	end
end

function ENT:WireTriggerBridge(value)
	if(value >= 1) then
		if(IsValid(self.Bridge1) and IsValid(self.Bridge2)) then
			self:OpenBridge()
		else
			if(self.Bridge1Pos == Vector(0,0,0) or self.Bridge2Pos == Vector(0,0,0)) then
				self.Entity:EmitSound("buttons/button2.wav",100,100,1,CHAN_AUTO,0,0)
			else
				self:OpenBridge()
			end
		end
	else
		self:CloseBridge()
	end
end

function ENT:TriggerInput(iname, value)
	if(iname == "Activate") then
		self.Entity:EmitSound("ground_bridge/ground_bridge_lever.wav")

		
		if(self.Reset == 1 and value >= 1) then
			self:ResetBridge()

			timer.Simple(0.1,function()
				self:WireTriggerBridge(value)
			end)
		else
			self:WireTriggerBridge(value)
		end
	elseif(iname == "Bridge1 Pos") then
		if(value != Vector(0,0,0)) then
			self.Bridge1Pos = value
		end
	elseif(iname == "Bridge1 Angle") then
		self.Bridge1Ang = value
	elseif(iname == "Bridge2 Pos") then
		if(value != Vector(0,0,0)) then
			self.Bridge2Pos = value
		end
	elseif(iname == "Bridge2 Angle") then
		self.Bridge2Ang = value
	elseif(iname == "Reset") then
		if(value >= 1) then
			self.Reset = 1
		else
			self.Reset = 0
		end

		self:ResetBridge()
	elseif(iname == "Color") then
		self.BridgeColor = value
	elseif(iname == "Size") then
		self.Size = math.Clamp(value,0.1,2)
	elseif(iname == "Distance") then
		self.Dist = math.Clamp(value,0,32000)
	end
end

function ENT:PreEntityCopy()
	if WireAddon then
		duplicator.StoreEntityModifier(self,"WireDupeInfo",WireLib.BuildDupeInfo(self.Entity))
	end
end

function ENT:PostEntityPaste(ply, ent, createdEnts)
	if WireAddon then
		local emods = ent.EntityMods
		if not emods then return end
		WireLib.ApplyDupeInfo(ply, ent, emods.WireDupeInfo, function(id) return createdEnts[id] end)
	end
end

function ENT:OnRemove()
	timer.Remove("BridgeOpen"..self:EntIndex())
	timer.Remove("BridgeClose"..self:EntIndex())
	timer.Remove("BridgeIdleSound"..self:EntIndex())
	timer.Remove("BridgeIdleSound_Stop"..self:EntIndex())
	timer.Remove("BridgeTP"..self:EntIndex())
	
	if(IsValid(self.Bridge1)) then
		self.Bridge1:Remove()
	end

	if(IsValid(self.Bridge2)) then
		self.Bridge2:Remove()
	end
end

end