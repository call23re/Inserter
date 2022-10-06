local Plugin = script.Parent.Parent

local Roact = require(Plugin.Packages.roact)
local StudioComponents = require(Plugin.Packages.studiocomponents)
local DefaultSettings = require(Plugin.DefaultSettings)

local Checkbox = StudioComponents.Checkbox
local Dropdown = StudioComponents.Dropdown

local Settings = Roact.Component:extend("Settings")

function Settings:init()
	self:setState(DefaultSettings)

	self.onUpdateCamera = function()
		local newState = not self.state.Camera
		self:setState({
			Camera = newState
		})
		self.props.Update("Camera", newState)
	end

	self.onUpdateLock = function()
		local newState = not self.state.Unlock
		self:setState({
			Unlock = newState
		})
		self.props.Update("Unlock", newState)
	end

	self.onUpdateParent = function()
		local newState = not self.state.Parent
		self:setState({
			Parent = newState
		})
		self.props.Update("Parent", newState)
	end

	self.onUpdateRig = function(item)
		self:setState({
			Rig = item
		})
		self.props.Update("Rig", item)
	end
end

function Settings:render()
	return Roact.createElement("Frame", {
		AnchorPoint = self.props.AnchorPoint,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 35),
		Position = self.props.Position
	}, {
		Roact.createElement(Checkbox, {
			Label = "Place at Camera",
			Value = self.state.Camera,
			LayoutOrder = 1,
			OnActivated = self.onUpdateCamera
		}),
		Roact.createElement(Checkbox, {
			Label = "Unlock Children",
			Value = self.state.Unlock,
			LayoutOrder = 2,
			OnActivated = self.onUpdateLock
		}),
		Roact.createElement(Checkbox, {
			Label = "Parent to Selection",
			Value = self.state.Parent,
			LayoutOrder = 3,
			OnActivated = self.onUpdateParent
		}),
		Roact.createElement(Dropdown, {
			Items = {"R15", "R6"},
			Item = self.state.Rig,
			LayoutOrder = 4,
			OnSelected = self.onUpdateRig
		}),
		ListLayout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 5)
		})
	})
end

return Settings