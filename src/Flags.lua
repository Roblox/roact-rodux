--!strict
--[[
	Fast flags gating in-progress behavior changes.

	The flag API is unavailable in lower security contexts (and outside of
	Roblox entirely), so each flag falls back to false when it cannot be read.
]]
local function createGetFFlag(name: string): () -> boolean
	local value: boolean? = nil

	return function()
		if value == nil then
			local success, result = pcall(function(): boolean
				game:DefineFastFlag(name, false)
				return game:GetFastFlag(name)
			end)
			value = success and result == true
		end

		return value :: boolean
	end
end

local Flags = {
	getEagerConnectUpdates = createGetFFlag("RoactRoduxEagerConnectUpdates"),
}

return Flags
