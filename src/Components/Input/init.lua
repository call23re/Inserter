local Plugin = script.Parent.Parent

local Roact = require(Plugin.Packages.roact)
local StudioComponents = require(Plugin.Packages.studiocomponents)
local Util = require(Plugin.Util)

local Clear = require(script.Clear)
local withTheme = StudioComponents.withTheme

local Input = Roact.PureComponent:extend("InputBar")

function Input:init()
	self:setState({
		Text = "",
		TextFits = true,
		Focused = false
	})

	self.Ref = Roact.createRef()

	self.TextChanged = function(TextBox)
		local Text = Util.Sanitize(TextBox.Text)
		self.Ref:getValue().Text = Text

		if Text ~= self.state.Text then
			self:setState({
				Text = Text
			})

			if self.props.TextChanged then
				self.props.TextChanged(Text)
			end
		end

	end

	self.TextFitsChanged = function(TextBox)
		self:setState({
			TextFits = TextBox.TextFits
		})
	end

	self.Focused = function()
		self:setState({
			Focused = true
		})
	end

	self.FocusLost = function()
		self:setState({
			Focused = false
		})
	end

	self.ClearClicked = function()
		self:setState({
			Text = "",
			Focused = true
		})
		
		if self.props.TextChanged then
			self.props.TextChanged("")
		end

		self.Ref:getValue():CaptureFocus()
	end
end

function Input:render()
	return withTheme(function(theme)

		local StrokeColors = {
			Focused = theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButton),
			Default = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBorder)
		}

		return Roact.createElement("Frame", {
			AnchorPoint = self.props.AnchorPoint,
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground),
			Size = self.props.Size,
			Position = self.props.Position
		}, {
			TextField = Roact.createElement("TextBox", {
				BackgroundTransparency = 1,
				ClipsDescendants = true,
				ClearTextOnFocus = false,

				Size = UDim2.new(1, -30, 1, 0),
				Position = UDim2.fromOffset(5, 0),

				Text = self.state.Text,
				PlaceholderText = self.props.PlaceholderText,
				
				Font = Enum.Font.SourceSans,
				TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
				PlaceholderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DimmedText),
				TextSize = 16,

				TextXAlignment = self.state.TextFits and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right,

				[Roact.Ref] = self.Ref,
				[Roact.Change.Text] = self.TextChanged,
				[Roact.Change.TextFits] = self.TextFitsChanged,
				[Roact.Event.Focused] = self.Focused,
				[Roact.Event.FocusLost] = self.FocusLost
			}),

			ClearButton = Roact.createElement(Clear, {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(1, -20, 0.5, 0),
				Visible = self.state.Text ~= "",

				onActivated = function()
					self.ClearClicked()
				end
			}),
			
			Stroke = Roact.createElement("UIStroke", {
				Color = self.state.Focused and StrokeColors.Focused or StrokeColors.Default
			}),

			Corner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 4)
			})
		})
	end)
end

return Input