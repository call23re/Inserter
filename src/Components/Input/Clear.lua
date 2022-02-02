local Plugin = script.Parent.Parent.Parent

local Roact = require(Plugin.Packages.roact)
local StudioComponents = require(Plugin.Packages.studiocomponents)

local withTheme = StudioComponents.withTheme

local Clear = Roact.Component:extend("Clear")

local Images = {
	Hovered = "rbxasset://textures/StudioToolbox/ClearHover.png",
	Default = "rbxasset://textures/StudioToolbox/Clear.png"
}

function Clear:init()
	self:setState({
		Hovered = false
	})

	self.onInputBegan = function(_, inputObject)
		if self.props.Disabled then
			return
		elseif inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			self:setState({ Hovered = true })
		elseif inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			self:setState({ Pressed = true })
		end
	end

	self.onInputEnded = function(_, inputObject)
		if self.props.Disabled then
			return
		elseif inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			self:setState({ Hovered = false })
		elseif inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			self:setState({ Pressed = false })
		end
	end

	self.onActivated = function()
		self:setState({
			Hovered = false
		})

		if self.props.onActivated then
			self.props.onActivated()
		end
	end
end

function Clear:render()
	return withTheme(function(theme)

		local Colors = {
			Hovered = theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButton),
			Default = theme:GetColor(Enum.StudioStyleGuideColor.SubText)
		}

		return Roact.createElement("ImageButton", {
			AnchorPoint = self.props.AnchorPoint,
			BackgroundTransparency = 1,
			Size = self.props.Size or UDim2.fromOffset(15, 15),
			Position = self.props.Position,
			Visible = self.props.Visible,
			Image = self.state.Hovered and Images.Hovered or Images.Default,
			ImageColor3 = self.state.Hovered and Colors.Hovered or Colors.Default,

			[Roact.Event.InputBegan] = self.onInputBegan,
			[Roact.Event.InputEnded] = self.onInputEnded,
			[Roact.Event.Activated] = self.onActivated
		})
	end)
end

return Clear