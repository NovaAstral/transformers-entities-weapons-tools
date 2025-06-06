AddCSLuaFile()

local SWEP = {Primary = {}, Secondary = {}}
SWEP.Author = "Nova Astral"
SWEP.PrintName = "Bridge Controller"
SWEP.Purpose = "Controlling the Ground Bridge"
SWEP.Instructions = "LMB - Open Bridge \nLMB + Walk - Set Bridge 1 Pos \nRMB - Close Bridge \nRMB + Walk - Set Bridge 2 Pos \nReload - Select Controller or Reset Bridges"
SWEP.DrawCrosshair = true
SWEP.SlotPos = 10
SWEP.Slot = 3
SWEP.Spawnable = true
SWEP.Weight = 1
SWEP.HoldType = "normal"
SWEP.Primary.Ammo = "none" --This stops it from giving pistol ammo when you get the swep
SWEP.Primary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = true
SWEP.WorldModel = "models/weapons/w_toolgun.mdl"
SWEP.ViewModel = "models/weapons/v_toolgun.mdl"

SWEP.Category = "Transformers Tools"

function SWEP:CanPrimaryAttack() return false end
function SWEP:CanSecondaryAttack() return false end
function SWEP:Holster() return true end
function SWEP:ShouldDropOnDie() return false end

function SWEP:Initialize()
    if(self.SetHoldType) then
        self:SetHoldType("pistol")
    end

    self:DrawShadow(false)

    self.BridgeController = nil
    self.ReloadDelay = CurTime()+1
end

if SERVER then
    function SWEP:PrimaryAttack()
        self:SetNextPrimaryFire(CurTime()+1)
        self:SetNextSecondaryFire(CurTime()+1)
        self.ReloadDelay = CurTime()+1

        local ply = self:GetOwner()

        if(not IsValid(ply)) then return end
        if(not IsValid(self.BridgeController)) then 
            ply:EmitSound("buttons/button8.wav",60,100,0.2)
            return 
        end

        if(ply:KeyDown(IN_WALK)) then
            local tr = ply:GetEyeTraceNoCursor()
            local ang = Vector(tr.HitPos - ply:GetPos()):Angle()
            local angp = Angle(-90,ang.y,ang.z)

            if(self.BridgeController:GetClass() == "ground_bridge_frame") then --force bridge 2 if its a ground bridge
                self.BridgeController.Bridge2Pos = tr.HitPos + tr.HitNormal * self.BridgeController.Dist
                self.BridgeController.Bridge2Ang = angp
            else
                self.BridgeController.Bridge1Pos = tr.HitPos + tr.HitNormal * self.BridgeController.Dist
                self.BridgeController.Bridge1Ang = angp
            end

            ply:EmitSound("buttons/button24.wav",60,100,0.2)
        else
            if(not util.IsInWorld(self.BridgeController.Bridge1Pos) or not util.IsInWorld(self.BridgeController.Bridge2Pos)) then
                ply:EmitSound("buttons/button2.wav",40,100,0.5)
            else
                ply:EmitSound("buttons/button22.wav",60,100,0.2)
                self.BridgeController:OpenBridge()
            end
        end
    end

    function SWEP:SecondaryAttack()
        self:SetNextSecondaryFire(CurTime()+1)
        self:SetNextPrimaryFire(CurTime()+1)
        self.ReloadDelay = CurTime()+1
        
        local ply = self:GetOwner()

        if(not IsValid(ply)) then return end
        if(not IsValid(self.BridgeController)) then 
            ply:EmitSound("buttons/button8.wav",60,100,0.2)
            return 
        end

        if(ply:KeyDown(IN_WALK)) then
            local tr = ply:GetEyeTraceNoCursor()

            self.BridgeController.Bridge2Pos = tr.HitPos + tr.HitNormal * self.BridgeController.Dist

            local ang = Vector(tr.HitPos - ply:GetPos()):Angle()
            local angp = Angle(-90,ang.y,ang.z)

            self.BridgeController.Bridge2Ang = angp

            ply:EmitSound("buttons/button24.wav",60,100,0.2)
        else
            ply:EmitSound("buttons/button22.wav",60,100,0.2)
            self.BridgeController:CloseBridge()
        end
    end

    function SWEP:Reload()
        if(self.ReloadDelay >= CurTime()) then
            return
        else
            self.ReloadDelay = CurTime()+1
        end
        
        local ply = self:GetOwner()

        if(not IsValid(ply)) then return end

        local tr = ply:GetEyeTraceNoCursor()

        if(tr.Entity:GetClass() == "ground_bridge_frame" or tr.Entity:GetClass() == "space_bridge_controller") then
            self.BridgeController = tr.Entity
            ply:EmitSound("buttons/blip1.wav",60,100,0.2)
        elseif(IsValid(self.BridgeController)) then
            self.BridgeController:ResetBridge()
            ply:EmitSound("buttons/button9.wav",60,100,0.2)
        else
            ply:EmitSound("buttons/button8.wav",60,100,0.2)
        end
    end
end

if(CLIENT)then
    local matScreen = Material("models/weapons/v_toolgun/screen")
    local rtTexture = GetRenderTarget("GModToolgunScreen",256,256)

    surface.CreateFont("TFBridgeController",{
        font = "Helvetica",
        size = 40,
        weight = 900
    })

    function SWEP:RenderScreen()
        matScreen:SetTexture("$basetexture",rtTexture)

        local oldRT = render.GetRenderTarget()

        render.SetViewPort(0,0,ScrW(),ScrH())
        render.PushRenderTarget(rtTexture)

        cam.Start2D()
            surface.SetDrawColor(Color(100,100,100))
            surface.DrawRect(0,0,256,256)
            self:drawShadowedText("Ground Bridge",128,110,"TFBridgeController")
            self:drawShadowedText("Controller",128,145,"TFBridgeController")
        cam.End2D()

        render.SetRenderTarget(oldRT)
        render.SetViewPort(0,0,ScrW(),ScrH())
        render.PopRenderTarget()
    end

    function SWEP:drawShadowedText(text, x, y, font)
        draw.SimpleText( text, font, x + 3, y + 3, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText( text, font, x , y , Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

timer.Simple(0.1, function() weapons.Register(SWEP,"tf_bridge_control_tool", true) end) --Putting this in a timer stops bugs from happening if the weapon is given while the game is paused