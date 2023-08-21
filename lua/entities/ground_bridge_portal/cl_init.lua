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
end