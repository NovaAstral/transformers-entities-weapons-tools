AddCSLuaFile()

local SWEP = {Primary = {}, Secondary = {}}
SWEP.Author = "Nova Astral"
SWEP.PrintName = "Battlemaster Combiner"
SWEP.Purpose = "Give someone yourself to use as a weapon"
SWEP.Instructions = "LMB - Combine/Uncombine"
SWEP.DrawCrosshair = true
SWEP.SlotPos = 10
SWEP.Slot = 3
SWEP.Spawnable = false
SWEP.Weight = 6
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

	self.Combined = false
    self.CombinedPly = nil
    self.CombineDist = 75
    self.CombineWep = nil
	self.SelectedWep = "" --put your weapon here
end

function SWEP:Holster()
	return !self.Combined
end

if SERVER then
	function SWEP:Combine(ent)
		local ply = self:GetOwner()
		if(IsValid(ent) and ent:IsPlayer()) then
			self.CombineWep = ent:Give(self.SelectedWep)

			if(IsValid(self.CombineWep)) then
				self.CombinedPly = ent
				ply:Spectate(OBS_MODE_CHASE)
				ply:SpectateEntity(ent)
			else
				ply:ChatPrint("Combiner: Invalid Weapon!")
			end
		end
	end

	function SWEP:UnCombine()
		if(IsValid(self.CombinedPly)) then
			local ply = self:GetOwner()
			ply:UnSpectate()
			ply:Spawn()
			ply:SetPos(self.CombinedPly:GetPos()+Vector(100,0,0))

			if(self.CombinedPly:HasWeapon(self.SelectedWep) and IsValid(self.CombineWep)) then
				self.CombineWep:Remove()
			end

			self.CombinedPly = nil
		end
	end

	function SWEP:PrimaryAttack()
		self:SetNextPrimaryFire(CurTime()+1)

		local ply = self:GetOwner()
		if (not IsValid(ply)) then return end

        local tr = ply:GetEyeTraceNoCursor()
        
        if(self:GetOwner():GetShootPos():Distance(tr.HitPos) <= self.CombineDist and IsValid(tr.Entity)) then
            if(self.Combined == false and !IsValid(self.CombinedPly)) then
                self:Combine(tr.Entity)
			end
        end
	end

	function SWEP:SecondaryAttack()
		if(IsValid(self.CombinedPly)) then
			self:UnCombine()
		end
	end

	function SWEP:Think() --check combined ply, if they dont have the wep, or die, un-combine
		if(IsValid(self.CombinedPly) and self.CombinedPly:IsPlayer()) then
			if(self.CombinedPly:HasWeapon(self.SelectedWep) and !IsValid(self.CombineWep)) then
				self.CombineWep = self.CombinedPly:GetWeapon(self.SelectedWep)
			end

			if(!self.CombinedPly:Alive()) then
				self:UnCombine()
			end
		end
	end

	function SWEP:OnRemove() -- When the player dies
		self:UnCombine()
	end

	function SWEP:OnDrop() -- if the player drops weapon
		self:UnCombine()
	end
end

timer.Simple(0.1, function() weapons.Register(SWEP,"tf_combiner_battlemaster", true) end) --Putting this in a timer stops bugs from happening if the weapon is given while the game is paused