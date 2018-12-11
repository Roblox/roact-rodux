## Roact Components

### StoreProvider
`StoreProvider` accepts a Rodux store via the `store` prop and makes it available to all components rendered under it.

It's possible to have multiple instances of `StoreProvider` in the same Roact tree, but most projects using Roact-Rodux will only have one.

`StoreProvider` is generally at the top of the tree:

```lua
Roact.createElement(RoactRodux.StoreProvider, {
	store = someStore,
}, {
	-- Any components created by `App` will be able to connect to someStore by
	-- using Roact-Rodux's `connect` method.
	App = Roact.createElement(App),
})
```

!!! warning
	Due to limitations of Roact, `StoreProvider` can only have zero or one children. This requirement may be relaxed in the future [when Roact supports fragments](https://github.com/Roblox/roact/issues/7).

## Methods

### connect
Connects to the Rodux store attached to the Roact tree by `StoreProvider`, retrieving data from the store and optionally creating functions to dispatch actions.

`connect` is a *Higher-Order Component* (HOC), which means that it wraps an existing component and adds additional functionality to it. Any props passed to the wrapped component will also be passed to the component that `connect` is wrapping.

`connect` accepts two functions, both of which are optional:

* `mapStateToProps`, which accepts the store's state as the first argument, as well as the props passed to the component.
	* `mapStateToProps` is run whenever the Rodux store updates, as well as whenever the props passed to your component are updated.
* `mapDispatchToProps`, which accepts a function that dispatches actions to your store. It works just like `Store:dispatch` in Rodux!
	* `mapDispatchToProps` is only run once per component instance.

Both `mapStateToProps` and `mapDispatchToProps` should return a table. These tables get merged into the props passed to the wrapped component.

!!! info
	`mapStateToProps` can also return a function. When it does, the returned function will be used to retrieve state from the store on each update. This is usually used when working with memoized functions, similar to Redux's supplemental [Reselect](https://github.com/reduxjs/reselect) library.

`connect` returns a function that should be called with the component to wrap. This API is sort of funky, but exists as-is for two primary reasons:

* Reusing the same connection for multiple components is useful, and can be used to create abstractions over `connect`.
* Since both `mapStateToProps` and `mapDispatchToProps` are optional, keeping them separate helps make the Roact-Rodux API cleaner.

Base example:

```lua
local function MyComponent(props)
	return Roact.createElement("TextButton", {
		Text = props.value,

		[Roact.Event.Activated] = props.onClick,
	})
end

MyComponent = RoactRodux.connect(
	function(state, props)
		return {
			value = state.value,
		}
	end,
	function(dispatch)
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

Using the higher-order version of `mapStateToProps`:

```lua
MyComponent = RoactRodux.connect(
	function()
		local getValue = memoize(function(state)
			return state.value
		end)

		return function(state, props)
			return {
				value = getValue(state),
			}
		end
	end
)(MyComponent)
```

The (very complicated) API signature of `connect` is:

```
connect([mapStateToProps, [mapDispatchToProps]]) -> (componentToWrap) -> wrappedComponent
where
	mapStateToProps:
		(storeState, props) -> propsToMerge
		OR
		() -> (storeState, props) -> propsToMerge
	mapDispatchToProps: (dispatchFn) -> propsToMerge
```