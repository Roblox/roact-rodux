--!strict
local Rodux = require(script.Parent.Parent.Rodux)

type Action = Rodux.Action<string>
type ThunkAction<ReturnType, State> = Rodux.ThunkAction<ReturnType, State>

export type DispatchProp = <Payload>(action: Payload & Action) -> ()

export type ThunkfulDispatchProp<State = any> =
	DispatchProp
	& <ReturnType>(thunkAction: ThunkAction<ReturnType, State>) -> ReturnType

return nil
