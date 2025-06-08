_plants = {}

AddEventHandler("Weed:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Database = exports["lumen-base"]:FetchComponent("Database")
	Callbacks = exports["lumen-base"]:FetchComponent("Callbacks")
	Logger = exports["lumen-base"]:FetchComponent("Logger")
	Middleware = exports["lumen-base"]:FetchComponent("Middleware")
	Logger = exports["lumen-base"]:FetchComponent("Logger")
	Utils = exports["lumen-base"]:FetchComponent("Utils")
	Locations = exports["lumen-base"]:FetchComponent("Locations")
	Game = exports["lumen-base"]:FetchComponent("Game")
	Weed = exports["lumen-base"]:FetchComponent("Weed")
	Routing = exports["lumen-base"]:FetchComponent("Routing")
	Fetch = exports["lumen-base"]:FetchComponent("Fetch")
	Inventory = exports["lumen-base"]:FetchComponent("Inventory")
	Execute = exports["lumen-base"]:FetchComponent("Execute")
	Routing = exports["lumen-base"]:FetchComponent("Routing")
	Tasks = exports["lumen-base"]:FetchComponent("Tasks")
	Wallet = exports["lumen-base"]:FetchComponent("Wallet")
	Reputation = exports["lumen-base"]:FetchComponent("Reputation")
	WaitList = exports["lumen-base"]:FetchComponent("WaitList")
	Chat = exports["lumen-base"]:FetchComponent("Chat")
	Status = exports["lumen-base"]:FetchComponent("Status")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["lumen-base"]:RequestDependencies("Weed", {
		"Database",
		"Callbacks",
		"Logger",
		"Middleware",
		"Logger",
		"Execute",
		"Utils",
		"Locations",
		"Game",
		"Routing",
		"Fetch",
		"Weed",
		"Inventory",
		"Routing",
		"Tasks",
		"Wallet",
		"Reputation",
		"WaitList",
		"Chat",
		"Status",
	}, function(error)
		if #error > 0 then
			return
		end -- Do something to handle if not all dependencies loaded
		RetrieveComponents()
		Startup()
		RegisterMiddleware()
		RegisterCallbacks()
		RegisterTasks()
		RegisterItems()
	end)
end)

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["lumen-base"]:RegisterComponent("Weed", WEED)
end)

function getStageByPct(pct)
    if pct < 25 then return 1
    elseif pct < 50 then return 2
    elseif pct < 75 then return 3
    else return 4
    end
end

function checkNearPlant(source, id)
	local coords = GetEntityCoords(GetPlayerPed(source))
	if _plants[id] ~= nil then
		return #(
				vector3(coords.x, coords.y, coords.z)
				- vector3(_plants[id].plant.location.x, _plants[id].plant.location.y, _plants[id].plant.location.z)
			) <= 5
	else
		return false
	end
end

WEED = {
	Planting = {
		Set = function(self, id, isUpdate, skipEvent)
			if _plants[id] ~= nil then
				local stage = getStageByPct(_plants[id].plant.growth)
				_plants[id].stage = stage

				if skipEvent then
					return { id = id, plant = _plants[id], update = isUpdate }
				else
					TriggerClientEvent("Weed:Client:Objects:Update", -1, id, _plants[id], isUpdate)
				end
			end
		end,
		Delete = function(self, id, skipRemove)
			if _plants[id] ~= nil then
				_plants[id] = nil
				TriggerClientEvent("Weed:Client:Objects:Delete", -1, id)
			end
		end,
		Create = function(self, isMale, location, material, strain)
			local p = promise.new()
			local weed = {
				isMale = isMale,
				location = location,
				growth = 0,
				output = 1,
				material = material,
				planted = os.time(),
				water = 100.0,
				strain = strain
			}
			Database.Game:insertOne({
				collection = "weed",
				document = weed,
			}, function(success, results, insertedIds)
				if not success then
					return p:resolve(nil)
				end
				weed._id = insertedIds[1]
				return p:resolve(weed)
			end)
			return Citizen.Await(p)
		end,
	},
}
