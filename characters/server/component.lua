ONLINE_CHARACTERS = {}

AddEventHandler("Characters:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Middleware = exports["lumen-base"]:FetchComponent("Middleware")
	Database = exports["lumen-base"]:FetchComponent("Database")
	Callbacks = exports["lumen-base"]:FetchComponent("Callbacks")
	DataStore = exports["lumen-base"]:FetchComponent("DataStore")
	Logger = exports["lumen-base"]:FetchComponent("Logger")
	Database = exports["lumen-base"]:FetchComponent("Database")
	Fetch = exports["lumen-base"]:FetchComponent("Fetch")
	Logger = exports["lumen-base"]:FetchComponent("Logger")
	Chat = exports["lumen-base"]:FetchComponent("Chat")
	GlobalConfig = exports["lumen-base"]:FetchComponent("Config")
	Routing = exports["lumen-base"]:FetchComponent("Routing")
	Sequence = exports["lumen-base"]:FetchComponent("Sequence")
	Reputation = exports["lumen-base"]:FetchComponent("Reputation")
	Apartment = exports["lumen-base"]:FetchComponent("Apartment")
	Phone = exports["lumen-base"]:FetchComponent("Phone")
	Damage = exports["lumen-base"]:FetchComponent("Damage")
	Punishment = exports["lumen-base"]:FetchComponent("Punishment")
	Execute = exports["lumen-base"]:FetchComponent("Execute")
	RegisterCommands()
	_spawnFuncs = {}
end

AddEventHandler("Core:Shared:Ready", function()
	exports["lumen-base"]:RequestDependencies("Characters", {
		"Callbacks",
		"Database",
		"Middleware",
		"DataStore",
		"Logger",
		"Database",
		"Fetch",
		"Logger",
		"Chat",
		"Config",
		"Routing",
		"Sequence",
		"Reputation",
		"Apartment",
		"Phone",
		"Damage",
		"Punishment",
		"Execute",
	}, function(error)
		if #error > 0 then
			return
		end -- Do something to handle if not all dependencies loaded
		RetrieveComponents()
		RegisterCallbacks()
		RegisterMiddleware()
		Startup()
	end)
end)

CHARACTERS = {
	GetLastLocation = function(self, source)
		return _tempLastLocation[source] or false
	end,
}

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["lumen-base"]:RegisterComponent("Characters", CHARACTERS)
end)