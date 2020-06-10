local Roact = require(script.Parent.Parent.Roact)

local storeKey = require(script.Parent.storeKey)

local StoreProvider = Roact.Component:extend("StoreProvider")

local StoreContext = Roact.createContext()

function StoreProvider.validateProps(props)
	local store = props.store
	
	if store == nil then
		return false, "Error initializing StoreProvider. Expected a `store` prop to be a Rodux store."
	else
		return true
	end
end

function StoreProvider:init(props)
	self.store = props.store
	self._context[storeKey] = props.store
end

function StoreProvider:render()
	return Roact.createElement(StoreContext.Provider, {
		value = self.store
	}, self.props[Roact.Children])
end

--Switch to function component wrapper, pass in props.store, use it is as value for context provider 
return StoreProvider