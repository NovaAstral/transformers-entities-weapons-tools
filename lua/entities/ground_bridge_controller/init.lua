AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

if(WireLib == nil) then return end

ENT.WireDebugName = "Ground Bridge Controller"

function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create("ground_bridge_controller")
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

	util.PrecacheModel("models/props_silo/desk_console2.mdl")

	util.PrecacheSound("ground_bridge/ground_bridge_open.wav")
	util.PrecacheSound("ground_bridge/ground_bridge_close.wav")
	util.PrecacheSound("ground_bridge/ground_bridge_lever.wav")
	util.PrecacheSound("ground_bridge/ground_bridge_teleport.wav")

	self.Entity:SetModel("models/props_silo/desk_console2.mdl")
	
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

	self.BridgeColor = Vector(255,255,255)
		
	if(phys:IsValid()) then
		phys:SetMass(100)
		phys:EnableGravity(true)
		phys:Wake()
	end

	print("Owner:")
	print(self.Entity.Owner)

	self.Inputs = WireLib.CreateSpecialInputs(self.Entity,
	{"Activate","Bridge1 Pos","Bridge1 Angle","Bridge2 Pos","Bridge2 Angle","Reset","Color","Size","Distance"},
	{"NORMAL","VECTOR","ANGLE","VECTOR","ANGLE","NORMAL","VECTOR","NORMAL","NORMAL"})
end

function ENT:OpenGroundBridge()
	if(self.BridgeActive == true) then return end

	self.BridgeActive = true

	if(!IsValid(self.Bridge1)) then
		self.Bridge1 = ents.Create("ground_bridge_portal")
		self.Bridge1:SetPos(self.Bridge1Pos)
		self.Bridge1:SetAngles(self.Bridge1Ang)
		self.Bridge1:Spawn()
		self.Bridge1:SetModelScale(0,0)
		self.Bridge1.backprop:SetModelScale(0,0)
	end

	if(!IsValid(self.Bridge2)) then
		self.Bridge2 = ents.Create("ground_bridge_portal")
		self.Bridge2:SetPos(self.Bridge2Pos)
		self.Bridge2:SetAngles(self.Bridge2Ang)
		self.Bridge2:Spawn()
		self.Bridge2:SetModelScale(0,0)
		self.Bridge2.backprop:SetModelScale(0,0)
	end

	timer.Create("BridgeIdleSound"..self:EntIndex(),1,1,function()
		if(IsValid(self.Bridge1)) then
			self.Bridge1:EmitSound("ambience/dronemachine3.wav",75,100,0.5)
		end

		if(IsValid(self.Bridge2)) then
			self.Bridge2:EmitSound("ambience/dronemachine3.wav",75,100,0.5)
		end
	end)

	self.Bridge1:SetNWBool("On",true)
	self.Bridge2:SetNWBool("On",true)

	if(IsValid(self.Bridge1)) then
		self.Bridge1:SetColor(Color(self.BridgeColor.x,self.BridgeColor.y,self.BridgeColor.z))
	end

	if(IsValid(self.Bridge2)) then
		self.Bridge2:SetColor(Color(self.BridgeColor.x,self.BridgeColor.y,self.BridgeColor.z))
	end

	timer.Create("BridgeOpen"..self:EntIndex(),0.1,1,function()
		self.Bridge1:SetModelScale(self.Size,0.3)
		self.Bridge2:SetModelScale(self.Size,0.3)
		self.Bridge1.backprop:SetModelScale(-self.Size,0.3)
		self.Bridge2.backprop:SetModelScale(-self.Size,0.3)

		self.Bridge1:EmitSound("ground_bridge/ground_bridge_open.wav")
		self.Bridge2:EmitSound("ground_bridge/ground_bridge_open.wav")
	end)

	timer.Create("BridgeTP"..self:EntIndex(),0.1,0,function()
		if(IsValid(self.Bridge1)) then
			for k, v in ipairs(ents.FindInSphere(self.Bridge1:GetPos(),self.Size*100)) do
				if(v:GetPhysicsObject():IsValid() and v:GetPhysicsObject():IsMotionEnabled() and v:GetClass() != "ground_bridge_portal" and v:GetNWBool("TFNoBridging",false) == false) then
					v:SetPos(self.Bridge2:LocalToWorld(Vector(0,math.random(-self.Size*50,self.Size*50),math.random(self.Size*250,self.Size*400))))
					v:SetVelocity(-v:GetVelocity()) --stop the player so they dont go back through the bridge

					self.Bridge1:EmitSound("ground_bridge/ground_bridge_teleport.wav")
					self.Bridge2:EmitSound("ground_bridge/ground_bridge_teleport.wav")

					if(v:IsPlayer()) then --jank way to get the player to face out of the exit bridge
						v:SetEyeAngles((self.Bridge2:LocalToWorld(Vector(0,45,300)) - v:GetShootPos()):Angle())
					end
				end
			end
		end

		if(IsValid(self.Bridge2)) then
			for k, v in ipairs(ents.FindInSphere(self.Bridge2:GetPos(),self.Size*100)) do
				if(v:GetPhysicsObject():IsValid() and v:GetPhysicsObject():IsMotionEnabled() and v:GetClass() != "ground_bridge_portal" and v:GetNWBool("TFNoBridging",false) == false) then
					v:SetPos(self.Bridge1:LocalToWorld(Vector(0,math.random(-self.Size*50,self.Size*50),math.random(self.Size*250,self.Size*400))))
					v:SetVelocity(-v:GetVelocity()) --stop the player so they dont go back through the bridge

					self.Bridge1:EmitSound("ground_bridge/ground_bridge_teleport.wav")
					self.Bridge2:EmitSound("ground_bridge/ground_bridge_teleport.wav")

					if(v:IsPlayer()) then --jank way to get the player to face out of the exit bridge
						v:SetEyeAngles((self.Bridge1:LocalToWorld(Vector(0,45,300)) - v:GetShootPos()):Angle())
					end
				end
			end
		end
	end)
