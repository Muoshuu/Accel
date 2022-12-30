--!strict

local Spring = require(script.Module)

type SpringKey = 'Clock' | 'Position' | 'Velocity' | 'Target' | 'Time' | 'Damper' | 'Speed'

export type Spring<T> = {
	Get: (Spring<T>, key: SpringKey) -> T | number | () -> number,
	Set: (Spring<T>, key: SpringKey, value: T | number | () -> number) -> Spring<T>,
	Update: (Spring<T>, now: number) -> (T, T),
	Impulse: (Spring<T>, velocity: T) -> (),
	TimeSkip: (Spring<T>, delta: number) -> ()
}

return table.freeze((Spring :: any) :: {
	new: <T>(initial: T, clock: nil | () -> number) -> Spring<T>,
	is: (value: any) -> boolean
})