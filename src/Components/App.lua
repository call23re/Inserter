local Plugin = script.Parent.Parent

local Inserter = require(Plugin.Inserter)
local Util = require(Plugin.Util)

local Roact = require(Plugin.Packages.roact)
local StudioComponents = require(Plugin.Packages.studiocomponents)

local Background = StudioComponents.Background
local Input = require(script.Parent.Input)
local RoundButton = require(script.Parent.RoundButton)
local Settings = require(script.Parent.Settings)

local App = Roact.Component:extend("App")

function App:init()
	self:setState({
		Valid = false,
		Text = "",
		AssetType = {
			["OBJECT"] = true,
			["BUNDLE"] = false,
			["CHARACTER"] = false
		}
	})

	self.Update = function(Key, Value)
		Inserter.Toggle(Key, Value)
	end

	self.TextChanged = function(Text)
		local ids = Util.ExtractIds(Text)

		local AssetType: Util.AssetType = {
			["OBJECT"] = true,
			["BUNDLE"] = false,
			["CHARACTER"] = false
		}

		if #ids == 1 then
			AssetType = Util.DetermineAssetType(ids[1])
		end

		local invalid = false
		if AssetType.OBJECT == false and AssetType.BUNDLE == false and AssetType.CHARACTER == false then
			invalid = true
		end

		self:setState({
			Text = Text,
			Valid = #ids >= 1 and (not invalid),
			numIds = #ids,
			AssetType = AssetType
		})
	end

	self.Insert = function(AssetType: Inserter.AssetType)
		if self.state.Text ~= "" then
			Inserter.Insert(self.state.Text, self.state.numIds == 1 and AssetType or nil)
		end
	end
end

function App:render()
	local AssetType: Util.AssetType = self.state.AssetType

	local numButtons = 0
	numButtons += (AssetType.OBJECT) and 1 or 0
	numButtons += (AssetType.BUNDLE) and 1 or 0
	numButtons += (AssetType.CHARACTER) and 1 or 0

	local PADDING = 5

	return Roact.createElement(Background, {
		Size = UDim2.fromScale(1, 1)
	}, {
		Input = Roact.createElement(Input, {
			AnchorPoint = Vector2.new(0.5, 0),
			Size = UDim2.new(1, -20, 0, 25),
			Position = UDim2.new(0.5, 0, 0, 20),
			PlaceholderText = "ID(s)",
			TextChanged = self.TextChanged
		}),

		Settings = Roact.createElement(Settings, {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 10, 0, 60),
			Update = self.Update
		}),

		Buttons = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -20, 0, 35),
			Position = UDim2.new(0.5, 0, 1, -50),
		}, {
			Object = Roact.createElement(RoundButton, {
				Text = "Insert",
				Size = UDim2.new(if self.state.Valid then 1/numButtons else 1, numButtons > 1 and -PADDING or 0, 1, 0),
				TextSize = 16,
				Font = Enum.Font.SourceSansSemibold,
				Disabled = not self.state.Valid,
				OnActivated = function()
					if numButtons == 1 then
						self.Insert()
					else
						self.Insert("OBJECT")
					end
				end,
				LayoutOrder = 0,
				Visible = not self.state.Valid or AssetType.OBJECT
			}),
			Bundle = Roact.createElement(RoundButton, {
				Text = "Insert as Bundle",
				Size = UDim2.new(1/numButtons, numButtons > 1 and -PADDING or 0, 1, 0),
				TextSize = 16,
				Font = Enum.Font.SourceSansSemibold,
				Disabled = not self.state.Valid,
				OnActivated = function()
					self.Insert("BUNDLE")
				end,
				LayoutOrder = 1,
				Visible = AssetType.BUNDLE
			}),
			Character = Roact.createElement(RoundButton, {
				Text = "Insert as Player",
				Size = UDim2.new(1/numButtons, numButtons > 1 and -PADDING or 0, 1, 0),
				TextSize = 16,
				Font = Enum.Font.SourceSansSemibold,
				Disabled = not self.state.Valid,
				OnActivated = function()
					self.Insert("CHARACTER")
				end,
				LayoutOrder = 2,
				Visible = AssetType.CHARACTER
			}),
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, PADDING)
			})
		})
	})
end

return App