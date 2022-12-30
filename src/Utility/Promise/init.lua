--!strict

local Promise = require(script['roblox-lua-promise']) :: any

export type Status = 'Started' | 'Resolved' | 'Rejected' | 'Cancelled'

type Handler<T...> = (T...) -> ()
type VoidHandler<T...> = (T...) -> ()

Promise.prototype.GetStatus = Promise.prototype.getStatus
--Promise.prototype.Timeout = Promise.prototype.timeout
Promise.prototype.Then = Promise.prototype.andThen
Promise.prototype.Catch = Promise.prototype.catch
Promise.prototype.Tap = Promise.prototype.tap
Promise.prototype.AndThenCall = Promise.prototype.andThenCall
Promise.prototype.AndThenReturn = Promise.prototype.andThenReturn
Promise.prototype.Cancel = Promise.prototype.cancel
Promise.prototype.Finally = Promise.prototype.finally
Promise.prototype.FinallyCall = Promise.prototype.finallyCall
Promise.prototype.FinallyReturn = Promise.prototype.finallyReturn
Promise.prototype.AwaitStatus = Promise.prototype.awaitStatus
Promise.prototype.Await = Promise.prototype.await
Promise.prototype.Expect = Promise.prototype.expect
Promise.prototype.Now = Promise.prototype.now

export type Promise<T..., R...> = {
	Status: Status,

	GetStatus: (Promise<T..., R...>) -> Status,

	Timeout: (...any) -> Promise<T..., R...>,--(Promise<T..., R...>, seconds: number, R...) -> Promise<T..., R...>,
	-- Causes issues for the type checker and I'm not entirely sure why.

	Then: (Promise<T..., R...>, successHandler: Handler<T...>?, failureHandler: Handler<R...>?) -> Promise<T..., R...>,
	Catch: (Promise<T..., R...>, failureHandler: Handler<R...>) -> Promise<T..., R...>,
	Tap: (Promise<T..., R...>, tapHandler: Handler<T...>) -> Promise<T..., R...>,
	AndThenCall: <V>(Promise<T..., R...>, callback: (V) -> (T...), V) -> Promise<T..., R...>,
	AndThenReturn: (Promise<T..., R...>, T...) -> Promise<T..., R...>,
	Cancel: (Promise<T..., R...>) -> (),
	Finally: <V>(Promise<T..., R...>, finallyHandler: (status: Status) -> V?) -> Promise<T..., R...>,
	FinallyCall: <V>(Promise<T..., R...>, callback: (V) -> T..., T...) -> Promise<T..., R...>,
	FinallyReturn: (Promise<T..., R...>, T...) -> Promise<T..., R...>,

	AwaitStatus: (Promise<T..., R...>) -> (Status, any),
	Await: (Promise<T..., R...>) -> (boolean, any),
	Expect: (Promise<T..., R...>) -> T...,
	Now: (Promise<T..., R...>, rejectionValue: any?) -> Promise<T..., R...>,
}

local PromiseLibrary = (Promise :: any) :: {
	new: <ResolveT..., RejectT...>(
		executor: (
			resolve: (ResolveT...) -> (),
			reject: (RejectT...) -> (),
			onCancel: (abortHandler: () -> ()?) -> boolean
		) -> ()
	) -> Promise<ResolveT..., RejectT...>,

	defer: <ResolveT..., RejectT...>(
		executor: (
			resolve: (ResolveT...) -> (),
			reject: (RejectT...) -> (),
			onCancel: (abortHandler: () -> ()?) -> boolean
		) -> ()
	) -> Promise<ResolveT..., RejectT...>,

	resolve: <T..., R...>(T...) -> Promise<T..., (R...)>,
	reject: <T..., R...>(R...) -> Promise<T..., (R...)>,
	try: <T..., R...>(callback: (T...) -> R..., T...) -> Promise<R..., (string)>,
	all: <ResolveT, RejectT>(promises: { Promise<ResolveT, (RejectT)> }) -> Promise<{ ResolveT }, ({ RejectT })>,
	fold: <T, U>(list: { T | Promise<T, (any)> }, reducer: (accumulator: U, value: T, index: number) -> U | Promise<U, (any)>) -> (),
	some: <T>(promises: { Promise<T, (any)> }, count: number) -> Promise<{ T }, (any)>,
	any: <T...>(promises: { Promise<T..., (any)> }) -> Promise<T..., (any)>,
	allSettled: <T...>(promises: { Promise<T..., (any)> }) -> Promise<{ Status }, (any)>,
	race: <ResolveT..., RejectT...>(promises: { Promise<ResolveT..., RejectT...> }) -> Promise<ResolveT..., (RejectT...)>,
	each: <T, U>(list: { T | Promise<T, (any)> }, predicate: (value: T, index: number) -> U | Promise<U, (any)>) -> Promise<{ U }, (any)>,
	is: (object: any) -> boolean,
	promisify: <T..., R...>(callback: (T...) -> R...) -> ((T...) -> Promise<R..., (any)>),
	delay: (seconds: number) -> Promise<number, (any)>,
	retry: <T..., P...>(callback: (P...) -> Promise<T..., (any)>, times: number, P...) -> Promise<T..., (any)>,
	retryWithDelay: <T..., P...>(callback: (P...) -> Promise<T..., (any)>, times: number, seconds: number, P...) -> Promise<T..., (any)>,
	fromEvent: <P...>(event: { Connect: RBXScriptSignal | (any) -> any }, predicate: ((P...) -> boolean)?) -> Promise<P..., (any)>,
	timeout: <ResolveT..., RejectT...>(seconds: number, RejectT...) -> Promise<ResolveT..., RejectT...>,

	onUnhandledRejection: <ResolveT..., RejectT...>(callback: (promise: Promise<ResolveT..., RejectT...>, any) -> ()) -> (),
}

return table.freeze(PromiseLibrary)