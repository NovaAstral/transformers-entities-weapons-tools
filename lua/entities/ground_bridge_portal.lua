AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Ground Bridge Portal"
ENT.Author = "Nova Astral"
ENT.Category = "Transformers Entities"
ENT.Contact	= "https://github.com/NovaAstral"
ENT.Purpose	= "zoom"
ENT.Instructions = "just use it"

ENT.Spawnable = true

if CLIENT then
    function ENT:Draw()
        self.Entity:DrawModel()
    end

	function ENT:Think()
    	if(self:GetNWBool("On",false) == true) then
        	local dlight = DynamicLight(self:EntIndex())

        	if(dlight) then
            	dlight.Pos = self:LocalToWorld(Vector(0,0,100))
            	dlight.Brightness = 1
            	dlight.Decay = 1024 * 5
            	dlight.Size = 1024
            	dlight.DieTime = CurTime() + 1

            	if(self:GetColor() == Color(255,255,255)) then
               		dlight.r = 0
               		dlight.g = 255
               		dlight.b = 158
            	else
               		dlight.r = self:GetColor().r
               		dlight.g = self:GetColor().g
               		dlight.b = self:GetColor().b
            	end
        	end
    	end
	end

	--hook.Add("PreDrawHalos","GroundBridgeHalo",function()
	--   halo.Add(halotable,Color(0,255,158),2,2,2,true,false)
	--end)

	net.Receive("ServerGroundBridgeMessage",function(len)
		local msg = net.ReadString()

		permissions.AskToConnect(msg)
	end)
else -- server

function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create("ground_bridge_portal")
	ent:SetPos(tr.HitPos + Vector(0, 0, 80))
	ent:SetVar("Owner",ply)
	ent:Spawn()
	return ent
end

function ENT:OpenPortal()
	timer.Create("BridgeIdleSound"..self:EntIndex(),1,1,function()
		if(IsValid(self.Entity)) then
			self:EmitSound("ambient/levels/citadel/field_loop2.wav",75,100,0.5)
		end
	end)

	self:SetNWBool("On",true)

	timer.Create("BridgeOpen"..self:EntIndex(),0.1,1,function()
		self:SetModelScale(self.PortalSize,0.5)
		self.backprop:SetModelScale(-self.PortalSize,0.5)

		self:EmitSound(self.OpenSounds[math.random(1,2)])
	end)

	if(self.PortalLink ~= nil and IsValid(self.PortalLink)) then
		timer.Create("BridgeTP"..self:EntIndex(),0.1,0,function()
			if(IsValid(self.Entity)) then
				for k, v in ipairs(ents.FindInSphere(self:GetPos(),self.PortalSize*100)) do
					if(v:GetPhysicsObject():IsValid() and v:GetPhysicsObject():IsMotionEnabled() and v:GetClass() != "ground_bridge_portal" and v:GetNWBool("TFNoBridging",false) == false) then
						if(IsValid(v:GetCreator()) or v:IsPlayer() or IsValid(v:GetOwner())) then
							v:SetPos(self.PortalLink:LocalToWorld(Vector(0,math.random(-self.PortalSize*50,self.PortalSize*50),math.random(self.PortalSize*250,self.PortalSize*400)))) --set random pos so players dont get stuck inside eachother hopefully
							v:SetVelocity(-v:GetVelocity()) --stop the player so they dont go back through the bridge

							timer.Simple(0.1,function() --delayed so the player teleporting can hear it
								self:EmitSound("ground_bridge/ground_bridge_teleport.wav")
								self.PortalLink:EmitSound("ground_bridge/ground_bridge_teleport.wav")
							end)
							
							if(self.ServerBridge == true and v:IsPlayer()) then
								net.Start("ServerGroundBridgeMessage")
									net.WriteString(self.ServerBridgeIP)
								net.Send(v)
							end
						end
					end
				end
			end
		end)
	end
end

function ENT:ClosePortal()
	self:EmitSound(self.CloseSound)
	self:SetModelScale(0,0.9)
	self.backprop:SetModelScale(0,0.9)

	self:StopSound("ambient/levels/citadel/field_loop2.wav")

	timer.Simple(2,function() --stop the sound twice incase someone turned it off before it was fully on
		if(IsValid(self.Bridge1)) then
			self:StopSound("ambient/levels/citadel/field_loop2.wav")
		end
	end)

	timer.Simple(1,function()
		self:SetNWBool("On",false)
		timer.Remove("BridgeTP"..self:EntIndex())
	end)
end

function ENT:Initialize()
	if(!util.IsValidModel("models/props_random/whirlpool22_narrow.mdl")) then
		self.Entity.Owner:SendLua("GAMEMODE:AddNotify(\"Missing Whirlpool Model! Check your chat!\", NOTIFY_ERROR, 8); surface.PlaySound( \"buttons/button2.wav\" )")
		self.Entity.Owner:PrintMessage(HUD_PRINTTALK,"The Server is missing the Whirlpool addon, install it at https://steamcommunity.com/sharedfiles/filedetails/?id=1524799867")
		self:Remove()

		return
	end

	util.AddNetworkString("GroundBridgeColor"..self:EntIndex())
	util.AddNetworkString("ServerGroundBridgeMessage")

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

	util.PrecacheSound("ground_bridge/ground_bridge_open.wav")
	util.PrecacheSound("ground_bridge/ground_bridge_open2.wav")
	util.PrecacheSound("ground_bridge/ground_bridge_close.wav")
	util.PrecacheSound("ground_bridge/ground_bridge_teleport.wav")

	self.PortalLink = nil
	self.PortalSize = 1
	self.OpenOnSpawn = true
	self.ServerBridge = true
	self.ServerBridgeIP = ""

	self.OpenSounds = {"ground_bridge/ground_bridge_open.wav","ground_bridge/ground_bridge_open2.wav"}
	self.CloseSound = "ground_bridge/ground_bridge_close.wav"
	self.TeleportSound = "ground_bridge/ground_bridge_teleport.wav"

	self.backprop = ents.Create("prop_physics")
	self.backprop:SetModel("models/props_random/whirlpool22_narrow.mdl")
	self.backprop:SetPos(self.Entity:GetPos())
	self.backprop:SetAngles(self.Entity:GetAngles()+Angle(180,0,0))
	self.backprop:Spawn()
	self.backprop:SetModelScale(0,0)
	self.backprop:SetNotSolid(true)
	self.backprop:SetParent(self.Entity)

	timer.Simple(0.1,function()
		if(IsValid(self.backprop)) then
			self.backprop:SetColor(self.Entity:GetColor())
		end
	end)
	
	local backphys = self.backprop:GetPhysicsObject()
	if(backphys:IsValid()) then
		backphys:SetMass(100)
		backphys:EnableGravity(false)
		backphys:Wake()
		backphys:EnableMotion(false)
	end

	self:SetModelScale(0,0)

	if(self.OpenOnSpawn == true) then
		self:OpenPortal()
	end
end

function ENT:Think()
	if(self.backprop:GetColor() ~= self:GetColor()) then
		self.backprop:SetColor(self:GetColor())
	end
end

function ENT:OnRemove()
	timer.Remove("BridgeIdleSound")
	self:StopSound("ambient/levels/citadel/field_loop2.wav")

	if(IsValid(self.backprop)) then
		self.backprop:Remove()
	end
end

end