local Roact = require(script.Parent.Parent.Roact)
local storeKey = require(script.Parent.storeKey)
local shallowEqual = require(script.Parent.shallowEqual)
local join = require(script.Parent.join)

--[[
	Formats a multi-line message with printf-style placeholders.
]]
local function formatMessage(lines, parameters)
	return table.concat(lines, "\n"):format(unpack(parameters or {}))
end

local function noop()
	return nil
end

--[[
	mapStateToProps:
		(storeState, props) -> partialProps
		OR
		() -> (storeState, props) -> partialProps
	mapDispatchToProps: (dispatch) -> partialProps
]]
local function connect(mapStateToPropsOrThunk, mapDispatchToProps)
	local connectTrace = debug.traceback()

	if mapStateToPropsOrThunk ~= nil then
		assert(typeof(mapStateToPropsOrThunk) == "function", "mapStateToProps must be a function or nil!")
	else
		mapStateToPropsOrThunk = noop
	end

	if mapDispatchToProps ~= nil then
		assert(typeof(mapDispatchToProps) == "function", "mapDispatchToProps must be a function or nil!")
	else
		mapDispatchToProps = noop
	end

	return function(innerComponent)
		if innerComponent == nil then
			local message = formatMessage({
				"connect returns a function that must be passed a component.",
				"Check the connection at:",
				"%s",
			}, {
				connectTrace,
			})

			error(message, 2)
		end

		local function makeStateUpdater(store, mapStateToProps)
			return function(nextProps, prevState, mapStateToPropsResult)
				if mapStateToPropsResult == nil then
					mapStateToPropsResult = mapStateToProps(store:getState(), nextProps)
				end

				local combinedResult = join(nextProps, mapStateToPropsResult, prevState.mapDispatchToPropsResult)

				return {
					mapStateToPropsResult = mapStateToPropsResult,
					combinedResult = combinedResult,
				}
			end
		end

		local componentName = ("RoduxConnection(%s)"):format(tostring(innerComponent))

		local outerComponent = Roact.Component:extend(componentName)

		function outerComponent.getDerivedStateFromProps(nextProps, prevState)
			return prevState.stateUpdater(nextProps, prevState)
		end

		function outerComponent:init()
			self.store = self._context[storeKey]

			if self.store == nil then
				local message = formatMessage({
					"Cannot initialize Roact-Rodux connection without being a descendent of StoreProvider!",
					"Tried to wrap component %q",
					"Make sure there is a StoreProvider above this component in the tree.",
				}, {
					tostring(innerComponent),
				})

				error(message)
			end

			local storeState = self.store:getState()

			local mapStateToProps = mapStateToPropsOrThunk
			local mapStateToPropsResult = mapStateToProps(storeState, self.props)

			-- mapStateToProps can return a function instead of a state value.
			-- In this variant, we keep that value as our 'state mapper' instead
			-- of the original mapStateToProps. This matches react-redux and
			-- enables connectors to keep instance-level state.
			if typeof(mapStateToPropsResult) == "function" then
				mapStateToProps = mapStateToPropsResult
				mapStateToPropsResult = mapStateToProps(storeState, self.props)
			end

			if mapStateToPropsResult ~= nil and typeof(mapStateToPropsResult) ~= "table" then
				local message = formatMessage({
					"mapStateToProps must either return a table, or return another function that returns a table.",
					"Instead, it returned %q, which is of type %s.",
				}, {
					tostring(mapStateToPropsResult),
					typeof(mapStateToPropsResult),
				})

				error(message)
			end

			local mapDispatchToPropsResult = mapDispatchToProps(function(...)
				return self.store:dispatch(...)
			end)

			local stateUpdater = makeStateUpdater(self.store, mapStateToProps)

			self.mapStateToProps = mapStateToProps
			self.state = {
				stateUpdater = stateUpdater,
				mapDispatchToPropsResult = mapDispatchToPropsResult,
			}

			self.state.combinedResult = stateUpdater(self.props, self.state, mapStateToPropsResult)
		end

		function outerComponent:didMount()
			self.eventHandle = self.store.changed:connect(function(storeState)
				self:setState(function(prevState, props)
					local mapStateToPropsResult = self.mapStateToProps(storeState, props)

					if shallowEqual(mapStateToPropsResult, prevState.mapStateToPropsResult) then
						return nil
					end

					return prevState.stateUpdater(props, prevState, mapStateToPropsResult)
				end)
			end)
		end

		function outerComponent:willUnmount()
			self.eventHandle:disconnect()
		end

		function outerComponent:render()
			return Roact.createElement(innerComponent, self.state.combinedResult)
		end

		return outerComponent
	end
end

return connect