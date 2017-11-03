local lemur = require("modules.lemur")

--[[
	Collapse ModuleScripts named 'init' into their parent folders.
]]
local function collapse(root)
	local init = root:FindFirstChild("init")
	if init then
		init.Name = root.Name
		init.Parent = root.Parent

		for _, child in ipairs(root:GetChildren()) do
			child.Parent = init
		end

		root:Destroy()
		root = init
	end

	for _, child in ipairs(root:GetChildren()) do
		if child:IsA("Folder") then
			collapse(child)
		end
	end

	return root
end

local habitat = lemur.Habitat.new()

local Root = lemur.Instance.new("Folder")
Root.Name = "Root"

do
	local RoactRodux = lemur.Instance.new("Folder", Root)
	RoactRodux.Name = "RoactRodux"
	habitat:loadFromFs("lib", RoactRodux)
end

do
	local Roact = lemur.Instance.new("Folder", Root)
	Roact.Name = "Roact"
	habitat:loadFromFs("modules/roact/lib", Roact)
end

do
	local Rodux = lemur.Instance.new("Folder", Root)
	Rodux.Name = "Rodux"
	habitat:loadFromFs("modules/roact/lib", Rodux)
end

local TestEZ = lemur.Instance.new("Folder", Root)
TestEZ.Name = "TestEZ"
habitat:loadFromFs("modules/testez/lib", TestEZ)

collapse(Root)

local TestBootstrap = habitat:require(TestEZ.TestBootstrap)
local TextReporter = habitat:require(TestEZ.Reporters.TextReporter)

local results = TestBootstrap:run(Root.RoactRodux, TextReporter)

if results.failureCount > 0 then
	os.exit(1)
end