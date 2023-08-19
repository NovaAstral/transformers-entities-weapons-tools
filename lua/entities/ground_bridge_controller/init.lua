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
		self.Entity.Owner:PrintMessage(HUD_PRINTTALK,"You're missing the Whirlpool addon, install it at https://steamcommunity.com/sharedfiles/filedetails/?id=1524799867")
		self.Entity:Remove()

		return
	end

	util.PrecacheModel("models/props_silo/desk_console2.mdl")

	util.PrecacheSound("ground_bridge/ground_bridge_open.wav")
	util.PrecacheSound("ground_bridge/ground_bridge_close.wav")
	util.PrecacheSound("ground_bridge/ground_bridge_lever.wav")
		
	self.Entity:SetModel("models/props_silo/desk_console2.mdl")
	
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
		
	self.Entity:DrawShadow(false)
		
	local phys = self.Entity:GetPhysicsObject()

	self.Bridge1PosEnt = nil
	self.Bridge2PosEnt = nil

	self.Mode = 0
	self.Size = 1
		
	if(phys:IsValid()) then
		phys:SetMass(100)
		phys:EnableGravity(true)
		phys:Wake()
	end

	print("Owner:")
	print(self.Entity.Owner)

	self.Inputs = WireLib.CreateSpecialInputs(self.Entity,
	{"Activate","Bridge1 Pos","Bridge2 Pos","Reset","Mode","Size"},
	{"NORMAL","ENTITY","ENTITY","NORMAL","NORMAL","NORMAL"})
	
end

