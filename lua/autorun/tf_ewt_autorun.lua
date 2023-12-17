if SERVER then
    hook.Add("PlayerSpawnedProp","tf_set_Creator",function(ply,model,ent)
        ent:SetCreator(ply)
    end)
end

if CLIENT then
    hook.Add("InitPostEntity","draw_energon_worldtips_init",function()
        hook.Add("Think","draw_energon_worldtips",function()
            local ply = LocalPlayer()
            local tr = ply:GetEyeTrace()
            local ent = tr.Entity

            if(IsValid(ent)) then
                if(ent:GetClass() == "energon_crystal") then
                    AddWorldTip(nil,"Energon: "..ent:GetNWInt("energon",0),nil,ent:GetPos(),ent)
                elseif(ent:GetClass() == "energon_extractor") then
                    AddWorldTip(nil,"Energon: "..ent:GetNWInt("energon",0).."\nCrystal Energon: "..ent:GetNWInt("crystal_energon",0),nil,ent:GetPos(),ent)
                end
            end
        end)
    end)
end