local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local AnimButton = require "widgets/animbutton"
local HoverText = require "widgets/hoverer"

local uiLeaderboard = Class(Widget, function(self, owner)
	Widget._ctor(self, "uiLeaderboard")
	self.owner = owner
	self.mainui = self:AddChild(Widget("mainui"))
	
	self.mainui:Hide()
	
	self.mainui.leaderboard_bg = self.mainui:AddChild(Image("images/hud/background_lmod.xml", "background_lmod.tex"))
	self.mainui.leaderboard_bg:SetPosition(-5, 40, 0)
	self.mainui.leaderboard_bg:SetScale(1,1,1)
	self.mainui.leaderboard_bg:MoveToFront()
	
	self.mainui.leaderboard_bg.title = self.mainui.leaderboard_bg:AddChild(Text(TITLEFONT, 64))
	self.mainui.leaderboard_bg.title:SetPosition(0, 425, 0)
	self.mainui.leaderboard_bg.title:SetString("Survival Leaderboard")
	
	self.mainui.leaderboard_bg.overallButton = self.mainui.leaderboard_bg:AddChild(ImageButton("images/button/button_bg.xml", "button_bg.tex"))
	self.mainui.leaderboard_bg.overallButton:SetPosition(-200, 280, 0)
	self.mainui.leaderboard_bg.overallButton:SetNormalScale(2,1,1)
	self.mainui.leaderboard_bg.overallButton:SetFocusScale(2.1,1.1,1)
	self.mainui.leaderboard_bg.overallButton:SetOnClick(function()
		self.mainui.leaderboard_bg.overallButton:SetTextures("images/button/button_bg.xml", "button_bg.tex")
		self.mainui.leaderboard_bg.currentButton:SetTextures("images/button/button_bg_inactive.xml", "button_bg_inactive.tex")
		self.currentLeaderboard:Hide()
		self.overallLeaderboard:Show()
		self:updateLeaderboards()
	end)
	self.mainui.leaderboard_bg.overallButton.label = self.mainui.leaderboard_bg.overallButton:AddChild(Text(BUTTONFONT, 35))
	self.mainui.leaderboard_bg.overallButton.label:SetMultilineTruncatedString("Highscore Leaderboard", 2, 200, 200, "", true)
	self.mainui.leaderboard_bg.overallButton.label:SetColour(0,0,0,1)
	self.mainui.leaderboard_bg.overallButton.label:SetScale(1,0.8,1)
	
	self.mainui.leaderboard_bg.currentButton = self.mainui.leaderboard_bg:AddChild(ImageButton("images/button/button_bg_inactive.xml", "button_bg_inactive.tex"))
	self.mainui.leaderboard_bg.currentButton:SetPosition(200, 280, 0)
	self.mainui.leaderboard_bg.currentButton:SetNormalScale(2,1,1)
	self.mainui.leaderboard_bg.currentButton:SetFocusScale(2.1,1.1,1)
	self.mainui.leaderboard_bg.currentButton:SetOnClick(function()
		self.mainui.leaderboard_bg.currentButton:SetTextures("images/button/button_bg.xml", "button_bg.tex")
		self.mainui.leaderboard_bg.overallButton:SetTextures("images/button/button_bg_inactive.xml", "button_bg_inactive.tex")
		self.currentLeaderboard:Show()
		self.overallLeaderboard:Hide()
		self:updateLeaderboards()
	end)
	self.mainui.leaderboard_bg.currentButton.label = self.mainui.leaderboard_bg.currentButton:AddChild(Text(BUTTONFONT, 35))
	self.mainui.leaderboard_bg.currentButton.label:SetMultilineTruncatedString("Current Leaderboard", 2, 200, 200, "", true)
	self.mainui.leaderboard_bg.currentButton.label:SetColour(0,0,0,1)
	self.mainui.leaderboard_bg.currentButton.label:SetScale(1,0.8,1)
	
	self.currentLeaderboard = self.mainui.leaderboard_bg:AddChild(Widget("currentLeaderboard"))
	self.currentLeaderboard:SetPosition(0, 460, 0)
	self.currentLeaderboard:Hide()
	
	self.overallLeaderboard = self.mainui.leaderboard_bg:AddChild(Widget("overallLeaderboard"))
	self.overallLeaderboard:SetPosition(0, 460, 0)
	--self.overallLeaderboard:Hide()
	
	self.overallLeaderboard.placement = self.overallLeaderboard:AddChild(Text(BODYTEXTFONT, 45))
	self.overallLeaderboard.placement:SetPosition(-400, -630, 0)
	self.overallLeaderboard.placement:SetHAlign(ANCHOR_MIDDLE)
	self.overallLeaderboard.placement:SetVAlign(ANCHOR_TOP)
	self.overallLeaderboard.placement:SetRegionSize(100,800)
	
	self.overallLeaderboard.names = self.overallLeaderboard:AddChild(Text(BODYTEXTFONT, 45))
	self.overallLeaderboard.names:SetPosition(-75, -630, 0)
	self.overallLeaderboard.names:SetHAlign(ANCHOR_LEFT)
	self.overallLeaderboard.names:SetVAlign(ANCHOR_TOP)
	self.overallLeaderboard.names:SetRegionSize(500,800)
	
	self.overallLeaderboard.days = self.overallLeaderboard:AddChild(Text(BODYTEXTFONT, 45))
	self.overallLeaderboard.days:SetPosition(200, -630, 0)
	self.overallLeaderboard.days:SetHAlign(ANCHOR_MIDDLE)
	self.overallLeaderboard.days:SetVAlign(ANCHOR_TOP)
	self.overallLeaderboard.days:SetRegionSize(200,800)
	
	self.currentLeaderboard.placement = self.currentLeaderboard:AddChild(Text(BODYTEXTFONT, 45))
	self.currentLeaderboard.placement:SetPosition(-400, -630, 0)
	self.currentLeaderboard.placement:SetHAlign(ANCHOR_MIDDLE)
	self.currentLeaderboard.placement:SetVAlign(ANCHOR_TOP)
	self.currentLeaderboard.placement:SetRegionSize(100,800)
	
	self.currentLeaderboard.names = self.currentLeaderboard:AddChild(Text(BODYTEXTFONT, 45))
	self.currentLeaderboard.names:SetPosition(-75, -630, 0)
	self.currentLeaderboard.names:SetHAlign(ANCHOR_LEFT)
	self.currentLeaderboard.names:SetVAlign(ANCHOR_TOP)
	self.currentLeaderboard.names:SetRegionSize(500,800)
	
	self.currentLeaderboard.days = self.currentLeaderboard:AddChild(Text(BODYTEXTFONT, 45))
	self.currentLeaderboard.days:SetPosition(100, -630, 0)
	self.currentLeaderboard.days:SetHAlign(ANCHOR_MIDDLE)
	self.currentLeaderboard.days:SetVAlign(ANCHOR_TOP)
	self.currentLeaderboard.days:SetRegionSize(200,800)
	
	self.currentLeaderboard.deaths = self.currentLeaderboard:AddChild(Text(BODYTEXTFONT, 45))
	self.currentLeaderboard.deaths:SetPosition(300, -630, 0)
	self.currentLeaderboard.deaths:SetHAlign(ANCHOR_MIDDLE)
	self.currentLeaderboard.deaths:SetVAlign(ANCHOR_TOP)
	self.currentLeaderboard.deaths:SetRegionSize(100,800)
	
	self.inst:DoTaskInTime(.2, function()
		self:StartUpdating()
	end)

end)

