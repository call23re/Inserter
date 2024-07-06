local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local function joinDictionaries(...)
	local out = {}
	for i = 1, select("#", ...) do
		for key, val in pairs(select(i, ...)) do
			out[key] = val
		end
	end
	return out
end

local function ReplaceNewlines(Text)
	return Text and Text:gsub("\n", ",") or ""
end

local function ExtractIds(Text)
	local Ids = {}

	for Id, _ in Text:gmatch('[^,]+') do
		table.insert(Ids, tonumber(Id))
	end

	return Ids
end

local function Sanitize(Text)
	Text = ReplaceNewlines(Text)
	Text = Text:gsub("[^%d,]+", "")
	return Text
end

export type AssetType = {
	["OBJECT"]: boolean,
	["BUNDLE"]: boolean,
	["CHARACTER"]: boolean
}

local Cache = {}

local function DetermineAssetType(Id): AssetType
	if Cache[Id] then return Cache[Id] end

	local options: AssetType = {
		["OBJECT"] = false,
		["BUNDLE"] = false,
		["CHARACTER"] = false
	}

	local ok = pcall(function() 
		return MarketplaceService:GetProductInfo(Id)
	end)

	if ok then
		options["OBJECT"] = true
	end

	ok = pcall(function()
		return MarketplaceService:GetProductInfo(Id, Enum.InfoType.Bundle)
	end)

	if ok then
		options["BUNDLE"] = true
	end

	ok = pcall(function()
		return Players:GetNameFromUserIdAsync(Id)
	end)

	if ok then
		options["CHARACTER"] = true
	end

	Cache[Id] = options

	return options
end

return {
	joinDictionaries = joinDictionaries,
	ReplaceNewlines = ReplaceNewlines,
	ExtractIds = ExtractIds,
	Sanitize = Sanitize,
	DetermineAssetType = DetermineAssetType
}