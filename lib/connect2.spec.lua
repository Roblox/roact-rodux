return function()
	local connect2 = require(script.Parent.connect2)

	local StoreProvider = require(script.Parent.StoreProvider)

	local Roact = require(script.Parent.Parent.Roact)
	local Rodux = require(script.Parent.Parent.Rodux)

	local function incrementReducer(state, action)
		state = state or 0

		if action.type == "increment" then
			return state + 1
		end

		return state
	end

	describe("Argument validation", function()
		it("should accept a table with stateKeys and mapStateToProps", function()
			connect2({
				stateKeys = {},
				mapStateToProps = function()
				end,
			})
		end)

		it("should accept a table with mapDispatchToProps", function()
			connect2({
				mapDispatchToProps = function()
				end,
			})
		end)

		it("should accept a table with stateKeys, mapStateToProps, and mapDispatchToProps", function()
			connect2({
				stateKeys = {},
				mapStateToProps = function()
				end,
				mapDispatchToProps = function()
				end,
			})
		end)

		it("should not accept zero parameters", function()
			expect(function()
				connect2()
			end).to.throw()
		end)

		it("should not accept a table with stateKeys without mapStateToProps", function()
			expect(function()
				connect2({
					stateKeys = {},
				})
			end).to.throw()
		end)

		it("should not accept a table with mapStateToProps without stateKeys", function()
			expect(function()
				connect2({
					mapStateToProps = function()
					end,
				})
			end).to.throw()
		end)
	end)

	it("should throw if not passed a component", function()
		local selector = function(store)
			return {}
		end

		expect(function()
			connect2(selector)(nil)
		end).to.throw()
	end)

	it("should successfully connect when mounted under a StoreProvider", function()
		local store = Rodux.Store.new(incrementReducer)

		local function SomeComponent(props)
			return nil
		end

		local ConnectedSomeComponent = connect2({}, function(store)
			return {}
		end)(SomeComponent)

		local tree = Roact.createElement(StoreProvider, {
			store = store,
		}, {
			Child = Roact.createElement(ConnectedSomeComponent),
		})

		local handle = Roact.reify(tree)

		expect(handle).to.be.ok()
	end)
end