return function()
	local Roact = require(script.Parent.Parent.Roact)
	local Rodux = require(script.Parent.Parent.Rodux)

	local StoreProvider = require(script.Parent.StoreProvider)
	local connect = require(script.Parent.connect2)

	local StoreUpdateGate = require(script.Parent.StoreUpdateGate)

	it("should throw if there is no StoreProvider above it", function()
		local success, result = pcall(function()
			return Roact.mount(Roact.createElement(StoreUpdateGate))
		end)

		expect(success).to.equal(false)
		expect(result:find("StoreUpdateGate")).to.be.ok()
		expect(result:find("StoreProvider")).to.be.ok()
	end)

	it("should allow store changes through when set to block", function()
		local function reducer(state, action)
			if state == nil then
				state = 0
			end

			if action.type == "increment" then
				return state + 1
			end

			return state
		end

		local store = Rodux.Store.new(reducer)

		local lastProps
		local function TestComponent(props)
			lastProps = props
			return nil
		end

		TestComponent = connect(
			function(state)
				return {
					state = state,
				}
			end
		)(TestComponent)

		local function tree(shouldBlock)
			return Roact.createElement(StoreProvider, {
				store = store,
			}, {
				Blocker = Roact.createElement(StoreUpdateGate, {
					shouldBlockUpdates = shouldBlock,
				}, {
					Child = Roact.createElement(TestComponent),
				}),
			})
		end

		local handle = Roact.mount(tree(false))

		expect(lastProps).to.be.ok()
		expect(lastProps.state).to.equal(0)

		store:dispatch({ type = "increment" })
		store:flush()

		expect(lastProps.state).to.equal(1)

		handle = Roact.reconcile(handle, tree(true))

		store:dispatch({ type = "increment" })
		store:flush()

		expect(lastProps.state).to.equal(1)

		handle = Roact.reconcile(handle, tree(false))

		expect(lastProps.state).to.equal(2)

		store:dispatch({ type = "increment" })
		store:flush()

		expect(lastProps.state).to.equal(3)

		Roact.unmount(handle)
	end)
end