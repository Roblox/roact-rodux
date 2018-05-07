local Roact = require(script.Parent.Parent.Roact)

local storeKey = require(script.Parent.storeKey)
local GatedSignal = require(script.Parent.GatedSignal)

local StoreUpdateGate = Roact.Component:extend("StoreUpdateGate")

function StoreUpdateGate:init()
	local realStore = self._context[storeKey]

	if not realStore then
		error("StoreUpdateGate must be placed below a StoreProvider in the tree!")
	end

	-- The 'mock store' only exposes a subset of the real store's methods!
	local mockStore = {}
	mockStore.changed = GatedSignal.new()

	mockStore.getState = function()
		if self.props.shouldBlockUpdates then
			return self.stateAtLastBlock
		else
			return realStore:getState()
		end
	end

	mockStore.dispatch = function(self, action)
		return realStore:dispatch(action)
	end

	self.changedConnection = realStore.changed:connect(function(...)
		mockStore.changed:fire(...)
	end)

	self.mockStore = mockStore
	self._context[storeKey] = mockStore

	self.stateAtLastBlock = nil

	if self.props.shouldBlockUpdates then
		self:blockChanges()
	end
end

function StoreUpdateGate:blockChanges()
	self.stateAtLastBlock = self.mockStore:getState()
	self.mockStore:block()
end

function StoreUpdateGate:unblockChanges()
	local oldState = self.stateAtLastBlock
	local newState = self.mockStore:getState()

	self.stateAtLastBlock = nil
	self.mockStore:unblock(oldState, newState)
end

function StoreUpdateGate:didUpdate(oldProps)
	if self.props.shouldBlockUpdates ~= oldProps.shouldBlockUpdates then
		if self.props.shouldBlockUpdates then
			self:blockChanges()
		else
			self:unblockChanges()
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