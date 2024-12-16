--!strict
local Vide = require(script.Parent.Parent.Parent.Packages.Vide)
local RbxBehaviorTree = require(script.Parent.Parent.Parent.Packages.RbxBehaviorTree)

local TreeGraph = require(script.Parent.Parent.Components.TreeGraph)

local create = Vide.create

type Props = {
	FullName: string,
	ScreenSize: Vector2,
	Root: RbxBehaviorTree.Node,
}

return function(props: Props)
	return create "ScreenGui" {
		create "Frame" {
			Name = "Background",
			BackgroundColor3 = Color3.fromRGB(46, 46, 46),
			Size = UDim2.fromScale(1, 2),
			Position = UDim2.fromScale(0, -1),
		},
		TreeGraph {
			ScreenSize = props.ScreenSize,
			Root = props.Root,
		},
		create "TextLabel" {
			AnchorPoint = Vector2.new(0.5, 0),
			Size = UDim2.fromScale(1, 0.075),
			Position = UDim2.new(0.5, 4, 0, 4),
			BackgroundTransparency = 1,
			TextScaled = true,
			Text = props.FullName,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		},
		create "Frame" {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			create "TextLabel" {
				Size = UDim2.fromScale(1, 0.04),
				BackgroundTransparency = 1,
				TextScaled = true,
				Text = "Green - SequenceNode",
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = 1,
				TextColor3 = Color3.fromRGB(100, 255, 100),
				create "UIStroke" {},
			},
			create "TextLabel" {
				Size = UDim2.fromScale(1, 0.04),
				BackgroundTransparency = 1,
				TextScaled = true,
				Text = "Red - FallbackNode",
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = 2,
				TextColor3 = Color3.fromRGB(255, 100, 100),
				create "UIStroke" {},
			},
			create "TextLabel" {
				Size = UDim2.fromScale(1, 0.04),
				BackgroundTransparency = 1,
				TextScaled = true,
				Text = "Blue - ActionNode",
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = 3,
				TextColor3 = Color3.fromRGB(100, 100, 255),
				create "UIStroke" {},
			},
			create "TextLabel" {
				Size = UDim2.fromScale(1, 0.04),
				BackgroundTransparency = 1,
				TextScaled = true,
				Text = "Reminder: Behavior trees solve from top to bottom, left to right!",
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = 4,
				TextColor3 = Color3.new(1, 1, 1),
				create "UIStroke" {},
			},
			create "UIListLayout" {
				FillDirection = Enum.FillDirection.Vertical,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
		},
		create "TextButton" {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = "",
			ZIndex = 3,
		},
	}
end