end

function ENT:CloseGroundBridge()
	if(self.BridgeActive == false) then return end

	self.BridgeActive = false

	timer.Remove("BridgeTP"..self:EntIndex())

	if(IsValid(self.Bridge1)) then
		self.Bridge1:EmitSound("ground_bridge/ground_bridge_close.wav")
		self.Bridge1:SetModelScale(0,0.3)
		self.Bridge1.backprop:SetModelScale(0,0.3)
		self.Bridge1:SetNWBool("On",false)

		self.Bridge1:StopSound("ambience/dronemachine3.wav")

		timer.Simple(2,function() --stop the sound twice incase someone turned it off before it was fully on
			if(IsValid(self.Bridge1)) then
				self.Bridge1:StopSound("ambience/dronemachine3.wav")
			end
		end)
	end

	if(IsValid(self.Bridge2)) then
		self.Bridge2:EmitSound("ground_bridge/ground_bridge_close.wav")
		self.Bridge2:SetModelScale(0,0.3)
		self.Bridge2.backprop:SetModelScale(0,0.3)
		self.Bridge2:SetNWBool("On",false)

		self.Bridge2:StopSound("ambience/dronemachine3.wav")

		timer.Simple(2,function() --stop the sound twice incase someone turned it off before it was fully on
			if(IsValid(self.Bridge2)) then
				self.Bridge2:StopSound("ambience/dronemachine3.wav")
			end
		end)
	end
end

function ENT:ResetBridge()
	self.BridgeActive = false
	
	if(IsValid(self.Bridge1)) then
		self.Bridge1:StopSound("ambience/dronemachine3.wav")
		self.Bridge1:Remove()
	end
	
	if(IsValid(self.Bridge2)) then
		self.Bridge2:StopSound("ambience/dronemachine3.wav")
		self.Bridge2:Remove()
	end
end

function ENT:TriggerInput(iname, value)
	if(iname == "Activate") then
		self.Entity:EmitSound("ground_bridge/ground_bridge_lever.wav")

		if(value >= 1) then
			if(IsValid(self.Bridge1) and IsValid(self.Bridge2)) then
				self:OpenGroundBridge()
			else
				if(self.Bridge1Pos == Vector(0,0,0) or self.Bridge2Pos == Vector(0,0,0)) then
					self.Entity:EmitSound("buttons/button2.wav",100,100,1,CHAN_AUTO,0,0)
				else
					self:OpenGroundBridge()
				end
			end
		else
			self:CloseGroundBridge()
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
		self:ResetBridge()
	elseif(iname == "Color") then
		self.BridgeColor = value
	elseif(iname == "Size") then
		self.Size = math.Clamp(value,0.1,2)
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
