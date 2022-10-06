local Plugin = script.Parent

local Roact = require(Plugin.Packages.roact)
local MainPlugin = require(Plugin.Components.MainPlugin)

local toolbar = plugin:CreateToolbar("Inserter")
local button = toolbar:CreateButton(
	"Inserter",
	"Inserter",
	"rbxassetid://11190713352"
)
button.ClickableWhenViewportHidden = true

local Main = Roact.createElement(MainPlugin, {
	Button = button
})

local handle = Roact.mount(Main)

plugin.Unloading:Connect(function()
	Roact.unmount(handle)
end)