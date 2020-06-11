return function()
	local StoreProvider = require(script.Parent.StoreProvider)

	local Roact = require(script.Parent.Parent.Roact)
	local Rodux = require(script.Parent.Parent.Rodux)
	local StoreContext = Roact.createContext()

	it("should be instantiable as a component", function()
		local store = Rodux.Store.new(function()
			return 0
		end)
		local element = Roact.createElement(StoreProvider, {
			store = store,
			Provider = StoreContext.Provider
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

		local consumedStore1 = nil
		local consumedStore2 = nil


		local element = Roact.createElement(StoreProvider, {
			store = store,
			Provider = StoreContext.Provider
		}, {
			test1 = Roact.createElement(StoreContext.Consumer, {
				render = function(store)
					consumedStore1 = store
				end
			}),
			test2 = Roact.createElement(StoreContext.Consumer, {
				render = function(store)
					consumedStore2 = store
				end
			}),
		})

		expect(element).to.be.ok()

		local handle = Roact.mount(element, nil, "StoreProvider-test")

		expect(consumedStore1).to.be.equal(store)
		expect(consumedStore2).to.be.equal(store)

		Roact.unmount(handle)
		store:destruct()
	end)
end