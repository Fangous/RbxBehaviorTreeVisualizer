--!strict
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Selection = game:GetService("Selection")
local RunService = game:GetService("RunService")

local RbxBehaviorTree = require(script.Packages.RbxBehaviorTree)
local Trove = require(script.Packages.Trove)
local Vide = require(script.Packages.Vide)

local State = require(script.Tables.State)
local Constants = require(script.Tables.Constants)
local Util = require(script.Modules.Util)
local WidgetView = require(script.Interface.Views.WidgetView)
local TreeView = require(script.Interface.Views.TreeView)

local PLUGIN_NAME = Constants.PLUGIN_NAME
local PLUGIN_ICON = Constants.PLUGIN_ICON
local VERSION = Constants.VERSION

local mount = Vide.mount
local effect = Vide.effect
local cleanup = Vide.cleanup

local pluginFullName = `{PLUGIN_NAME} v{VERSION}`
local camera = Workspace.Camera
local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left, false, false, 200, 300, 200, 200)
local pluginTrove = Trove.new()
local viewTrove = pluginTrove:Extend()
local isClient = RunService:IsClient()
local isRunning = RunService:IsRunning()
local isStudio = RunService:IsStudio()
local isEdit = not isRunning

local function createTreeView(rootNode: RbxBehaviorTree.Node)
	local function app()
		local screenGui = TreeView {
			FullName = "Tree",
			ScreenSize = camera.ViewportSize,
			Root = rootNode,
		}

		cleanup(function()
			screenGui:Destroy()
		end)

		return screenGui
	end

	viewTrove:Add(mount(app, CoreGui))
end

local function initPlugin()
	local toolbar = plugin:CreateToolbar(pluginFullName)
	local widgetButton = toolbar:CreateButton("Open Widget", "Open RbxBehaviorTreeVisualizer widget", PLUGIN_ICON)
	local widget = plugin:CreateDockWidgetPluginGui(pluginFullName, widgetInfo)

	pluginTrove:Add(mount(function()
		local screenGui = WidgetView()

		effect(function()
			viewTrove:Clean()

			local currentNode = State.SelectedTreeNode()
			if currentNode then
				createTreeView(currentNode)
			end
		end)

		cleanup(function()
			screenGui:Destroy()
		end)

		return screenGui
	end, widget))

	pluginTrove:Connect(widgetButton.Click, function()
		widget.Enabled = not widget.Enabled
		local isEnabled = widget.Enabled
		if not isEnabled then
			-- yeah...
			widgetButton.Enabled = false
			widgetButton.Enabled = true
		end
	end)

	pluginTrove:Connect(Selection.SelectionChanged, function()
		State.SelectedTreeNode(Util.GetNodeFromSelection())
	end)

	Util.Print("Enabled plugin!")
end

if isClient then
	if isStudio and isEdit then
		initPlugin()
	else
		Util.Warn("Disabled plugin during Run mode!")
	end
end
