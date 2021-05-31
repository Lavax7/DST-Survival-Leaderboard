local _G = GLOBAL
local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

_G.LEADERRESET = GetModConfigData('RESET')

require "rpc"									 

Assets = {
	Asset("ATLAS", "images/hud/background_lmod.xml"),
    Asset("IMAGE", "images/hud/background_lmod.tex"),
	Asset("ATLAS", "images/button/button_bg.xml"),
    Asset("IMAGE", "images/button/button_bg.tex"),
	Asset("ATLAS", "images/button/button_bg_inactive.xml"),
    Asset("IMAGE", "images/button/button_bg_inactive.tex"),
}

GLOBAL.c_clearLB = function() end
GLOBAL.c_resetLB = function() end

AddPlayerPostInit(function(inst)
	inst.currentLeaderboard = GLOBAL.net_string(inst.GUID,"currentLeaderboard")
	inst.overallLeaderboard = GLOBAL.net_string(inst.GUID,"overallLeaderboard")
	
    inst:AddComponent("leaderboard")
	if not GLOBAL.TheNet:GetIsClient() then
		inst.components.leaderboard:Init(inst)
	end
	
	GLOBAL.c_clearLB = function()
		if not GLOBAL.TheNet:GetIsClient() then
			inst.components.leaderboard:clearLeaderboard()
		end
	end
	GLOBAL.c_resetLB = function()
		if not GLOBAL.TheNet:GetIsClient() then
			inst.components.leaderboard:resetLeaderboard()
		end
	end
end)

local uiLeaderboard = require("widgets/uiLeaderboard")
local uiLeaderboardWidget = nil
local function hideMenus()
	if type(GLOBAL.ThePlayer) ~= "table" or type(GLOBAL.ThePlayer.HUD) ~= "table" then return end
	uiLeaderboardWidget.mainui:Hide()
end

local function switchVisibilty()
	if type(GLOBAL.ThePlayer) ~= "table" or type(GLOBAL.ThePlayer.HUD) ~= "table" then return end
	if uiLeaderboardWidget.mainui.shown then
		uiLeaderboardWidget.mainui:Hide()
	else
		uiLeaderboardWidget:updateLeaderboards()
		uiLeaderboardWidget.mainui:Show()
	end
	
end

local function PositionUI(self, screensize)
	local hudscale = self.top_root:GetScale()
	local screenw_full, screenh_full = GLOBAL.unpack(screensize)
	local screenw = screenw_full/hudscale.x
	local screenh = screenh_full/hudscale.y
	self.uiLeaderboard:SetScale(.60*hudscale.x,.60*hudscale.y,1)
end

local function AdduiLeaderboard(self)
    self.uiLeaderboard = self.top_root:AddChild(uiLeaderboard(self.owner))
	uiLeaderboardWidget = self.uiLeaderboard
	local screensize = {GLOBAL.TheSim:GetScreenSize()}
    PositionUI(self, screensize)
    self.uiLeaderboard:SetHAnchor(0)
    self.uiLeaderboard:SetVAnchor(0)
    self.uiLeaderboard:MoveToFront()
	local OnUpdate_base = self.OnUpdate
	self.OnUpdate = function(self, dt)
		OnUpdate_base(self, dt)
		local curscreensize = {GLOBAL.TheSim:GetScreenSize()}
		if curscreensize[1] ~= screensize[1] or curscreensize[2] ~= screensize[2] then
			PositionUI(self, curscreensize)
			screensize = curscreensize
		end
	end
	
	GLOBAL.TheInput:AddKeyUpHandler(GLOBAL.KEY_ESCAPE, hideMenus)
	GLOBAL.TheInput:AddKeyDownHandler(GLOBAL.KEY_L, switchVisibilty)
end

AddClassPostConstruct("widgets/controls", AdduiLeaderboard)
