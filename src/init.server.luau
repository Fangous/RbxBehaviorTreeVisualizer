--!strict
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Selection = game:GetService("Selection")
local RunService = game:GetService("RunService")

local Trove = require(script.Packages.Trove)
local Vide = require(script.Packages.Vide)

local State = require(script.Tables.State)
local Util = require(script.Modules.Util)
local TreeView = require(script.Interface.Views.TreeView)

local mount = Vide.mount
local effect = Vide.effect
local cleanup = Vide.cleanup

local camera = Workspace.Camera
local pluginTrove = Trove.new()
local viewTrove = pluginTrove:Extend()
local isClient = RunService:IsClient()
local isRunning = RunService:IsRunning()
local isStudio = RunService:IsStudio()
local isEdit = not isRunning

local function createTreeView(rootNode: Util.SelectedNodeInfo)
	local function app()
		local screenGui = TreeView {
			FullName = rootNode.Name,
			ScreenSize = camera.ViewportSize,
			Root = rootNode.Node,
		}

		cleanup(function()
			screenGui:Destroy()
		end)

		return screenGui
	end

	viewTrove:Add(mount(app, CoreGui))
end

local function initPlugin()
	pluginTrove:Add(mount(function()
		effect(function()
			viewTrove:Clean()

			local currentNode = State.SelectedTreeNode()
			if currentNode then
				createTreeView(currentNode)
			end
		end)
	end, CoreGui))

	pluginTrove:Connect(Selection.SelectionChanged, function()
		State.SelectedTreeNode(Util.GetSelectedNodeInfoFromSelection())
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
