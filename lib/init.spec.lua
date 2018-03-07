return function()
	local RoactRodux = require(script.Parent)

	local Roact = require(script.Parent.Parent.Roact)
	local Rodux = require(script.Parent.Parent.Rodux)

	describe("StoreProvider", function()
		it("should be instantiable as a component", function()
			local store = Rodux.Store.new(function()
				return 0
			end)
			local element = Roact.createElement(RoactRodux.StoreProvider, {
				store = store
			})

			expect(element).to.be.ok()

			Roact.reify(element, nil, "StoreProvider-test")

			store:destruct()
		end)
	end)

	describe("connect", function()
		it("should be instantiated as a component underneath StoreProvider", function()
			local renderCount = 0

			local function MyComponent(props)
				expect(props.foo).to.equal("bar")
				renderCount = renderCount + 1
			end

			local Wrapped = RoactRodux.connect(function(store)
				return {}
			end)(MyComponent)

			expect(Wrapped).to.be.ok()

			local wrappedElement = Roact.createElement(Wrapped, {
				foo = "bar"
			})

			expect(wrappedElement).to.be.ok()

			local store = Rodux.Store.new(function()
				return 0
			end)

			local element = Roact.createElement(RoactRodux.StoreProvider, {
				store = store
			}, {
				WrappedChild = wrappedElement
			})

			expect(element).to.be.ok()

			Roact.reify(element, nil, "connect-test")

			expect(renderCount > 0).to.equal(true)

			store:destruct()
		end)

		it("should receive updates to the store and re-render the wrapped component", function()
			local renderCount = 0

			local function reducer(state, action)
				state = state or 0

				if action.type == "foo" then
					return state + 1
				end

				return state
			end

			local store = Rodux.Store.new(reducer)

			local function MyComponent(props)
				expect(props.value).to.equal(store:getState())
				renderCount = renderCount + 1
			end

			local Wrapped = RoactRodux.connect(function(store)
				return {
					value = store:getState()
				}
			end)(MyComponent)

			expect(Wrapped).to.be.ok()

			local wrappedElement = Roact.createElement(Wrapped)

			expect(wrappedElement).to.be.ok()

			local element = Roact.createElement(RoactRodux.StoreProvider, {
				store = store
			}, {
				WrappedChild = wrappedElement
			})

			expect(element).to.be.ok()

			Roact.reify(element, nil, "connect-test")

			expect(renderCount >= 1).to.equal(true)

			local lastCount = renderCount

			store:dispatch({
				type = "foo"
			})
			store:flush()

			expect(renderCount >= lastCount + 1).to.equal(true)

			store:destruct()
		end)
	end)
end