local StoreProvider = require(script.StoreProvider)
local connect = require(script.connect)
local getStore = require(script.getStore)
local GlobalConfig = require(script.GlobalConfig)

return {
	StoreProvider = StoreProvider,
	connect = connect,
	UNSTABLE_getStore = getStore,
	UNSTABLE_connect2 = connect,

	setGlobalConfig = GlobalConfig.set,
}