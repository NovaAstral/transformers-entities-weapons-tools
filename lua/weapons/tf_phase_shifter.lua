local SWEP = {Primary = {}, Secondary = {}} -- I don't know what this does
SWEP.Author = "Nova Astral"
SWEP.PrintName = "Phase Shifter"
SWEP.Purpose = "Become Intangiable"
SWEP.Instructions = "LMB - Enable Phase Shift \nRMB - Disable Phase Shift"
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

SWEP.Category = "Transformers Tools"

function SWEP:DrawWorldModel() end
function SWEP:DrawWorldModelTranslucent() end
function SWEP:CanPrimaryAttack() return false end
function SWEP:CanSecondaryAttack() return false end
function SWEP:Holster() return true end
function SWEP:ShouldDropOnDie() return false end
function SWEP:PreDrawViewModel() return true end -- This stops it from displaying as a pistol in your hands

function SWEP:Initialize()
    if(self.SetHoldType) then
		self:SetHoldType("normal")
	else
		self:SetWeaponHoldType("normal") -- This makes your arms go to your sides
	end

	self:DrawShadow(false)

	self.Phase = false
end

if SERVER then
	function SWEP:PrimaryAttack()
		local ply = self:GetOwner()

		if (not IsValid(ply)) then return end

		if(not self.Phase) then
			self.Phase = true

			SWEP:Phase(ply,true,true) --ply, on, playsound
		end
	end

	function SWEP:SecondaryAttack()
		local ply = self:GetOwner()

		if (not IsValid(ply)) then return end
		if(self.Phase) then
			self.Phase = false

			SWEP:Phase(ply,false,false)
		end
	end

	function SWEP:Phase(ply,on,playsound)
		if(on == true) then
			if(playsound == true) then
				ply:EmitSound("tftools/phase_shift.wav",100,100)
			end

			timer.Create("TFPhase_wait",1.2,1,function()
				ply:SetCustomCollisionCheck(true)

				hook.Add("ShouldCollide","TFPhaseHook",function(ent1,ent2)
					if(ent1 == ply or ent2 == ply) then
						return false
					end
				end)
			end)
		else
			if(timer.Exists("TFPhase_wait")) then
				timer.Remove("TFPhase_wait")
			end

			ply:StopSound("tftools/phase_shift.wav")
			ply:EmitSound("tftools/phase_shift_deactivate.wav")

			ply:SetCustomCollisionCheck(false)
			hook.Remove("ShouldCollide","TFPhaseHook")
		end
	end

	function SWEP:OnRemove() -- When the player dies
		Phase(self:GetOwner(),false,false)
	end
end

if CLIENT then
	function SWEP:Initialize()
        self.NextUse = CurTime()
    end
end

timer.Simple(0.1, function() weapons.Register(SWEP,"tf_phase_shifter", true) end) --Putting this in a timer stops bugs from happening if the weapon is given while the game is paused