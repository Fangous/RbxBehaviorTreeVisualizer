--!strict
local Selection = game:GetService("Selection")

local RbxBehaviorTree = require(script.Parent.Parent.Packages.RbxBehaviorTree)

local CloneRequire = require(script.Parent.CloneRequire)
local Constants = require(script.Parent.Parent.Tables.Constants)

local PLUGIN_NAME = Constants.PLUGIN_NAME
local VERSION = Constants.VERSION
local PLUGIN_EXTENSION = Constants.PLUGIN_EXTENSION

local pluginFullName = `{PLUGIN_NAME} v{VERSION}`

export type SelectedNodeInfo = {
	Name: string,
	Node: RbxBehaviorTree.Node,
}

local Util = {}

function Util.Print(message: string)
	print(`[{pluginFullName}] {message}`)
end

function Util.Warn(message: string)
	warn(`[{pluginFullName}] {message}`)
end

function Util.HasPluginExtension(instance: Instance): boolean
	return string.match(instance.Name, "%" .. PLUGIN_EXTENSION .. "$") and true or false
end

function Util.GetSingularInstanceSelected(): Instance?
	local currentSelection = Selection:Get() or {} :: { Instance }

	local singularInstanceSelected = #currentSelection == 1
	if not singularInstanceSelected then
		return nil
	end

	return currentSelection[1]
end

function Util.GetNodeFromValidModule(module: ModuleScript): RbxBehaviorTree.Node?
	if not Util.HasPluginExtension(module) then
		return nil
	end

	local requiredModule = CloneRequire(module)
	if requiredModule then
		if typeof(requiredModule) == "function" then
			local result = requiredModule()
			if result.NodeType then
				return result :: RbxBehaviorTree.Node
			elseif result.RootNode and result.Destroy then
				return result.RootNode :: RbxBehaviorTree.Node
			end
		elseif requiredModule.NodeType then
			return requiredModule :: RbxBehaviorTree.Node
		elseif requiredModule.RootNode and requiredModule.Destroy then
			return requiredModule.RootNode :: RbxBehaviorTree.Node
		end
	end

	return nil
end

function Util.GetSelectedNodeInfoFromSelection(): SelectedNodeInfo?
	local currentSelection = Util.GetSingularInstanceSelected()

	if not (currentSelection and currentSelection:IsA("ModuleScript")) then
		return nil
	end

	if not Util.HasPluginExtension(currentSelection) then
		return nil
	end

	local selectedNode = Util.GetNodeFromValidModule(currentSelection)
	return {
		Name = currentSelection.Name,
		Node = selectedNode,
	}
end

return Util
