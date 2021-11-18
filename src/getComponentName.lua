-- upstream: https://github.com/facebook/react/blob/a774502e0ff2a82e3c0a3102534dbc3f1406e5ea/packages/shared/getComponentName.js
--[[*
* Copyright (c) Facebook, Inc. and its affiliates.
*
* This source code is licensed under the MIT license found in the
* LICENSE file at https://github.com/facebook/react/blob/a774502e0ff2a82e3c0a3102534dbc3f1406e5ea/LICENSE
*
* @flow
]]

local ReactSymbols = require(script.Parent.ReactSymbols)
local REACT_CONTEXT_TYPE = ReactSymbols.REACT_CONTEXT_TYPE
local REACT_FORWARD_REF_TYPE = ReactSymbols.REACT_FORWARD_REF_TYPE
local REACT_FRAGMENT_TYPE = ReactSymbols.REACT_FRAGMENT_TYPE
local REACT_PORTAL_TYPE = ReactSymbols.REACT_PORTAL_TYPE
local REACT_MEMO_TYPE = ReactSymbols.REACT_MEMO_TYPE
local REACT_PROFILER_TYPE = ReactSymbols.REACT_PROFILER_TYPE
local REACT_PROVIDER_TYPE = ReactSymbols.REACT_PROVIDER_TYPE
local REACT_STRICT_MODE_TYPE = ReactSymbols.REACT_STRICT_MODE_TYPE
local REACT_SUSPENSE_TYPE = ReactSymbols.REACT_SUSPENSE_TYPE
local REACT_SUSPENSE_LIST_TYPE = ReactSymbols.REACT_SUSPENSE_LIST_TYPE
local REACT_LAZY_TYPE = ReactSymbols.REACT_LAZY_TYPE

local getComponentName

local function getWrappedName(outerType, innerType, wrapperName)
	-- deviation: Account for indexing into function
	local functionName = getComponentName(innerType)
	return outerType.displayName
		or (functionName ~= "" and string.format("%s(%s)", wrapperName, functionName) or wrapperName)
end

local function getContextName(type)
	return type.displayName or "Context"
end

function getComponentName(type)
	if type == nil then
		-- Host root, text node or just invalid type.
		return nil
	end
	local typeofType = typeof(type)

	if typeofType == "function" then
		-- try using Roblox Lua's debug.info before falling back to lua5.1 debug.getinfo
		-- selene: allow(incorrect_standard_library_use)
		local name = type(debug.info) == "function" and debug.info(type, "n") or debug.getinfo(type).name
		-- when name = (null) we want it to be treated as nil, not as an empty (truthy) string
		if name and #name > 0 then
			return name
		end
		-- if we can't get the name, try for the source file where the function was created
		local source = type(debug.info) == "function" and debug.info(type, "sl") or debug.getinfo(type).source
		if source and #source > 0 then
			return source
		end
		return nil
	end

	if typeofType == "string" then
		return type
	end

	if type == REACT_FRAGMENT_TYPE then
		return "Fragment"
	elseif type == REACT_PORTAL_TYPE then
		return "Portal"
	elseif type == REACT_PROFILER_TYPE then
		return "Profiler"
	elseif type == REACT_STRICT_MODE_TYPE then
		return "StrictMode"
	elseif type == REACT_SUSPENSE_TYPE then
		return "Suspense"
	elseif type == REACT_SUSPENSE_LIST_TYPE then
		return "SuspenseList"
	end

	if typeofType == "table" then
		local typeProp = type["$$typeof"]
		if typeProp == REACT_CONTEXT_TYPE then
			local context = type
			return getContextName(context) .. ".Consumer"
		elseif typeProp == REACT_PROVIDER_TYPE then
			local provider = type
			return getContextName(provider._context) .. ".Provider"
		elseif typeProp == REACT_FORWARD_REF_TYPE then
			return getWrappedName(type, type.render, "ForwardRef")
		elseif typeProp == REACT_MEMO_TYPE then
			return getComponentName(type.type)
		elseif typeProp == REACT_LAZY_TYPE then
			local lazyComponent = type
			local payload = lazyComponent._payload
			local init = lazyComponent._init

			local ok, result = pcall(init, payload)
			if ok then
				return getComponentName(result)
			else
				-- don't propagate error to avoid erroring during creation of error messages
				return nil
			end
		else
			if type.displayName then
				return type.displayName
			end
			if type.name then
				return type.name
			end
			-- only use tostring() if its overridden to avoid "table: 0xabcd9012"
			local mt = getmetatable(type)
			if mt and rawget(mt, "__tostring") then
				return tostring(type)
			end
		end
	end

	return nil
end

return getComponentName
