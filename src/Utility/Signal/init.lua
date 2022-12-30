--!strict

type Listener<T...> = (T...) -> ()

export type Signal<T...> = {
	Connections: { Connection<T...> },

	Connect: (Signal<T...>, listener: Listener<T...>) -> Connection<T...>,
	ConnectOnce: (Signal<T...>, listener: Listener<T...>) -> Connection<T...>,
	Disconnect: (Signal<T...>, connection: Connection<T...>) -> (),
	DisconnectAll: (Signal<T...>) -> (),
	Destroy: (Signal<T...>) -> (),
	Wait: (Signal<T...>) -> T...,
	Fire: (Signal<T...>, T...) -> (),

	Destroyed: boolean
}

export type Connection<T...> = {
	Connected: boolean,

	Disconnect: (Connection<T...>) -> ()
}

local Signal = require(script.Module)

table.freeze(Signal.Connection)

return table.freeze((Signal :: any) :: {
	new: <T...>() -> Signal<T...>,
	is: (any) -> boolean,

	Connection: {
		new: <T...>(signal: Signal<T...>, listener: Listener<T...>) -> Connection<T...>,
		is: (any) -> boolean
	}
})