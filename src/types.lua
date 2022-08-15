--!strict
local Rodux = require(script.Parent.Parent.Rodux)

type BaseAction = Rodux.Action<string>
type ThunkAction<ReturnType, State> = Rodux.ThunkAction<ReturnType, State>

export type DispatchProp = <Action>(action: Action & BaseAction) -> ()

export type ThunkfulDispatchProp<State = any> =
	DispatchProp
	& <ReturnType>(thunkAction: ThunkAction<ReturnType, State>) -> ReturnType

return nil
