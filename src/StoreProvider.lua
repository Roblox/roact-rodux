local Roact = require(script.Parent.Parent.Roact)

local storeKey = require(script.Parent.storeKey)

local StoreProvider = Roact.Component:extend("StoreProvider")

function StoreProvider.validateProps(props)
	local store = props.store
	if store == nil then
		return false, "Error initializing StoreProvider. Expected a `store` prop to be a Rodux store."
	end
	return true
end

function StoreProvider:init(props)
	local store = props.store
	self._context[storeKey] = store
end

function StoreProvider:render()
	return Roact.createFragment(self.props[Roact.Children])
end

return StoreProvider