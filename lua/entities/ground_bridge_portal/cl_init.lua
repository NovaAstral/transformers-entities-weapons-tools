include('shared.lua')

language.Add( "Cleanup_ground_bridge_portal", "Ground Bridge Portal")
language.Add( "Cleaned_ground_bridge_portal", "Ground Bridge Portal")

function ENT:Draw()
   self:DrawEntityOutline( 0.0 )
   self.Entity:DrawModel()
end

function ENT:DrawEntityOutline()
   return
end

if CLIENT then
	function ENT:Think()
      if(self:GetNWBool("On",false) == true) then
         local dlight = DynamicLight(self:EntIndex())

         if(dlight) then
            dlight.Pos = self:LocalToWorld(Vector(0,0,100))
            dlight.r = self:GetNWInt("GroundBridgeCol_R",0)
            dlight.g = self:GetNWInt("GroundBridgeCol_G",255)
            dlight.b = self:GetNWInt("GroundBridgeCol_B",158)
            dlight.Brightness = 2
            dlight.Decay = 1024 * 5
            dlight.Size = 1024
            dlight.DieTime = CurTime() + 1
         end
      end
	end

   --hook.Add("PreDrawHalos","GroundBridgeHalo",function()
   --   halo.Add(halotable,Color(0,255,158),2,2,2,true,false)
   --end)
end