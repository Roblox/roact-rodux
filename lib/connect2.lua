local Roact = require(script.Parent.Parent.Roact)
local storeKey = require(script.Parent.storeKey)
local shallowEqual = require(script.Parent.shallowEqual)
local join = require(script.Parent.join)

-- A version of 'error' that outputs over multiple lines
local function errorLines(...)
	error(table.concat({...}, "\n"))
end

local function noop()
	return nil
end

--[[
	mapStateToProps: (storeState, props) -> partialProps
	mapDispatchToProps: (dispatch) -> partialProps
]]
local function connect2(mapStateToProps, mapDispatchToProps)
	local connectTrace = debug.traceback()

	if mapStateToProps == nil then
		mapStateToProps = noop
	end

	if mapDispatchToProps == nil then
		mapDispatchToProps = noop
	end

	return function(innerComponent)
		if innerComponent == nil then
			local message = (
				"connect returns a function that must be passed a component.\nCheck the connection at:\n%s"
			):format(connectTrace)

			error(message, 0)
		end

		local componentName = ("RoduxConnection(%s)"):format(tostring(innerComponent))

		local outerComponent = Roact.Component:extend(componentName)

		function outerComponent.getDerivedStateFromProps(nextProps, prevState)
			local stateValues = prevState.stateMapper(prevState.storeState, nextProps)
			local combinedValues = join(nextProps, stateValues, prevState.dispatchValues)

			return {
				stateValues = stateValues,
				combinedValues = combinedValues,
			}
		end

		function outerComponent:init()
			local store = self._context[storeKey]

			if store == nil then
				errorLines(
					"Cannot initialize Roact-Rodux connection without being a descendent of StoreProvider!",
					("Tried to wrap component %q"):format(tostring(innerComponent)),
					"Make sure there is a StoreProvider above this component in the tree."
				)
			end

			self.store = store

			local storeState = store:getState()

			local stateMapper = mapStateToProps

			local stateValues = mapStateToProps(storeState)
			if typeof(stateValues) == "function" then
				stateMapper = stateValues
				stateValues = stateValues(storeState)
			end

			local dispatchValues = mapDispatchToProps(function(...)
				self.store:dispatch(...)
			end)

			self.state = {
				storeState = storeState,
				stateMapper = stateMapper,
				stateValues = stateValues,
				dispatchValues = dispatchValues,
				combinedValues = join(self.props, stateValues, dispatchValues)
			}
		end

		function outerComponent:updateState(newStoreState)
			self:setState(function(prevState, props)
				local newStateValues = prevState.stateMapper(newStoreState, props)

				if shallowEqual(newStateValues, prevState.stateValues) then
					-- TODO: Return nil instead once Roblox/Roact#63 is closed
					-- This will let us cancel the render.
					return {}
				end

				local newCombinedState = join(props, newStateValues, prevState.dispatchValues)

				return {
					storeState = newStoreState,
					stateValues = newStateValues,
					combinedState = newCombinedState,
				}
			end)
		end

		function outerComponent:didMount()
			self.eventHandle = self.store.changed:connect(function(storeState)
				self:updateState(storeState)
			end)
		end

		function outerComponent:willUnmount()
			self.eventHandle:disconnect()
		end

		function outerComponent:render()
			return Roact.createElement(innerComponent, self.state.combinedValues)
		end

		return outerComponent
	end
end

return connect2