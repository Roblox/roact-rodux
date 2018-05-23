local Roact = require(script.Parent.Parent.Roact)

local storeKey = require(script.Parent.storeKey)
local Signal = require(script.Parent.Signal)

local StoreUpdateGate = Roact.Component:extend("StoreUpdateGate")

function StoreUpdateGate:init()
	local realStore = self._context[storeKey]

	if realStore == nil then
		error("StoreUpdateGate must be placed below a StoreProvider in the tree!")
	end

	self.realStore = realStore

	-- mockStore has a replaced version of 'changed'
	local mockStore = {}
	setmetatable(mockStore, {
		__index = realStore,
	})

	mockStore.changed = Signal.new()

	self.mockStore = mockStore
	self._context[storeKey] = mockStore

	self.stateAtLastBlock = nil
	self.changedConnection = realStore.changed:connect(function(nextState, previousState)
		if self.props.shouldBlockUpdates then
			return
		end

		mockStore.changed:fire(nextState, previousState)
	end)
end

function StoreUpdateGate:didUpdate(oldProps)
	if self.props.shouldBlockUpdates ~= oldProps.shouldBlockUpdates then
		if self.props.shouldBlockUpdates then
			self.stateAtLastBlock = self.realStore:getState()
		else
			self.mockStore.changed:fire(self.realStore:getState(), self.stateAtLastBlock)
		end
	end
end

function StoreUpdateGate:willUnmount()
	self.changedConnection:disconnect()
end

function StoreUpdateGate:render()
	return Roact.oneChild(self.props[Roact.Children])
end

return StoreUpdateGate