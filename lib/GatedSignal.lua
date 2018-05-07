--[[
	A limited, simple implementation of a GatedSignal with the addition of a
	gated condition.

	If the signal has 'isBlocking' set, changes will be witheld until
	'isBlocking' is reset to false..

	Handlers are fired in order, and (dis)connections are properly handled when
	executing an event.
]]

local function immutableAppend(list, ...)
	local new = {}
	local len = #list

	for key = 1, len do
		new[key] = list[key]
	end

	for i = 1, select("#", ...) do
		new[len + i] = select(i, ...)
	end

	return new
end

local function immutableRemoveValue(list, removeValue)
	local new = {}

	for i = 1, #list do
		if list[i] ~= removeValue then
			table.insert(new, list[i])
		end
	end

	return new
end

local GatedSignal = {}

GatedSignal.__index = GatedSignal

function GatedSignal.new()
	local self = {
		_listeners = {},
		_isBlocking = false,
		_shouldFireWhenUnblocked = false,
	}

	setmetatable(self, GatedSignal)

	return self
end

function GatedSignal:connect(callback)
	local listener = {
		callback = callback,
		disconnected = false,
	}

	self._listeners = immutableAppend(self._listeners, listener)

	local function disconnect()
		listener.disconnected = true
		self._listeners = immutableRemoveValue(self._listeners, listener)
	end

	return {
		disconnect = disconnect
	}
end

function GatedSignal:fire(...)
	if self._isBlocking then
		self._shouldFireWhenUnblocked = true
		return
	end

	for _, listener in ipairs(self._listeners) do
		if not listener.disconnected then
			listener.callback(...)
		end
	end
end

function GatedSignal:block()
	if self._isBlocking then
		return
	end

	self._isBlocking = true
end

function GatedSignal:unblock(...)
	if not self._isBlocking then
		return
	end

	self._isBlocking = false

	if self._shouldFireWhenUnblocked then
		self._shouldFireWhenUnblocked = false
		self:fire(...)
	end
end

return GatedSignal