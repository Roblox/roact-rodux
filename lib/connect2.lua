local Roact = require(script.Parent.Parent.Roact)
local storeKey = require(script.Parent.storeKey)

local function join(...)
	local result = {}

	for i = 1, select("#", ...) do
		local source = select(i, ...)

		if source ~= nil then
			for key, value in pairs(source) do
				result[key] = value
			end
		end
	end

	return result
end

--[[
	Transforms a list of keys and a map into a new map containing only those
]]
local function selectKeysFromMap(keys, map)
	local result = {}

	for i = 1, #keys do
		local key = keys[i]
		result[key] = map[key]
	end

	return result
end

--[[
	Compares two dictionaries, assuming that they have the same keys.
]]
local function oneWayShallowEqual(a, b)
	for key, value in pairs(a) do
		if value ~= b[key] then
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
	options: {
		mapStateToProps(storeState, props) -> partialProps
		mapDispatchToProps(dispatch) -> partialProps
	}
]]
local function connect2(options)
	local connectTrace = debug.traceback()

	assert(typeof(options) == "table", "connect expects a table of options!")

	local stateKeys = options.stateKeys
	local mapStateToProps = options.mapStateToProps
	local mapDispatchToProps = options.mapDispatchToProps

	if stateKeys ~= nil and mapStateToProps == nil then
		error("If 'stateKeys' is specified, 'mapStateToProps' must also be specified!", 2)
	end

	if mapStateToProps ~= nil and stateKeys == nil then
		error("If 'mapStateToProps' is specified, 'stateKeys' must also be specified!", 2)
	end

	if stateKeys == nil and mapStateToProps == nil then
		stateKeys = {}
		mapStateToProps = function()
			return nil
		end
	end

	if mapDispatchToProps == nil then
		mapDispatchToProps = function()
			return nil
		end
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
			local stateValues = mapStateToProps(prevState.storeStateSlice, nextProps)

			return {
				stateValues = join(nextProps, stateValues, prevState.dispatchValues)
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

			self.state = {}

			self.state.storeStateSlice = selectKeysFromMap(stateKeys, store:getState())
			self.state.stateValues = mapStateToProps(self.state.storeStateSlice)

			self.state.dispatchValues = mapDispatchToProps(function(...)
				self.store:dispatch(...)
			end)
		end

		function outerComponent:updateState(newStoreStateSlice)
			self:setState(function(prevState, props)
				local newState = mapStateToProps(newStoreStateSlice, self.props)
				local stateValues = join(self.props, newState, self.dispatchValues)

				return {
					stateValues = stateValues,
					storeStateSlice = newStoreStateSlice,
				}
			end)
		end

		function outerComponent:didMount()
			self.eventHandle = self.store.changed:connect(function(state)
				local newStateSlice = selectKeysFromMap(stateKeys, state)

				if not oneWayShallowEqual(newStateSlice, self.storeStateSlice) then
					self:updateState(newStateSlice)
				end
			end)
		end

		function outerComponent:willUnmount()
			self.eventHandle:disconnect()
		end

		function outerComponent:render()
			return Roact.createElement(innerComponent, self.state.stateValues)
		end

		return outerComponent
	end
end

return connect2