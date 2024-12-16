--!strict
local CoreGui = game:GetService("CoreGui")
local Selection = game:GetService("Selection")
local RunService = game:GetService("RunService")

local RbxBehaviorTree = require(script.Packages.RbxBehaviorTree)
local Trove = require(script.Packages.Trove)
local Vide = require(script.Packages.Vide)

local Constants = require(script.Constants)
local TreeView = require(script.Interface.Views.TreeView)

local PLUGIN_NAME = Constants.PLUGIN_NAME
local VERSION = Constants.VERSION

local NodeTypes = RbxBehaviorTree.NodeTypes

local mount = Vide.mount
local cleanup = Vide.cleanup

local pluginFullName = `{PLUGIN_NAME} v{VERSION}`
local camera = workspace.Camera
local pluginTrove = Trove.new()
local viewTrove = pluginTrove:Extend()
local isClient = RunService:IsClient()
local isRunning = RunService:IsRunning()
local isStudio = RunService:IsStudio()
local isEdit = not isRunning

local function isBehaviorTreeNode(object: Instance): RbxBehaviorTree.Node?
	if not object:IsA("ModuleScript") then
		return
	end

	local clonedModule = object:Clone()
	clonedModule.Parent = object.Parent

	local success, requiredModule = pcall(function()
		return require(clonedModule) :: any
	end)

	clonedModule:Destroy()

	if typeof(requiredModule) == "function" then
		local result = requiredModule()
		if result.RootNode and result.Destroy then
			return result.RootNode
		end
	elseif requiredModule.NodeType and requiredModule.NodeType ~= NodeTypes.ACTION then
		return requiredModule
	elseif requiredModule.RootNode and requiredModule.Destroy then
		return requiredModule.RootNode
	end

	return
end

local function getSelectedRootNode(): (ModuleScript?, RbxBehaviorTree.Node?)
	local currentSelection = Selection:Get() or {} :: { Instance }
	local isOnlyOneInstanceSelected = #currentSelection == 1
	if not isOnlyOneInstanceSelected then
		return
	end

	local selectedInstance = currentSelection[1]
	local success, behaviorTreeNode = pcall(function()
		return isBehaviorTreeNode(selectedInstance)
	end)

	if success and behaviorTreeNode then
		return selectedInstance, behaviorTreeNode
	else
		return
	end
end

local function createView(module: ModuleScript, rootNode: RbxBehaviorTree.Node)
	viewTrove:Clean()

	local function app()
		local screenGui = TreeView {
			FullName = module:GetFullName(),
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
	pluginTrove:Connect(Selection.SelectionChanged, function()
		viewTrove:Clean()

		local selectedInstance, selectedRootNode = getSelectedRootNode()
		if selectedInstance and selectedRootNode then
			createView(selectedInstance, selectedRootNode)
		end
	end)
end

if isClient then
	if isStudio and isEdit then
		initPlugin()

		warn(`[{pluginFullName}] Enabled plugin!`)
	else
		warn(`[{pluginFullName}] Disabled plugin during Run mode!`)
	end
end
