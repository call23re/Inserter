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
		Camera = false,
		Unlock = true,
		Rig = "R15",
		Valid = false,
		Text = ""
	})

	self.Update = function(Key, Value)
		self:setState({
			[Key] = Value
		})
		Inserter:ToggleSetting(Key, Value)
	end

	self.TextChanged = function(Text)
		self:setState({
			Text = Text,
			Valid = #Util.ExtractIDs(Text) >= 1
		})
	end

	self.Insert = function()
		if self.state.Text ~= "" then
			Inserter:Insert(self.state.Text)
		end
	end
end

function App:render()
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

		Insert = Roact.createElement(RoundButton, {
			Text = "Insert",
			AnchorPoint = Vector2.new(0.5, 0),
			Size = UDim2.new(1, -20, 0, 35),
			Position = UDim2.new(0.5, 0, 1, -50),
			TextSize = 16,
			Font = Enum.Font.SourceSansSemibold,
			Disabled = not self.state.Valid,
			OnActivated = self.Insert
		})
	})
end

return App