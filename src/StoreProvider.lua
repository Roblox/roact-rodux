local Roact = require(script.Parent.Parent.Roact)

local StoreContext = require(script.Parent.StoreContext)

local StoreProvider = Roact.Component:extend("StoreProvider")

function StoreProvider:init(props)
	local store = props.store
	if store == nil then
		error("Error initializing StoreProvider. Expected a `store` prop to be a Rodux store.")
	end
	self.store = store
end

function StoreProvider:render()
	return Roact.createElement(StoreContext.Provider, {
		value = self.store
	}, self.props[Roact.Children])
end

return StoreProvider