AddCSLuaFile()

local SWEP = {Primary = {}, Secondary = {}}
SWEP.Author = "Nova Astral"
SWEP.PrintName = "Combiner"
SWEP.Purpose = "Give someone yourself to use as a weapon"
SWEP.Instructions = "LMB - Combine/Uncombine"
SWEP.DrawCrosshair = true
SWEP.SlotPos = 10
SWEP.Slot = 3
SWEP.Spawnable = true
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

	SWEP.SelectedWep = "" --set these with code ran on the weapon when the player gets it, not here
	self.CombinerForced = false

	if SERVER then
		util.AddNetworkString("tf_combiner_wepnet")
	end
end

function SWEP:Holster()
	return !self.Combined
end

if SERVER then
	net.Receive("tf_combiner_wepnet",function(len,ply)
		local wepstr = net.ReadString()

		if(#wepstr > 0) then
			SWEP.SelectedWep = wepstr
		end
	end)

	function SWEP:Combine(ent)
		local ply = self:GetOwner()
		if(IsValid(ent) and ent:IsPlayer()) then
			self.CombineWep = ent:Give(SWEP.SelectedWep)

			if(IsValid(self.CombineWep)) then
				self.CombinedPly = ent
				ply:Spectate(OBS_MODE_CHASE)
				ply:SpectateEntity(ent)
			else
				ply:ChatPrint("Combiner: Invalid Weapon Selected!")
			end
		end
	end

	function SWEP:UnCombine()
		if(IsValid(self.CombinedPly)) then
			local ply = self:GetOwner()
			ply:UnSpectate()
			ply:Spawn()
			ply:SetPos(self.CombinedPly:GetPos()+Vector(100,0,0))

			if(self.CombinedPly:HasWeapon(SWEP.SelectedWep) and IsValid(self.CombineWep)) then
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
			if(self.CombinedPly:HasWeapon(SWEP.SelectedWep) and !IsValid(self.CombineWep)) then
				self.CombineWep = self.CombinedPly:GetWeapon(SWEP.SelectedWep)
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

if CLIENT then

	function SWEP:Reload()
		if(self.CombinerForced == false and !IsValid(WepEntry)) then
			WepEntry = vgui.Create("DFrame")
			WepEntry:SetTitle("Select your Combiner Weapon")
			WepEntry:SetSize(400,150)
			WepEntry:Center()
			WepEntry:MakePopup()

			local Preset1 = vgui.Create("DButton",WepEntry)
			Preset1:SetText("Preset 1")
			Preset1:SetPos(5,50)
			Preset1:SetSize(190,30)
			Preset1.DoClick = function()
				net.Start("tf_combiner_wepnet")
					net.WriteString("preset1")
				net.SendToServer()
			end

			local Preset2 = vgui.Create("DButton",WepEntry)
			Preset2:SetText("Preset 2")
			Preset2:SetPos(205,50)
			Preset2:SetSize(190,30)
			Preset2.DoClick = function()
				net.Start("tf_combiner_wepnet")
					net.WriteString("preset2")
				net.SendToServer()
			end

			local Preset3 = vgui.Create("DButton",WepEntry)
			Preset3:SetText("Preset 3")
			Preset3:SetPos(5,80)
			Preset3:SetSize(190,30)
			Preset3.DoClick = function()
				net.Start("tf_combiner_wepnet")
					net.WriteString("preset3")
				net.SendToServer()
			end

			local Preset4 = vgui.Create("DButton",WepEntry)
			Preset4:SetText("Preset 4")
			Preset4:SetPos(205,80)
			Preset4:SetSize(190,30)
			Preset4.DoClick = function()
				net.Start("tf_combiner_wepnet")
					net.WriteString("preset4")
				net.SendToServer()
			end

			local Preset5 = vgui.Create("DButton",WepEntry)
			Preset5:SetText("Preset 5")
			Preset5:SetPos(5,110)
			Preset5:SetSize(190,30)
			Preset5.DoClick = function()
				net.Start("tf_combiner_wepnet")
					net.WriteString("preset5")
				net.SendToServer()
			end

			local Preset6 = vgui.Create("DButton",WepEntry)
			Preset6:SetText("Preset 6")
			Preset6:SetPos(205,110)
			Preset6:SetSize(190,30)
			Preset6.DoClick = function()
				net.Start("tf_combiner_wepnet")
					net.WriteString("preset6")
				net.SendToServer()
			end

			if(LocalPlayer():IsSuperAdmin()) then
				local TextEntry = vgui.Create("DTextEntry",WepEntry)
				TextEntry:Dock(TOP)

				TextEntry.OnEnter = function(self)
					wep = self:GetValue()

					net.Start("tf_combiner_wepnet")
						net.WriteString(wep)
					net.SendToServer()

					chat.AddText("Combiner Weapon Selected: ",Color(150,220,0),wep)
					WepEntry:Close()
				end
			end
		end
	end
end

timer.Simple(0.1, function() weapons.Register(SWEP,"tf_combiner", true) end) --Putting this in a timer stops bugs from happening if the weapon is given while the game is paused