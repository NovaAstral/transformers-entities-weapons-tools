include('shared.lua')

language.Add( "Cleanup_ground_bridge_controller", "Ground Bridge Controller")
language.Add( "Cleaned_ground_bridge_controller", "Ground Bridge Controller")

function ENT:Draw()
   self:DrawEntityOutline( 0.0 )
   self.Entity:DrawModel()	
end

function ENT:DrawEntityOutline()
return
end
