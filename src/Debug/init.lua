local scriptContext = game:GetService('ScriptContext')
local logService = game:GetService('LogService')

local onceHistory = {
	warn = {},
	print = {}
}

local Debug = {
	info = debug.info,

	setMemoryCategory = debug.setmemorycategory,
	resetMemoryCategory = debug.resetmemorycategory,

	profileBegin = debug.profilebegin,
	profileEnd = debug.profileend,

	trace = debug.traceback,

	print = print,
	warn = warn,
	error = error,
	assert = assert,

	onError = scriptContext.Error,
	onOutput = logService.MessageOut,

	inspect = require(script.Inspect),

	printOnce = function(str: string, ...)
		str = str:format(...)

		if not onceHistory.print[str] then
			onceHistory.print[str] = true

			print(str)
		end
	end,

	warnOnce = function(str: string, ...)
		str = str:format(...)

		if not onceHistory.warn[str] then
			onceHistory.warn[str] = true

			warn(str)
		end
	end,

	printf = function(str: string, ...)
		print(str:format(...))
	end,

	warnf = function(str: string, ...)
		warn(str:format(...))
	end,

	errorf = function(str: string, ...)
		error(str:format(...))
	end,

	errorf2 = function(level: number, str: string, ...)
		error(str:format(...), level)
	end,

	assertf = function(condition: boolean, str: string, ...)
		assert(condition, str:format(...))
	end,

	getLogHistory = function()
		return logService:GetLogHistory() :: {
			{
				message: string,
				messageType: Enum.MessageType,
				timestamp: number
			}
		}
	end,

	ERROR = {
		API = {
			NO_ACCESS = 'Studio API access is not enabled. For this reason, some Accel features that require API access will be disabled while in studio.',
			NO_ACCESS_FOR = 'Studio API access is not enabled. For this reason, %s is disabled. To correct this, enable studio API access.'
		},

		SERVER_ONLY = '%s can only be called on the server',
		CLIENT_ONLY = '%s can only be called on the client',

		NOT_IMPLEMENTED = '%s has not been implemented yet!',

		IMPORT = {
			FAILED = {
				INVALID_ARG_TYPE = 'First argument to Accel.import must be either a string or a ModuleScript, but %q was passed.',
				BAD_PATH = 'Failed to resolve a module from the path %q at %s.'
			}
		},

		RECEIPT_PROCESSOR = {
			STORE_FAILURE = 'Failed to store receipt with ID %s.',
			INVALID_RETURN = 'The receipt processor did not return an Enum.ProductPurchaseDecision or a boolean for receipt with ID %s.',
			NON_EXISTENT = 'No receipt processor exists to process receipt with ID %s.',
			ERROR = 'The receipt processor errored when processing receipt with ID %s. Error: %s'
		},

		NETWORK = {
			REQUEST_TIMEOUT = 'Network request for provider with key %s timed out.',
			GET_SIGNAL_TIMEOUT = 'NetworkService.getSignal(q) timed out on the client. Ensure the signal is being created on the server.',

			PLAYER = {
				BAD_TYPE = 'Expected a Player, ID, username, or wrapper as the first argument to %s, but got %q',
				NOT_FOUND_FROM_X = 'Received a %s as the first argument to %s, but no Player could be matched to it.'
			},

			CLIENT_ATTEMPTED_BROADCAST = 'RemoteSignal::broadcast can only be called from the server.',

			HTTP = {
				INVALID_OPTIONS = 'The first argument passed to HttpRequest.new must be a URL string or a table of request options including a host.',
				HOST_REQUIRED = 'A host is required when creating an HttpRequest.',
				PROTOCOL_PORT_MISMATCH = 'Protocol/port mismatch when creating an HttpRequest.',
				X_MUST_BE_A_Y_GOT_Z = '%s option to HttpRequest.new must be a %s, got %q',
				UNSUPPORTED_X_Y = 'Unsupported %s %q passed when creating an HttpRequest.',
				AUTH_PRESENCE = 'Both user and pass must be present in auth when creating an HttpRequest.'
			}
		},

		CLASS = {
			SUPER_NOT_CALLED = 'Super is not being called in the initializer for %s which extends %s',
			SERIALIZER_NOT_IMPLEMENTED = 'No implementation exists to serialize an Instance of %s to %q',

			META = { -- mirror Roblox errors
				BAD_CALL = 'attempt to call an Instance of %s',
				BAD_COMPARE = 'attempt to compare Instance of %s and %s',
				BAD_CONCAT = 'attempt to concatenate Instance of %s with %s',
				BAD_ARITHMETIC = 'attempt to perform arithmetic (%s) on Instance of %s and %s'
			},

			IS_A = {
				CLASS_NOT_FOUND = 'Could not find a valid class with the name %s in a call to %s',
			}
		},

		DATA = {
			METADATA_QUERY_NOT_IMPLEMENTED = 'DataStore v2.0 does not yet support querying by metadata. For this reason, MarketService.getReceiptsForPlace and MarketService.getReceiptsForProduct will be disabled until support is implemented.'
		}
	}
}

table.freeze(Debug.ERROR)

return table.freeze(Debug)