--!strict
local UserInputService = game:GetService("UserInputService")

local Vide = require(script.Parent.Parent.Parent.Packages.Vide)
local RbxBehaviorTree = require(script.Parent.Parent.Parent.Packages.RbxBehaviorTree)

local create = Vide.create
local source = Vide.source
local cleanup = Vide.cleanup

local SEQUENCE_COLOR = Color3.fromRGB(100, 255, 100)
local FALLBACK_COLOR = Color3.fromRGB(255, 100, 100)
local ACTION_COLOR = Color3.fromRGB(100, 100, 255)

local NODE_X_SPACING = 50
local NODE_Y_SPACING = 100

type Props = {
	ScreenSize: Vector2,
	Root: RbxBehaviorTree.Node,
}

local function calculateSubtreeWidth(node: RbxBehaviorTree.Node): number
	if #node.SubTree == 0 then
		return NODE_X_SPACING
	end

	local totalWidth = 0
	for _, child in ipairs(node.SubTree) do
		totalWidth += calculateSubtreeWidth(child) + NODE_X_SPACING
	end

	return math.max(totalWidth - NODE_X_SPACING, NODE_X_SPACING)
end

local function createNodeUI(node: RbxBehaviorTree.Node, x: number, y: number)
	return create "Frame" {
		Size = UDim2.new(0, NODE_X_SPACING, 0, NODE_X_SPACING),
		Position = UDim2.new(0, x, 0, y),
		BackgroundColor3 = node.NodeType == "SEQUENCE" and SEQUENCE_COLOR
			or node.NodeType == "FALLBACK" and FALLBACK_COLOR
			or ACTION_COLOR,
		ZIndex = 2,
		create "TextLabel" {
			Text = node.NodeName,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = math.floor(0.5 + NODE_X_SPACING / 3),
			FontFace = Font.new("Arimo", Enum.FontWeight.SemiBold),
			ZIndex = 2,
			create "UIStroke" {
				Color = Color3.new(0, 0, 0),
			},
		},
		create "UIStroke" {
			Color = Color3.new(0, 0, 0),
		},
	}
end

local function createLine(x1: number, y1: number, x2: number, y2: number)
	local length = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
	local angle = math.atan2(y2 - y1, x2 - x1)

	return create "Frame" {
		Size = UDim2.new(0, length, 0, 2),
		Position = UDim2.new(0, (x1 + x2) / 2, 0, (y1 + y2) / 2),
		Rotation = math.deg(angle),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		ZIndex = 2,
	}
end

local function buildTree(node: RbxBehaviorTree.Node, x: number, y: number)
	local elements = { createNodeUI(node, x, y) }

	local childXOffset = x - calculateSubtreeWidth(node) / 2
	for _, child in ipairs(node.SubTree) do
		local subtreeWidth = calculateSubtreeWidth(child)
		local childX = childXOffset + subtreeWidth / 2
		local childY = y + NODE_Y_SPACING

		-- Add line and child node elements directly to `elements`
		table.insert(
			elements,
			createLine(x + NODE_X_SPACING / 2, y + NODE_X_SPACING, childX + NODE_X_SPACING / 2, childY)
		)
		table.insert(elements, buildTree(child, childX, childY))

		childXOffset += subtreeWidth + NODE_X_SPACING
	end

	return elements
end

return function(props: Props)
	local screenSize = props.ScreenSize
	local startX = screenSize.X / 2
	local startY = screenSize.Y / 3

	NODE_X_SPACING = screenSize.Y / 13.5
	NODE_Y_SPACING = NODE_X_SPACING * 2

	local framePosition = source(UDim2.fromOffset(startX, startY))
	local scale = source(1)
	local dragging = false
	local dragStartPosition = Vector3.new(0, 0, 0)
	local offset = UDim2.fromOffset(0, 0)

	local inputBeganConnection = UserInputService.InputBegan:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStartPosition = input.Position
			offset = framePosition() - UDim2.fromOffset(input.Position.X, input.Position.Y)
		end
	end)

	local inputChangedConnection = UserInputService.InputChanged:Connect(function(input: InputObject)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = UDim2.fromOffset(input.Position.X, input.Position.Y) + offset
			local newPos = UDim2.fromOffset(delta.X.Offset, delta.Y.Offset)
			framePosition(newPos)
		end

		if input.UserInputType == Enum.UserInputType.MouseWheel then
			local direction = input.Position.Z
			scale(math.clamp(scale() + direction / 10, 0.1, 2.5))
		end
	end)

	local inputEndedConnection = UserInputService.InputEnded:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	cleanup(function()
		inputBeganConnection:Disconnect()
		inputChangedConnection:Disconnect()
		inputEndedConnection:Disconnect()
	end)

	return create "Frame" {
		Name = "Background",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(46, 46, 46),
		Size = UDim2.fromScale(1, 1),
		Position = function()
			return framePosition()
		end,
		create "UIScale" {
			Scale = function()
				return scale()
			end,
		},
		buildTree(props.Root, startX, startY),
	}
end
