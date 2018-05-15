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

local function makeStateUpdater(store, mapStateToProps)
	return function(nextProps, prevState, mappedStoreState)
		if mappedStoreState == nil then
			mappedStoreState = mapStateToProps(store:getState(), nextProps)
		end

		local propsForChild = join(nextProps, mappedStoreState, prevState.mappedStoreDispatch)

		return {
			mappedStoreState = mappedStoreState,
			propsForChild = propsForChild,
		}
	end
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
			local mappedStoreState = mapStateToProps(storeState, self.props)

			-- mapStateToProps can return a function instead of a state value.
			-- In this variant, we keep that value as our 'state mapper' instead
			-- of the original mapStateToProps. This matches react-redux and
			-- enables connectors to keep instance-level state.
			if typeof(mappedStoreState) == "function" then
				mapStateToProps = mappedStoreState
				mappedStoreState = mapStateToProps(storeState, self.props)
			end

			if mappedStoreState ~= nil and typeof(mappedStoreState) ~= "table" then
				local message = formatMessage({
					"mapStateToProps must either return a table, or return another function that returns a table.",
					"Instead, it returned %q, which is of type %s.",
				}, {
					tostring(mappedStoreState),
					typeof(mappedStoreState),
				})

				error(message)
			end

			local mappedStoreDispatch = mapDispatchToProps(function(...)
				return self.store:dispatch(...)
			end)

			local stateUpdater = makeStateUpdater(self.store, mapStateToProps)

			self.mapStateToProps = mapStateToProps
			self.state = {
				stateUpdater = stateUpdater,
				mappedStoreDispatch = mappedStoreDispatch,
			}

			self.state.propsForChild = stateUpdater(self.props, self.state, mappedStoreState)
		end

		function outerComponent:didMount()
			self.eventHandle = self.store.changed:connect(function(storeState)
				self:setState(function(prevState, props)
					local mappedStoreState = self.mapStateToProps(storeState, props)

					if shallowEqual(mappedStoreState, prevState.mappedStoreState) then
						return nil
					end

					return prevState.stateUpdater(props, prevState, mappedStoreState)
				end)
			end)
		end

		function outerComponent:willUnmount()
			self.eventHandle:disconnect()
		end

		function outerComponent:render()
			return Roact.createElement(innerComponent, self.state.propsForChild)
		end

		return outerComponent
	end
end

return connect