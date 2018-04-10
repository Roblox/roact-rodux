local Roact = require(script.Parent.Parent.Roact)
local storeKey = require(script.Parent.storeKey)

local function join(...)
	local result = {}

	for i = 1, select("#", ...) do
		for key, value in pairs((select(i, ...))) do
			result[key] = value
		end
	end

	return result
end

--[[
	A list comparison that's only valid if the given lists are the same length.
]]
local function listShallowEqual(a, b)
	for index = 1, #a do
		if a[index] ~= b[index] then
			return false
		end
	end

	return true
end

-- A version of 'error' that outputs over multiple lines
local function errorLines(...)
	error(table.concat({...}, "\n"))
end

--[[
	mapStateToProps(storeState, props) -> partialProps
	mapDispatchToProps(dispatch) -> partialProps
]]
local function connect2(stateKeys, mapStateToProps, mapDispatchToProps)
	-- TODO: validate mapStateToProps and mapDispatchToProps

	return function(innerComponent)
		-- TODO: validate innerComponent

		local componentName = ("RoduxConnection(%s)"):format(tostring(innerComponent))

		local outerComponent = Roact.Component:extend(componentName)

		function outerComponent.getDerivedStateFromProps(props, state)
			return {
				combinedState = join(props, state.stateValues, state.dispatchValues)
			}
		end

		function outerComponent:init()
			local store = self._context[storeKey]

			-- TODO: validate store

			self.store = store

			local state = store:getState()
			local relevantStoreState = {}

			for _, key in ipairs(stateKeys) do
				relevantStoreState[key] = state[key]
			end

			self.relevantStoreState = relevantStoreState

			if mapDispatchToProps then
				state.dispatchValues = mapDispatchToProps(function(...)
					self.store:dispatch(...)
				end)
			end

			self.state = state
		end

		function outerComponent:updateState(newRelevantStoreState)
			self.relevantStoreState = newRelevantStoreState

			local newState = mapStateToProps(self.props, unpack(newRelevantStoreState))
			local combinedState = join(self.props, newState, self.dispatchValues)

			self:setState({
				combinedState = combinedState
			})
		end

		function outerComponent:didMount()
			self.eventHandle = self.store:connect(function(state)
				local newStateValues = {}

				for _, key in ipairs(stateKeys) do
					newStateValues[key] = state[key]
				end

				if not listShallowEqual(newStateValues, self.stateValues) then
					self:updateState(newStateValues)
				end
			end)
		end

		function outerComponent:willUnmount()
			self.eventHandle:disconnect()
		end

		function outerComponent:render()
			return Roact.createElement(innerComponent, self.state.combinedState)
		end

		return outerComponent
	end
end

return connect2