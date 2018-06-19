## Create a Store with Rodux
Create your store as normal with [Rodux](https://github.com/Roblox/Rodux):

```lua
local function reducer(state, action)
	state = state or {
		value = 0,
	}

	if action.type == "increment" then
		return {
			value = state.value + 1,
		}
	end

	return state
end

local store = Rodux.Store.new(reducer)
```

## Add a `StoreProvider`
When you render your Roact application, wrap the top-level component in a `RoactRodux.StoreProvider`:

```lua
local app = Roact.createElement(RoactRodux.StoreProvider, {
	store = store,
}, {
	Main = Roact.createElement(MyComponent),
})
```

This makes your Rodux store available for any components in your app. They'll access that store using the `connect` function.

## Connect with `connect`
Use `RoactRodux.connect` to retrieve values from the store and use them in your [Roact](https://github.com/Roblox/Roact) component:

```lua
-- Write your component as if Rodux is not involved first.
-- This helps guide you to create a more focused interface.

local function MyComponent(props)
	-- Values from Rodux can be accessed just like regular props
	local value = props.value
	local onClick = props.onClick

	return Roact.createElement("ScreenGui", nil, {
		Label = Roact.createElement("TextButton", {
			-- ...and used in your components!
			Text = "Current value: " .. value,
			Size = UDim2.new(1, 0, 1, 0),

			[Roact.Event.Activated] = onClick,
		})
	})
end

-- `connect` accepts two optional functions:
-- `mapStateToProps` accepts your store's state and returns props
-- `mapDispatchToProps` accepts a dispatch function and returns props

-- Both functions should return a table containing props that will be passed to
-- your component!

-- `connect` returns a function, so we call that function, passing in our
-- component, getting back a new component!
MyComponent = RoactRodux.connect(
	function(state, props)
		-- mapStateToProps is run every time the store's state updates.
		-- It's also run whenever the component receives new props.
		return {
			value = state.value,
		}
	end,
	function(dispatch)
		-- mapDispatchToProps only runs once, so create functions here!
		return {
			onClick = function()
				dispatch({
					type = "increment",
				})
			end,
		}
	end
)(MyComponent)
```

Now, whenever the store updates, your connected components will receive updated data and re-render!

In many ways, Roact-Rodux works just like [react-redux](https://github.com/reactjs/react-redux). The public API is almost identical and most of the best practices from that ecosystem work here as well.