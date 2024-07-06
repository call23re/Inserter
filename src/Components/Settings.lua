local Plugin = script.Parent.Parent

local Roact = require(Plugin.Packages.roact)
local StudioComponents = require(Plugin.Packages.studiocomponents)
local DefaultSettings = require(Plugin.DefaultSettings)

local Checkbox = StudioComponents.Checkbox
local Dropdown = StudioComponents.Dropdown
local Label = StudioComponents.Label

local Settings = Roact.Component:extend("Settings")

function Settings:init()
	self:setState(DefaultSettings)

	self.onUpdateCamera = function()
		local newState = not self.state.MoveToCamera
		self:setState({
			MoveToCamera = newState
		})
		self.props.Update("MoveToCamera", newState)
	end

	self.onUpdateLock = function()
		local newState = not self.state.UnlockDescendants
		self:setState({
			UnlockDescendants = newState
		})
		self.props.Update("UnlockDescendants", newState)
	end

	self.onUpdateParent = function()
		local newState = not self.state.ParentToSelection
		self:setState({
			ParentToSelection = newState
		})
		self.props.Update("ParentToSelection", newState)
	end

	self.onUpdateRig = function(item)
		self:setState({
			Rig = item
		})
		self.props.Update("Rig", item:upper())
	end
end

function Settings:render()
	return Roact.createElement("Frame", {
		AnchorPoint = self.props.AnchorPoint,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 130),
		Position = self.props.Position
	}, {
		-- Checkboxes
		CheckboxContainer = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0.5, 0, 1, 0)
		}, {
			Camera = Roact.createElement(Checkbox, {
				Label = "Place at Camera",
				Value = self.state.MoveToCamera,
				LayoutOrder = 1,
				OnActivated = self.onUpdateCamera
			}),
			Unlock = Roact.createElement(Checkbox, {
				Label = "Unlock Children",
				Value = self.state.UnlockDescendants,
				LayoutOrder = 2,
				OnActivated = self.onUpdateLock
			}),
			Selection = Roact.createElement(Checkbox, {
				Label = "Parent to Selection",
				Value = self.state.ParentToSelection,
				LayoutOrder = 3,
				OnActivated = self.onUpdateParent
			}),
			ListLayout = Roact.createElement("UIListLayout", {
				Padding = UDim.new(0, 5)
			})
		}),
		-- Other
		DropdownContainer = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0.5, 0, 1, 0),
			Position = UDim2.new(0.5, 0, 0, 0)
		}, {
			Label = Roact.createElement(Label, {
				Size = UDim2.new(1, 0, 0, 15),
				Text = "Rig Type",
				TextXAlignment = "Left",
				LayoutOrder = 0,
			}),
			Dropdown = Roact.createElement(Dropdown, {
				Items = {"R15", "R6", "Both"},
				SelectedItem = self.state.Rig,
				Width = UDim.new(0, 100),
				LayoutOrder = 4,
				OnItemSelected = self.onUpdateRig
			}),
			ListLayout = Roact.createElement("UIListLayout", {
				Padding = UDim.new(0, 5),
				SortOrder = Enum.SortOrder.LayoutOrder,
			})
		}),
	})
end

return Settings