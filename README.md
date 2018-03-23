<h1 align="center">Roact-Rodux</h1>
<div align="center">
	<a href="https://travis-ci.org/Roblox/roact-rodux">
		<img src="https://api.travis-ci.org/Roblox/roact-rodux.svg?branch=master" alt="Travis-CI Build Status" />
	</a>
	<a href="https://coveralls.io/github/Roblox/roact-rodux?branch=master">
		<img src="https://coveralls.io/repos/github/Roblox/roact-rodux/badge.svg?branch=master" alt="Coveralls Coverage" />
	</a>
	<a href="#">
		<img src="https://img.shields.io/badge/docs-soon-red.svg" alt="Documentation" />
	</a>
</div>

<div align="center">
	A binding between <a href="https://github.com/Roblox/Roact">Roact</a> and <a href="https://github.com/Roblox/Rodux">Rodux</a>.
</div>

<div>&nbsp;</div>

## Installation
**Roact-Rodux expects to be located inside the same object as [Roact](https://github.com/Roblox/Roact) and [Rodux](https://github.com/Roblox/Rodux). They should be installed into the same place!**

### Method 1: Model File (Roblox Studio)
* Download the `rbxmx` model file attached to the latest release from the [GitHub releases page](https://github.com/Roblox/roact-rodux/releases).
* Insert the model into Studio into a place like `ReplicatedStorage`

### Method 2: Filesystem
* Copy the `lib` directory into your codebase
* Rename the folder to `RoactRodux`
* Use a plugin like [Rojo](https://github.com/LPGhatguy/rojo) to sync the files into a place

## Usage
Create your store as normal with [Rodux](https://github.com/Roblox/Rodux):

```lua
local store = Rodux.Store.new(function(state, action)
	state = state or {
		value = 0,
	}

	if action.type == "increment" then
		return {
			value = state.value + 1,
		}
	end

	return state
end)
```

Use `RoactRodux.connect` to inject values into your [Roact](https://github.com/Roblox/Roact) component:

```lua
local function MyComponent(props)
	-- Values from Rodux can be accessed just like regular props
	local value = props.value

	return Roact.createElement("ScreenGui", nil, {
		Label = Roact.createElement("TextLabel", {
			-- ...and used in your components!
			Text = "Current value: " .. value,

			Size = UDim2.new(1, 0, 1, 0),
		})
	})
end

-- `connect` accepts a function that passes you your store
-- and expects you to return a table of props for your component

-- Here, we immediately assign the result back to MyComponent
MyComponent = RoactRodux.connect(function(store)
	local state = store:getState()

	return {
		value = state.value,
	}
end)(MyComponent)
```

Finally, when you render your Roact application, wrap the top-level component in a `RoactRodux.StoreProvider`:

```lua
local app = Roact.createElement(RoactRodux.StoreProvider, {
	store = store,
}, {
	Main = Roact.createElement(MyComponent),
})
```

Now, whenever the store updates, your connected components will receive updated data and re-render!

In many other cases, RoactRodux works just like [react-redux](https://github.com/reactjs/react-redux). The public API is almost identical and most of the best practices from that ecosystem work here as well.

## License
RoactRodux is available under the Apache 2.0 license. See [LICENSE](LICENSE) for details.