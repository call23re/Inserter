local AssetService = game:GetService("AssetService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Players = game:GetService("Players")
local Selection = game:GetService("Selection")

local DefaultSettings = require(script.Parent.DefaultSettings)
local Util = require(script.Parent.Util)

local CharacterModels = script.Parent.Models

local Inserter = {
	Settings = DefaultSettings
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

	local Characters = {}

	if self.Settings.Rig == "R15" or self.Settings.Rig == "Both" then
		table.insert(Characters, CharacterModels.R15:Clone())
	end

	if self.Settings.Rig == "R6" or self.Settings.Rig == "Both" then
		table.insert(Characters, CharacterModels.R6:Clone())
	end

	for _, Character in Characters do
		Character.Name = Details.Name
		Character.Parent = workspace

		Character.Humanoid:ApplyDescription(HumanoidDescription)
		HumanoidDescription:Destroy()

		self:_ApplyModifications(Character)
	end

	return Characters
end

function Inserter:_Insert(ID)
	local Selected = self.Settings.Parent and Selection:Get()[1] or workspace

	local ok, Objects = pcall(function()
		return game:GetObjects("rbxassetid://" .. ID)
	end)

	if ok then
		for _, Object in pairs(Objects) do
			self:_ApplyModifications(Object)
			Object.Parent = Selected
		end
		return Objects
	end

	-- if it couldn't insert the id, try to insert it as a bundle
	local Bundles = self:_LoadBundle(ID)

	if Bundles then
		for _, Bundle in Bundles do
			Bundle.Parent = Selected
		end
		return Bundles
	end

	warn("Failed to insert " .. ID)
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

	local Inserted = {}

	for _, ID in pairs(IDs) do
		local Item = self:_Insert(ID)
		if typeof(Item) == "table" then
			table.move(Item, 1, #Item, #Inserted + 1, Inserted)
		elseif typeof(Item) ~= nil then
			table.insert(Inserted, Item)
		end
	end

	Selection:Set(Inserted)

	ChangeHistoryService:SetWaypoint("PostInsert" .. os.clock())
end

return Inserter