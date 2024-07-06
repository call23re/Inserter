--!strict

local AssetService = game:GetService("AssetService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Players = game:GetService("Players")
local Selection = game:GetService("Selection")

local DefaultSettings = require(script.Parent.DefaultSettings)
local Util = require(script.Parent.Util)

local CharacterModels = script.Parent.Models

type Rig = "R6" | "R15" | "BOTH"
type Settings = {
	UnlockDescendants: boolean,
	MoveToCamera: boolean,
	ParentToSelection: boolean,
	Rig: Rig
}

export type AssetType = "OBJECT" | "BUNDLE" | "CHARACTER"

type Ok = { status: "OK", value: {any} }
type Error = { status: "ERROR", error: string }
type Result = Ok | Error

local Settings = DefaultSettings :: Settings

local function ApplyModifications(Object, AssetType: AssetType)
	if Settings.UnlockDescendants then
		pcall(function()
			Object.Locked = false
		end)

		for _, v in Object:GetDescendants() do
			pcall(function()
				v.Locked = false
			end)
		end
	end

	local Camera = workspace.CurrentCamera
	if not Camera then return end

	if Settings.MoveToCamera or AssetType ~= "OBJECT" then
		local Position;

		if AssetType == "BUNDLE" or AssetType == "CHARACTER" then
			Position = CFrame.new((Camera.CFrame + (Camera.CFrame.LookVector * 15)).Position)
		end

		if Settings.MoveToCamera then
			Position = CFrame.new(Camera.CFrame.Position)
		end

		if Object:IsA("Model") or Object:IsA("BasePart") then
			Object:PivotTo(Position)
		else
			pcall(function()
				local ProxyModel = Instance.new("Model")
				Object.Parent = ProxyModel
				ProxyModel:PivotTo(Position)
				Object.Parent = workspace
				ProxyModel:Destroy()
			end)
		end
	end
end

local function LoadBundle(Id): Result
	local ok, Details = pcall(function()
		return AssetService:GetBundleDetailsAsync(Id)
	end)

	if not ok then
		return { status = "ERROR", error = "Could not find bundle details" }
	end

	local outfitId;
	for _, Item in Details.Items do
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
		return { status = "ERROR", error = "Failed to get HumanoidDescription" }
	end

	local Characters = {}

	if Settings.Rig == "R15" or Settings.Rig == "BOTH" then
		table.insert(Characters, CharacterModels.R15:Clone())
	end

	if Settings.Rig == "R6" or Settings.Rig == "BOTH" then
		table.insert(Characters, CharacterModels.R6:Clone())
	end

	for _, Character in Characters do
		Character.Name = Details.Name
		Character.Parent = workspace

		Character.Humanoid:ApplyDescription(HumanoidDescription)
		HumanoidDescription:Destroy()

		ApplyModifications(Character, "BUNDLE")
	end

	return { status = "OK", value = Characters }
end

local function LoadCharacter(Id): Result
	local Models = {}

	local ok, Description = pcall(function()
		return Players:GetHumanoidDescriptionFromUserId(Id)
	end)

	if not ok then
		return { status = "ERROR", error = "Failed to get humanoid description" }
	end

	local ok, username = pcall(function()
		return Players:GetNameFromUserIdAsync(Id)
	end)

	if not ok then
		username = "Player"
	end

	if Settings.Rig == "R15" or Settings.Rig == "BOTH" then
		local ok, Model = pcall(function()
			return Players:CreateHumanoidModelFromDescription(Description, Enum.HumanoidRigType.R15)
		end)

		if ok then
			Model.Name = username
			table.insert(Models, Model)
		end
	end

	if Settings.Rig == "R6" or Settings.Rig == "BOTH" then
		local ok, Model = pcall(function()
			return Players:CreateHumanoidModelFromDescription(Description, Enum.HumanoidRigType.R6)
		end)

		if ok then
			Model.Name = username
			table.insert(Models, Model)
		end
	end

	if #Models == 0 then
		return { status = "ERROR", error = "Failed to insert character" }
	end

	for _, Model in Models do
		ApplyModifications(Model, "CHARACTER")
	end

	return { status = "OK", value = Models }
end

local function InsertObject(Id): Result
	local Selected = Settings.ParentToSelection and Selection:Get()[1] or workspace

	local ok, Objects = pcall(function()
		return game:GetObjects(`rbxassetid://{Id}`)
	end)

	if ok then
		for _, Object in Objects do
			ApplyModifications(Object, "OBJECT")
			pcall(function()
				Object.Parent = Selected
			end)
		end
		return { status = "OK", value = Objects }
	end

	warn(`Failed to insert object {Id}`)
	return { status = "ERROR", error = "Failed to insert object" }
end

local function InsertBundle(Id): Result
	local Selected = Settings.ParentToSelection and Selection:Get()[1] or workspace

	local Bundles = LoadBundle(Id)
	if Bundles.status == "OK" then
		for _, Bundle in Bundles.value do
			pcall(function()
				Bundle.Parent = Selected
			end)
		end
		return { status = "OK", value = Bundles.value }
	end

	warn(`Failed to insert bundle {Id}`)
	return { status = "ERROR", error = "Failed to insert bundle" }
end

local function InsertCharacter(Id): Result
	local Selected = Settings.ParentToSelection and Selection:Get()[1] or workspace
	
	local Characters = LoadCharacter(Id)
	if Characters.status == "OK" then
		for _, Character in Characters.value do
			pcall(function()
				Character.Parent = Selected
			end)
		end
		return { status = "OK", value = Characters.value }
	end

	warn(`Failed to insert player/character {Id}`)
	return { status = "ERROR", error = "Failed to insert character" }
end

local function Insert(Id): Result
	-- insert as asset
	local result = InsertObject(Id)
	if result.status == "OK" then
		return result
	end

	-- insert as bundle
	local result = InsertBundle(Id)
	if result.status == "OK" then
		return result
	end

	-- insert as character
	local result = InsertCharacter(Id)
	if result.status == "OK" then
		return result
	end

	return { status = "ERROR", error = "Failed to insert" }
end

local function Process(Text, AssetType: AssetType?)
	local Ids = Util.ExtractIds(Text)
	if #Ids < 1 then return end

	local recording = ChangeHistoryService:TryBeginRecording("Insert", "Inserting applicable asset ids.")

	local Inserted = {}

	if AssetType == "OBJECT" then
		local result = InsertObject(Ids[1])
		if result.status == "OK" then
			Inserted = result.value
		end
	elseif AssetType == "BUNDLE" then
		local result = InsertBundle(Ids[1])
		if result.status == "OK" then
			Inserted = result.value
		end
	elseif AssetType == "CHARACTER" then
		local result = InsertCharacter(Ids[1])
		if result.status == "OK" then
			Inserted = result.value
		end
	else
		for _, Id in Ids do
			local result = Insert(Id)
			if result.status ~= "OK" then continue end
			table.move(result.value, 1, #result.value, #Inserted + 1, Inserted)
		end
	end

	Selection:Set(Inserted)

	if recording then
		ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
	end
end

return {
	Insert = Process,
	-- TODO: temp
	Toggle = function(key, value)
		Settings[key] = value
	end,
	SetUnlockDescendants = function(bool: boolean)
		Settings.UnlockDescendants = bool
	end,
	SetMoveToCamera = function(bool: boolean)
		Settings.MoveToCamera = bool
	end,
	SetParentToSelection = function(bool: boolean)
		Settings.ParentToSelection = bool
	end,
	SetRig = function(Rig: Rig)
		Settings.Rig = Rig
	end
}