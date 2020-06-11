local Roact = require(script.Parent.Parent.Roact)

local storeKey = require(script.Parent.storeKey)

local StoreProvider = Roact.Component:extend("StoreProvider")

function StoreProvider.validateProps(props)
	local store = props.store
	
	if store == nil then
		return false, "Error initializing StoreProvider. Expected a `store` prop to be a Rodux store."
	elseif props.Provider == nil then
		return false, "Error initializing StoreProvider. Expected a `Provider` prop to be a Rodux Provider. See Roact.createContext()."
	else
		return true
	end
end

function StoreProvider:init(props)
	self.store = props.store
	self.Provider = props.Provider
end

function StoreProvider:render()
	return Roact.createElement(self.Provider, {
		value = self.store
	}, self.props[Roact.Children])
end

return StoreProvider