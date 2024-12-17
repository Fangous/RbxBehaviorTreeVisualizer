--!strict
local Vide = require(script.Parent.Parent.Parent.Packages.Vide)

local create = Vide.create

return function()
	return create "Frame" {
		BackgroundColor3 = Color3.new(1, 0, 0),
		Size = UDim2.fromScale(1, 1),
	}
end