function uiLeaderboard:OnUpdate(dt)
	local oldcurrentData = self.currentData or ""
	local oldoverallData = self.overallData or ""
	self.currentData = self.owner.currentLeaderboard:value()
	self.overallData = self.owner.overallLeaderboard:value()
	if self.currentData ~= oldcurrentData or self.overallData ~= oldoverallData then self:updateLeaderboards() end
end

function uiLeaderboard:updateLeaderboards()
	local currentLeaders = self.owner.currentLeaderboard:value();
	local overallLeaders = self.owner.overallLeaderboard:value();
	
	self.currentNames = {}
	self.currentDays = {}
    self.currentDeaths = {}	
	self.currentNumber = 0
	local stringLines = {}
	for s in currentLeaders:gmatch("[^\n]+") do
		table.insert(stringLines, s)
		self.currentNumber = self.currentNumber + 1
	end
	for index, value in ipairs(stringLines) do
		local myTable = value:split("|")
		table.insert(self.currentNames, myTable[1])
		table.insert(self.currentDays, myTable[2])
		table.insert(self.currentDeaths, myTable[3])
	end
	
	self.overallNames = {}
	self.overallDays = {}
	self.overallNumber = 0
	stringLines = {}
	for s in overallLeaders:gmatch("[^\n]+") do
		table.insert(stringLines, s)
		self.overallNumber = self.overallNumber + 1
	end
	for index, value in ipairs(stringLines) do
		local myTable = value:split("|")
		table.insert(self.overallNames, myTable[1])
		table.insert(self.overallDays, myTable[2])
	end
	
	if self.currentLeaderboard.shown then
		local numberString = "Place\n\n";
		local namesString = "Name\n\n";
		local daysString = "Survived Days\n\n";
		local deathsString = "Deaths\n\n"
		local num = 0;
		if self.currentNumber > 10 then num = 10 else num = self.currentNumber end
		for i=1,num do 
			numberString = numberString .. i .. "\n"
			namesString = namesString .. self.currentNames[i] .. "\n"
			daysString = daysString .. self.currentDays[i] .. "\n"
			deathsString = deathsString .. self.currentDeaths[i] .. "\n"
		end 
		self.currentLeaderboard.placement:SetString(numberString)
		self.currentLeaderboard.names:SetString(namesString)
		self.currentLeaderboard.days:SetString(daysString)
		self.currentLeaderboard.deaths:SetString(deathsString)
	end
	
	if self.overallLeaderboard.shown then
		local numberString = "Place\n\n";
		local namesString = "Name\n\n";
		local daysString = "Survived Days\n\n";
		local num = 0;
		if self.overallNumber > 10 then num = 10 else num = self.overallNumber end
		for i=1,num do 
			numberString = numberString .. i .. "\n"
			namesString = namesString .. self.overallNames[i] .. "\n"
			daysString = daysString .. self.overallDays[i] .. "\n"
		end 
		self.overallLeaderboard.placement:SetString(numberString)
		self.overallLeaderboard.names:SetString(namesString)
		self.overallLeaderboard.days:SetString(daysString)
	
	end
	
end
	
return uiLeaderboard