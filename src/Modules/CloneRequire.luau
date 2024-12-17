--!strict
return function(module: ModuleScript): any
	local clonedModule = module:Clone()
	clonedModule.Parent = module.Parent

	local success, result = pcall(function()
		return require(clonedModule) :: any
	end)

	clonedModule:Destroy()

	return success and result or nil
end
