return function()
	local StoreProvider = require(script.Parent.StoreProvider)

	local Roact = require(script.Parent.Parent.Roact)
	local Rodux = require(script.Parent.Parent.Rodux)
	local folder = Instance.new("Folder")

	it("should be instantiable as a component", function()
		local store = Rodux.Store.new(function()
			return 0
		end)
		local element = Roact.createElement(StoreProvider, {
			store = store
		})

		expect(element).to.be.ok()

		local handle = Roact.mount(element, nil, "StoreProvider-test")

		Roact.unmount(handle)
		store:destruct()
	end)

	it("should expect a 'store' prop", function()
		local element = Roact.createElement(StoreProvider)

		expect(function()
			Roact.mount(element)
		end).to.throw()
	end)

	it("should accept multiple children", function()
		local store = Rodux.Store.new(function()
			return 0
		end)

		local element = Roact.createElement(StoreProvider, {
			store = store
		}, {
			test1 = Roact.createElement("Frame"),
			test2 = Roact.createElement("Frame"),
			test3 = Roact.createElement("Frame")
		})

		expect(element).to.be.ok()

		local handle = Roact.mount(element, folder, "StoreProvider-test")

		local children = folder:GetChildren()
		local count = 0

		for i, v in ipairs(children) do
			count  = count + 1
		end

		expect(count).to.be.equal(3)

		Roact.unmount(handle)
		store:destruct()
	end)
end