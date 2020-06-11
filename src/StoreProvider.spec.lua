return function()
	local StoreProvider = require(script.Parent.StoreProvider)

	local Roact = require(script.Parent.Parent.Roact)
	local Rodux = require(script.Parent.Parent.Rodux)

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

		local TestComponent = Roact.Component:extend("TestComponent")
		local count = 0

		function TestComponent:render()
			count = count + 1
		end


		local element = Roact.createElement(StoreProvider, {
			store = store
		}, {
			test1 = Roact.createElement(TestComponent),
			test2 = Roact.createElement(TestComponent)
		})

		expect(element).to.be.ok()

		local handle = Roact.mount(element, nil, "StoreProvider-test")

		expect(count).to.be.equal(2)
		Roact.unmount(handle)
		store:destruct()
	end)
end