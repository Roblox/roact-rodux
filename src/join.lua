local function join(...)
	local result = {}

	for _, source in pairs({...}) do
		if source ~= nil then
			for key, value in pairs(source) do
				result[key] = value
			end
		end
	end

	return result
end

return join
