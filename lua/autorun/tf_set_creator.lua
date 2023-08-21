if SERVER then
    hook.Add("PlayerSpawnedProp","tf_set_Creator",function(ply,model,ent)
        ent:SetCreator(ply)
    end)
end