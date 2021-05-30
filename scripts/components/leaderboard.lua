local function leaderboardToString(board)
	local sortedboard = {}
	for i, v in pairs(board) do
		table.insert(sortedboard, {id=i, name= v[1], days = v[2], deaths = v[3]})
	end
	table.sort(sortedboard, function(a,b) if a.days == b.days then return a.deaths < b.deaths else return a.days > b.days end end)
	local s = ""
	for k,v in pairs(sortedboard) do
	    s = s .. v.name .. "|" .. math.floor(v.days / TUNING.TOTAL_DAY_TIME) + 1 .. "|" .. v.deaths .. "\n"
		--s = s .. v.name .. "|" .. v.days .. "|" .. v.deaths .. "\n"
	end
	return s
end

function getCurrentLeaderboard(self,currentLeaderboard) self.inst.currentLeaderboard:set(leaderboardToString(currentLeaderboard)) end
function getOverallLeaderboard(self,overallLeaderboard) self.inst.overallLeaderboard:set(leaderboardToString(overallLeaderboard)) end

local currentLeaderboard = {};
local overallLeaderboard = {};

local leaderboard = Class(
	function(self, inst)
		self.inst = inst
		self.deaths = 0
		self.lastDeathTime = 0
		
		self.currentDaysSurvived = 0
		self.currentMaxDaysSurvived = 0
		
		self.maxDaysSurvived = 0
		
		self.currentLeaderboard = {}
		self.overallLeaderboard = {}
	end,
	nil,
	{
		currentLeaderboard = getCurrentLeaderboard,
		overallLeaderboard = getOverallLeaderboard,
	}
)

--Save
function leaderboard:OnSave()
    local data = {
        deaths = self.deaths,
		currentDaysSurvived = self.currentDaysSurvived,
		maxDaysSurvived = self.maxDaysSurvived,
		currentLeaderboard = currentLeaderboard,
		overallLeaderboard = overallLeaderboard,
    }
    return data
end

--Load
function leaderboard:OnLoad(data)
    self.deaths = data.deaths or 0
	self.currentDaysSurvived = data.currentDaysSurvived or 0
	self.maxDaysSurvived = data.maxDaysSurvived or 0
	if TheNet:GetIsServer() then
		if _G.LEADERRESET then 
			self:resetLeaderboard()
		else
			currentLeaderboard = data.currentLeaderboard or {}
			overallLeaderboard = data.overallLeaderboard or {}
			getOverallLeaderboard(self,overallLeaderboard)
			getCurrentLeaderboard(self,currentLeaderboard)
		end
	
	end
end

function leaderboard:resetLeaderboard()
	currentLeaderboard = {}
	overallLeaderboard = {}
	getOverallLeaderboard(self,overallLeaderboard)
	getCurrentLeaderboard(self,currentLeaderboard)
end

--compute days of survival
function leaderboard:ontimepass(inst)
	inst:DoTaskInTime(1, function(inst)
		self:computeLeaderboard(inst)
	end)
	--inst:DoTaskInTime(1, function()
	--	overallLeaderboard["asdasd"] = {"Player1", 500, 2}
	--	overallLeaderboard["fdgdfg"] = {"Player2", 6000, 1}
	--	overallLeaderboard["fdgdf123g"] = {"Player3", 200, 3}
	--	overallLeaderboard["fdgdf1a23g"] = {"Player4", 400, 3}
	--	overallLeaderboard["asd123asd"] = {"Player5", 666, 2}
	--	overallLeaderboard["fd3gdfg"] = {"Player6", 800, 2}
	--	overallLeaderboard["fdg1df123g"] = {"Player7", 1500, 1}
	--	overallLeaderboard["fdg2df123g"] = {"Player8", 600, 3}
	--	overallLeaderboard["asda6sd"] = {"Player9", 50, 2}
	--	overallLeaderboard["fdg5dfg"] = {"Player10", 60, 1}
	--	overallLeaderboard["fdg4df123g"] = {"Player11", 120, 1}
	--	overallLeaderboard["fdgdf1723g"] = {"Player12", 70, 10}
	--	getOverallLeaderboard(self,overallLeaderboard)
	--end)
    inst:DoPeriodicTask(60, function(inst) 
		self:computeLeaderboard(inst)
	end)
	
end
function leaderboard:computeLeaderboard(inst)
	self.currentDaysSurvived = inst.components.age:GetAge() - self.lastDeathTime
	
	if self.currentDaysSurvived > self.maxDaysSurvived then
		self.maxDaysSurvived = self.currentDaysSurvived;
		overallLeaderboard[inst.userid] = {inst:GetDisplayName(), self.maxDaysSurvived, self.deaths}

		getOverallLeaderboard(self,overallLeaderboard)			
	end
	
	if self.currentDaysSurvived > self.currentMaxDaysSurvived then
		self.currentMaxDaysSurvived = self.currentDaysSurvived;
		currentLeaderboard[inst.userid] = {inst:GetDisplayName(), self.currentMaxDaysSurvived, self.deaths}

		getCurrentLeaderboard(self,currentLeaderboard)			
	end
end

--Death
function leaderboard:onkilled(inst)
    inst:ListenForEvent("death", function(inst, data)
		self.lastDeathTime = inst.components.age:GetAge();
		self.currentMaxDaysSurvived = inst.components.age:GetAge() - self.lastDeathTime
		self.deaths = self.deaths + 1;
		self.currentDaysSurvived = 0;
		
	end)
end

--Init
function leaderboard:Init(inst)
	inst:ListenForEvent("ms_playerleft", function(src, player) 
		currentLeaderboard[player.userid] = nil;
		getCurrentLeaderboard(self,currentLeaderboard)	
	end, TheWorld)
	
	inst:DoTaskInTime(.1, function()
		self:ontimepass(inst)
		self:onkilled(inst)
	end)
end

return leaderboard