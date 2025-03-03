# RbxBehaviorTreeVisualizer

A Roblox Studio plugin for visualizing and debugging behavior trees created with the [RbxBehaviorTree](https://github.com/Fangous/RbxBehaviorTree/) package.

## Installation

You can get the latest version of this plugin here: https://create.roblox.com/store/asset/93075433602329/

## Usage

Simply click on a RbxBehaviorTree module script in the "Explorer" tab of your Roblox Studio file to open up a visual tree view.

In order for a module script to be recognized by the RbxBehaviorTreeVisualizer plugin, it must:
- return one of the following types: BehaviorTree, Node, or a function that returns either a BehaviorTree or a Node
- have a name ending with '.rbxbtree' - for example: TestTree.rbxbtree
    - If using Rojo, the example file name would be: TestTree.rbxbtree.luau

## Preview

Example screenshot of the plugin:
<div align="center">
    <a href="https://create.roblox.com/store/asset/93075433602329/"><img src="images/pluginPreview.png" alt="Plugin Link" height="420" /></a>
</div>