function ENT:OpenGroundBridge()
	if(!IsValid(self.Bridge1)) then
		self.Bridge1 = ents.Create("ground_bridge_portal")
		self.Bridge1:SetPos(self.Bridge1PosEnt:GetPos())
		self.Bridge1:SetAngles(self.Bridge1PosEnt:GetAngles())
		self.Bridge1:Spawn()
		self.Bridge1:SetModelScale(0,0)
		self.Bridge1.backprop:SetModelScale(0,0)
	end

	if(!IsValid(self.Bridge2)) then
		self.Bridge2 = ents.Create("ground_bridge_portal")
		self.Bridge2:SetPos(self.Bridge2PosEnt:GetPos())
		self.Bridge2:SetAngles(self.Bridge2PosEnt:GetAngles())
		self.Bridge2:Spawn()
		self.Bridge2:SetModelScale(0,0)
		self.Bridge2.backprop:SetModelScale(0,0)
	end

	timer.Create("BridgeIdleSound"..self:EntIndex(),1,1,function()
		if(IsValid(self.Bridge1)) then
			self.Bridge1:EmitSound("ambience/dronemachine3.wav")
		end

		if(IsValid(self.Bridge2)) then
			self.Bridge2:EmitSound("ambience/dronemachine3.wav")
		end
	end)

	self.Bridge1:SetNWBool("On",true)
	self.Bridge2:SetNWBool("On",true)

	if(self.Mode == 1) then
		if(IsValid(self.Bridge1)) then
			self.Bridge1:SetColor(Color(150,0,150))
			self.Bridge1:SetNWInt("GroundBridgeCol_R",150)
			self.Bridge1:SetNWInt("GroundBridgeCol_G",0)
			self.Bridge1:SetNWInt("GroundBridgeCol_B",150)
		end
		
		if(IsValid(self.Bridge2)) then
			self.Bridge2:SetColor(Color(150,0,150))
			self.Bridge2:SetNWInt("GroundBridgeCol_R",150)
			self.Bridge2:SetNWInt("GroundBridgeCol_G",0)
			self.Bridge2:SetNWInt("GroundBridgeCol_B",150)
		end
	elseif(self.Mode == 0) then
		if(IsValid(self.Bridge1)) then
			self.Bridge1:SetColor(Color(255,255,255))
			self.Bridge1:SetNWInt("GroundBridgeCol_R",0)
			self.Bridge1:SetNWInt("GroundBridgeCol_G",255)
			self.Bridge1:SetNWInt("GroundBridgeCol_B",158)
		end
		
		if(IsValid(self.Bridge2)) then
			self.Bridge2:SetColor(Color(255,255,255))
			self.Bridge2:SetNWInt("GroundBridgeCol_R",0)
			self.Bridge2:SetNWInt("GroundBridgeCol_G",255)
			self.Bridge2:SetNWInt("GroundBridgeCol_B",158)
		end
	elseif(self.Mode == 2) then
		if(IsValid(self.Bridge1)) then
			self.Bridge1:SetColor(Color(255,95,255))
			self.Bridge1:SetNWInt("GroundBridgeCol_R",255)
			self.Bridge1:SetNWInt("GroundBridgeCol_G",95)
			self.Bridge1:SetNWInt("GroundBridgeCol_B",255)
		end
		
		if(IsValid(self.Bridge2)) then
			self.Bridge2:SetColor(Color(255,95,255))
			self.Bridge2:SetNWInt("GroundBridgeCol_R",255)
			self.Bridge2:SetNWInt("GroundBridgeCol_G",95)
			self.Bridge2:SetNWInt("GroundBridgeCol_B",255)
		end
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
				if(v:GetClass() == "player") then
					v:SetPos(self.Bridge2:LocalToWorld(Vector(0,math.random(-self.Size*50,self.Size*50),math.random(self.Size*250,self.Size*400))))
					v:SetVelocity(-v:GetVelocity()) --stop the player so they dont go back through the bridge

					--jank way to get the player to face out of the exit bridge
					v:SetEyeAngles((self.Bridge2:LocalToWorld(Vector(0,45,300)) - v:GetShootPos()):Angle())
				end
			end
		end

		if(IsValid(self.Bridge2)) then
			for k, v in ipairs(ents.FindInSphere(self.Bridge2:GetPos(),self.Size*100)) do
				if(v:GetClass() == "player") then
					v:SetPos(self.Bridge1:LocalToWorld(Vector(0,math.random(-self.Size*50,self.Size*50),math.random(self.Size*250,self.Size*400))))
					v:SetVelocity(-v:GetVelocity()) --stop the player so they dont go back through the bridge

					--jank way to get the player to face out of the exit bridge
					v:SetEyeAngles((self.Bridge1:LocalToWorld(Vector(0,45,300)) - v:GetShootPos()):Angle())
				end
			end
		end
	end)
end

function ENT:CloseGroundBridge()
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

function ENT:TriggerInput(iname, value)
	if(iname == "Activate") then
		self.Entity:EmitSound("ground_bridge/ground_bridge_lever.wav")

		if(value >= 1) then
			if(IsValid(self.Bridge1) and IsValid(self.Bridge2)) then
				self:OpenGroundBridge()
			else
				if(not IsValid(self.Bridge1PosEnt) or not IsValid(self.Bridge2PosEnt)) then
					self.Entity:EmitSound("buttons/button2.wav",100,100,1,CHAN_AUTO,0,0)
				else
					self:OpenGroundBridge()
				end
			end
		else
			self:CloseGroundBridge()
		end
	elseif(iname == "Bridge1 Pos") then
		if(IsValid(value)) then
			self.Bridge1PosEnt = value
		end
	elseif(iname == "Bridge2 Pos") then
		if(IsValid(value)) then
			self.Bridge2PosEnt = value
		end
	elseif(iname == "Reset") then
		if(IsValid(self.Bridge1)) then
			self.Bridge1:Remove()
		end

		if(IsValid(self.Bridge2)) then
			self.Bridge2:Remove()
		end
	elseif(iname == "Mode") then
		if(value >= 1) then
			self.Mode = 1
		elseif(value == -158) then
			self.Mode = 2
		else
			self.Mode = 0
		end
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
