AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Ground Bridge Frame"
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
	local ent = ents.Create("ground_bridge_frame")
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

	if(!util.IsValidModel("models/cybertron/space_bridge.mdl")) then -- If server is missing cybertrian prop pack v4 (not typo'd), use backup model
		self.Entity.Owner:SendLua("GAMEMODE:AddNotify(\"Missing Cybertrian Prop Pack V4!\", NOTIFY_ERROR, 8); surface.PlaySound( \"buttons/button2.wav\" )")
		self.Entity.Owner:PrintMessage(HUD_PRINTTALK,"The Server is missing Cybertrian Prop Pack V4. Install the correct model at https://steamcommunity.com/sharedfiles/filedetails/?id=1747440216")
		self:Remove()
	else --server has cyberpack v4
		util.PrecacheModel("models/cybertron/space_bridge.mdl")
		self.Entity:SetModel("models/cybertron/space_bridge.mdl")
	end

	util.PrecacheSound("ground_bridge/ground_bridge_open.wav")
	util.PrecacheSound("ground_bridge/ground_bridge_open2.wav")
	util.PrecacheSound("ground_bridge/ground_bridge_close.wav")
	util.PrecacheSound("ground_bridge/ground_bridge_lever.wav")
	util.PrecacheSound("ground_bridge/ground_bridge_teleport.wav")

	self.OpenSounds = {"ground_bridge/ground_bridge_open.wav","ground_bridge/ground_bridge_open2.wav"}

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	self.Entity:DrawShadow(false)
		
	local phys = self.Entity:GetPhysicsObject()

	self.Bridge1Pos = self.Entity:GetPos() + self.Entity:GetForward()*-100
	self.Bridge1Ang = self.Entity:GetAngles() + Angle(90,0,0)
	self.Bridge2Pos = Vector(0,0,0)
	self.Bridge2Ang = Angle(0,0,0)

	self.BridgeActive = false
	self.Size = 1
	self.Dist = 100
	self.Reset = 0

	self.MaxRange = 8000 --max distance the exit portal can be from the frame

	self.BridgeColor = Vector(255,255,255)
		
	if(phys:IsValid()) then
		phys:SetMass(100)
		phys:EnableGravity(true)
		phys:Wake()
	end

	if(WireLib != nil) then
		self.WireDebugName = "Ground Bridge Controller"

		self.Inputs = WireLib.CreateSpecialInputs(self.Entity,
		{"Activate","Bridge Pos","Bridge Angle","Reset","Color","Size","Distance"},
		{"NORMAL","VECTOR","ANGLE","NORMAL","VECTOR","NORMAL","NORMAL"})
	end

	self:SetNWBool("TFNoBridging",true)
end

function ENT:OpenBridge()
	if(self.BridgeActive == true) then return end

	if(self.Bridge2Pos:Distance(self.Entity:GetPos())) > self.MaxRange then
		self:EmitSound("buttons/button18.wav",75,100,0.5)
		
		local BridgePos = self.Bridge2Pos	
		local x = math.Clamp(BridgePos.x,self:GetPos().x - self.MaxRange,self:GetPos().x + self.MaxRange)
		local y = math.Clamp(BridgePos.y,self:GetPos().y - self.MaxRange,self:GetPos().y + self.MaxRange)
		local z = math.Clamp(BridgePos.z,self:GetPos().z - self.MaxRange,self:GetPos().z + self.MaxRange)
		self.Bridge2Pos = Vector(x,y,z)
	end

	if(not util.IsInWorld(self.Bridge2Pos)) then
		self:EmitSound("buttons/button2.wav",75,100,0.5)
		
		return
	end

	self.BridgeActive = true
	if(!IsValid(self.Bridge1)) then
		self.Bridge1 = ents.Create("ground_bridge_portal")
		self.Bridge1:SetPos(self.Entity:GetPos() + self.Entity:GetForward()*-100)
		self.Bridge1:SetAngles(self.Entity:GetAngles() + Angle(90,0,0))
		self.Bridge1.OpenOnSpawn = false
		self.Bridge1:Spawn()
		self.Bridge1:SetParent(self.Entity)
	end

	if(!IsValid(self.Bridge2)) then
		self.Bridge2 = ents.Create("ground_bridge_portal")
		self.Bridge2:SetPos(self.Bridge2Pos)
		self.Bridge2:SetAngles(self.Bridge2Ang)
		self.Bridge1.OpenOnSpawn = false
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
				if(Bridge2Pos:Distance(self.Entity:GetPos())) > self.MaxRange then
					self:OpenBridge()
				end
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