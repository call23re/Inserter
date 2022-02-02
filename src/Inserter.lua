local AssetService = game:GetService("AssetService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Players = game:GetService("Players")

local Util = require(script.Parent.Util)

local Characters = script.Parent.Models

local Inserter = {
	Settings = {
		Unlock = true,
		Camera = false,
		Rig = "R15"
	}
}

-- Private
function Inserter:_ApplyModifications(Object)
	if self.Settings.Unlock then
		pcall(function()
			Object.Locked = false
		end)

		for _, v in pairs(Object:GetDescendants()) do
			pcall(function()
				v.Locked = false
			end)
		end
	end

	if self.Settings.Camera then
		local Position = CFrame.new(workspace.CurrentCamera.CFrame.Position)

		if Object:IsA("Model") or Object:IsA("BasePart") then
			Object:PivotTo(Position)
		else
			local ProxyModel = Instance.new("Model")
			Object.Parent = ProxyModel
			ProxyModel:PivotTo(Position)
			Object.Parent = workspace
			ProxyModel:Destroy()
		end
	end
end

function Inserter:_LoadBundle(ID)
	local ok, Details = pcall(function()
		return AssetService:GetBundleDetailsAsync(ID)
	end)
	
	if not ok then return false end

	local Character = (self.Settings.Rig == "R15" and Characters.R15 or Characters.R6):Clone()

	local outfitId;
	for _, Item in pairs(Details.Items) do
		if Item.Type == "UserOutfit" then
			outfitId = Item.Id
			break;
		end
	end

	local ok, HumanoidDescription = pcall(function()
		return Players:GetHumanoidDescriptionFromOutfitId(outfitId)
	end)

	if not ok then
		warn("Failed to get HumanoidDescription")
		return
	end

	Character.Name = Details.Name
	Character.Parent = workspace

	Character.Humanoid:ApplyDescription(HumanoidDescription)
	HumanoidDescription:Destroy()

	self:_ApplyModifications(Character)

	return true
end

function Inserter:_Insert(ID)
	local ok, Objects = pcall(function()
		return game:GetObjects("rbxassetid://" .. ID)
	end)

	if ok then
		for _, Object in pairs(Objects) do
			self:_ApplyModifications(Object)
			if Object.Parent == nil then
				Object.Parent = workspace
			end
		end
		return true
	end

	-- if it couldn't insert the id, try to insert it as a bundle
	local Bundle = self:_LoadBundle(ID)

	if not Bundle then
		warn("Failed to insert " .. ID)
	end
end

-- Public
function Inserter:ToggleSetting(Name, Value)
	if self.Settings[Name] ~= nil then
		self.Settings[Name] = Value
	end
end

function Inserter:Insert(Text)
	local IDs = Util.ExtractIDs(Text)
	if #IDs < 1 then return end

	ChangeHistoryService:SetWaypoint("PreInsert" .. os.clock())

	for _, ID in pairs(IDs) do
		self:_Insert(ID)
	end

	ChangeHistoryService:SetWaypoint("PostInsert" .. os.clock())
end

return Inserter