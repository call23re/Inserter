local Plugin = script.Parent.Parent

local Roact = require(Plugin.Packages.roact)
local StudioComponents = require(Plugin.Packages.studiocomponents)
local Util = require(Plugin.Util)

local joinDictionaries = Util.joinDictionaries
local Label = StudioComponents.Label
local BaseButton = StudioComponents.BaseButton

local function RoundButton(props)
	local Text = props.Text

	return Roact.createElement(BaseButton, joinDictionaries(props, {
		TextColorStyle = Enum.StudioStyleGuideColor.DialogMainButtonText,
		BackgroundColorStyle = Enum.StudioStyleGuideColor.DialogMainButton,
		BorderColorStyle = Enum.StudioStyleGuideColor.ButtonBorder,
		Text = ""
	}), {
		Corner = Roact.createElement("UICorner"),
		Label = Roact.createElement(Label, {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Text = Text,
			TextSize = props.TextSize,
			TextColorStyle = Enum.StudioStyleGuideColor.DialogMainButtonText,
			Font = props.Font,
			ZIndex = 2,
			Disabled = props.Disabled
		})
	})
end

return RoundButton