local SWEP = {Primary = {}, Secondary = {}}

SWEP.Author 		= "Nova Astral"
SWEP.Purpose		= "Energon Miner"
SWEP.Instructions	= "Left Click to mine energon"

SWEP.DrawCrosshair	= true
SWEP.SlotPos = 1
SWEP.Slot = 2
SWEP.Spawnable = false
SWEP.Weight = 1
SWEP.HoldType = "pistol"
SWEP.Primary.Ammo = "none" --This stops it from giving pistol ammo when you get the tool
SWEP.Secondary.Ammo = "none"
SWEP.Primary.Delay = 1-- Repair Delay
SWEP.Primary.Automatic = true
SWEP.ViewModelFOV = 70
SWEP.ViewModel = "models/weapons/c_toolgun.mdl"
SWEP.WorldModel = "models/weapons/w_toolgun.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.UseHands = true


--function SWEP:DrawWorldModel() end
--function SWEP:DrawWorldModelTranslucent() end
function SWEP:CanPrimaryAttack() return false end
function SWEP:CanSecondaryAttack() return false end
function SWEP:Holster() return true end
function SWEP:ShouldDropOnDie() return false end

function SWEP:Initialize()
	self:SetNWInt("rawenergon",0)
	self:SetNWString("screencol","200 100 100 255")
	self.Weldsound = self.Weldsound or CreateSound(self, "ambient/energy/electric_loop.wav")
	self.NextTrace = 0
	self.Trace = nil

	self:DrawShadow(false)
end

if SERVER then
	AddCSLuaFile()
	function SWEP:Think()
		if CurTime() > self.NextTrace then
			self.Trace = self.Owner:GetEyeTrace()
			self.NextTrace = CurTime() + 0.1

			if(IsValid(self.Trace.Entity) and self.Trace.Entity.EntHealth and self.Trace.Entity.MaxHealth) then
				local trclass = self.Trace.Entity:GetClass()
			end
		end

		if(self.Owner:GetShootPos():Distance(self.Trace.HitPos) < 300) then
			if(IsValid(self.Trace.Entity) and self.Trace.Entity.RawEnergon) then
				local eng = self.Trace.Entity.RawEnergon
                local prog = self.Trace.Entity.MiningProgress
                local Prog = math.Clamp(CurHP + 1,0,MaxHP)

				self:SetNWInt("rawenergon",eng)
                self:SetNWInt("miningprogress",prog)
				self:SetNWString("screencol","100 200 100 255")

				if(self.Owner:KeyPressed(1)) then
                    if(eng > 0) then
                        self.Weldsound:PlayEx(1, 100)

                        local trclass = self.Trace.Entity:GetClass()
        
                        local effectData = EffectData()
                        effectData:SetOrigin(self.Trace.HitPos)
                        effectData:SetNormal(self.Trace.HitNormal)
                        util.Effect("stunstickimpact", effectData, true, true)

                        eng = math.clamp(eng-1,0,100)
                    else
                        self.Trace.Entity:SpawnRawEnergon()
                    end
				end
			else
                self.Weldsound:Stop()

				self:SetNWInt("rawenergon",0)
                self:SetNWInt("miningprogress",0)
				self:SetNWString("screencol","200 100 100 255")
			end
		else
            self.Weldsound:Stop()
			self:SetNWInt("rawenergon",0)
            self:SetNWInt("miningprogress",0)
			self:SetNWString("screencol","200 100 100 255")
		end
	end
end

if CLIENT then
	local matScreen = Material("models/weapons/v_toolgun/screen")

    -- GetRenderTarget returns the texture if it exists, or creates it if it doesn't
    local rtTexture = GetRenderTarget("GModToolgunScreen",256,256)

    surface.CreateFont("TFEnergonMinerTitle",{
        font = "Helvetica",
        size = 30,
        weight = 900
    })
    surface.CreateFont("TFEnergonMinerRawEnergon",{
        font = "Helvetica",
        size = 100,
        weight = 900
    })

    function SWEP:RenderScreen()
        local TEX_SIZE = 256

        -- Set the material of the screen to our render target
        matScreen:SetTexture("$basetexture",rtTexture)

        local oldRT = render.GetRenderTarget()

        -- Set up our view for drawing to the texture
        render.SetViewPort(0,0,ScrW(),ScrH())
		render.PushRenderTarget(rtTexture)

        cam.Start2D()
            local RawEnergon = self:GetNWInt("rawenergon")
            local MiningProgress = self:GetNWInt("miningprogress")
			local Title = "Energon Miner"
			local BGColor = self:GetNWString("screencol")

            surface.SetDrawColor(string.ToColor(BGColor):Unpack())
            surface.DrawRect(0,0,TEX_SIZE,TEX_SIZE)

            self:drawShadowedText(Title, TEX_SIZE / 2, 32, "TFEnergonMinerTitle")
            self:drawShadowedText(RawEnergon, TEX_SIZE / 2, TEX_SIZE / 2, "TFEnergonMinerRawEnergon")
            self:drawShadowedText(MiningProgress, TEX_SIZE / 2, TEX_SIZE / 2, "TFEnergonMinerRawEnergon")
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

function SWEP:OnDrop()
    if SERVER then
		self:Remove() -- This deletes the SWEP entity if you drop it so there isn't just a invisible repair tool somewhere
	end
end

timer.Simple(0.1, function() weapons.Register(SWEP,"tf_energon_miner", true) end) --Putting this in a timer stops bugs from happening if the weapon is given while the game is paused