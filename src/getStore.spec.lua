return function()
	local Roact = require(script.Parent.Parent.Roact)
	local Rodux = require(script.Parent.Parent.Rodux)

	local StoreProvider = require(script.Parent.StoreProvider)

	local getStore = require(script.Parent.getStore)

	it("should get store from consumer", function()
		local function reducer()
			return 0
		end

		local store = Rodux.Store.new(reducer)
		local consumedStore = nil

		local StoreContext = Roact.createContext()

		local tree = Roact.createElement(StoreProvider, {
			store = store,
			Provider = StoreContext.Provider
		}, {
			Consumer = Roact.createElement(StoreContext.Consumer, {
				render = function(store)
					consumedStore = store
					return Roact.createElement("TextButton")
				end
			})
		})

		local handle = Roact.mount(tree)
		expect(consumedStore).to.equal(store)

		Roact.unmount(handle)
		store:destruct()
	end)
end