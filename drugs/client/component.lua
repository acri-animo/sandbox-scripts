local _weedLabProps = {}
local poly = nil

local drugLabs = {
	{
		model = `k4weed_shell`,
		coords = vector4(338.076, 3398.296, 23.811, 287.475),
		spawn = vector4(332.496, 3407.754, 27.782, 200.402),
	},
	{
		model = `k4meth_shell`,
		coords = vector4(-1200.0, -1565.0, 4.0, 0.0),
		spawn = vector4(-1200.0, -1565.0, 4.0, 0.0),	
	},
	{
		model = `k4coke_shell`,
		coords = vector4(-1200.0, -1565.0, 4.0, 0.0),
		spawn = vector4(-1200.0, -1565.0, 4.0, 0.0),
	},
}

AddEventHandler("Drugs:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Callbacks = exports["lumen-base"]:FetchComponent("Callbacks")
	Inventory = exports["lumen-base"]:FetchComponent("Inventory")
	Targeting = exports["lumen-base"]:FetchComponent("Targeting")
	Progress = exports["lumen-base"]:FetchComponent("Progress")
	Hud = exports["lumen-base"]:FetchComponent("Hud")
	Notification = exports["lumen-base"]:FetchComponent("Notification")
	ObjectPlacer = exports["lumen-base"]:FetchComponent("ObjectPlacer")
	Minigame = exports["lumen-base"]:FetchComponent("Minigame")
	ListMenu = exports["lumen-base"]:FetchComponent("ListMenu")
	PedInteraction = exports["lumen-base"]:FetchComponent("PedInteraction")
	Polyzone = exports["lumen-base"]:FetchComponent("Polyzone")
	Buffs = exports["lumen-base"]:FetchComponent("Buffs")
	Minigame = exports["lumen-base"]:FetchComponent("Minigame")
	Status = exports["lumen-base"]:FetchComponent("Status")
	Reputation = exports["lumen-base"]:FetchComponent("Reputation")
	Animations = exports["lumen-base"]:FetchComponent("Animations")
	Sounds = exports["lumen-base"]:FetchComponent("Sounds")
	Keybinds = exports["lumen-base"]:FetchComponent("Keybinds")
	Action = exports["lumen-base"]:FetchComponent("Action")
	EmergencyAlerts = exports["lumen-base"]:FetchComponent("EmergencyAlerts")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["lumen-base"]:RequestDependencies("Drugs", {
		"Callbacks",
		"Inventory",
		"Targeting",
		"Progress",
		"Hud",
		"Notification",
		"ObjectPlacer",
		"Minigame",
		"ListMenu",
		"PedInteraction",
		"Polyzone",
		"Buffs",
		"Minigame",
		"Status",
		"Reputation",
		"Animations",
		"Sounds",
		"Keybinds",
		"Action",
		"EmergencyAlerts",
	}, function(error)
		if #error > 0 then
			exports["lumen-base"]:FetchComponent("Logger"):Critical("Drugs", "Failed To Load All Dependencies")
			return
		end

		RetrieveComponents()
		SpawnDrugsLabs()
		TriggerEvent("Drugs:Client:Startup")
	end)
end)

AddEventHandler("Drugs:Client:Startup", function()
	for k, v in ipairs(Config.LabPolys) do
		Polyzone.Create:Box(v.id, v.coords, v.length, v.width, v.options)
	end
end)

AddEventHandler("Polyzone:Enter", function(id, testedPoint, insideZones, data)
	if id == "weed_lab_entrance" then
		poly = "weed_enter"

		if Inventory.Check.Player:HasItem("weed_lab_card", 1) then
			Action:Show("weed_lab_entrance", "{keybind}primary_action{/keybind} Enter Weed Lab")
		end
	end

	if id == "weed_lab_exit" then
		poly = "weed_exit"
		Action:Show("weed_lab_exit", "{keybind}primary_action{/keybind} Exit Weed Lab")
	end
end)

AddEventHandler("Polyzone:Exit", function(id, testedPoint, insideZones, data)
	if id == "weed_lab_entrance" then
		poly = nil
		Action:Hide("weed_lab_entrance")
	elseif id == "weed_lab_exit" then
		poly = nil
		Action:Hide("weed_lab_exit")
	end
end)

AddEventHandler("Keybinds:Client:KeyUp:primary_action", function()
	if poly == "weed_enter" then
		if not Inventory.Check.Player:HasItem("weed_lab_card", 1) then
			return
		end

		Sounds.Play:One("door_open.ogg", 0.15)

		DoScreenFadeOut(1000)
		while not IsScreenFadedOut() do
			Citizen.Wait(10)
		end

		FreezeEntityPosition(PlayerPedId(), true)
		Citizen.Wait(50)

		spawnShellProps()

		SetEntityCoords(PlayerPedId(), 332.496, 3407.754, 27.782, 0, 0, 0, false)
		SetEntityHeading(PlayerPedId(), 200.402)

		local time = GetGameTimer()
		while (not HasCollisionLoadedAroundEntity(PlayerPedId()) and (GetGameTimer() - time) < 10000) do
			Citizen.Wait(100)
		end

		FreezeEntityPosition(PlayerPedId(), false)

		DoScreenFadeIn(1000)
		while not IsScreenFadedIn() do
			Citizen.Wait(10)
		end

	elseif poly == "weed_exit" then
		Sounds.Play:One("door_close.ogg", 0.15)

		DoScreenFadeOut(1000)
		while not IsScreenFadedOut() do
			Citizen.Wait(10)
		end

		FreezeEntityPosition(PlayerPedId(), true)
		Citizen.Wait(50)

		deleteShellProps()

		SetEntityCoords(PlayerPedId(), 346.478, 3406.330, 36.502, 0, 0, 0, false)
		SetEntityHeading(PlayerPedId(), 23.503)

		local time = GetGameTimer()
		while (not HasCollisionLoadedAroundEntity(PlayerPedId()) and (GetGameTimer() - time) < 10000) do
			Citizen.Wait(100)
		end

		FreezeEntityPosition(PlayerPedId(), false)

		DoScreenFadeIn(1000)
		while not IsScreenFadedIn() do
			Citizen.Wait(10)
		end
	end
end)

function SpawnDrugsLabs()
	for k, v in pairs(drugLabs) do
		local shellModel = v.model
		local spawnCoords = v.coords

		if not HasModelLoaded(shellModel) then
			RequestModel(shellModel)
			while not HasModelLoaded(shellModel) do
				Citizen.Wait(100)
			end
		end

		local spawnedShell = CreateObject(shellModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false)
		FreezeEntityPosition(spawnedShell, true)
		SetEntityHeading(spawnedShell, spawnCoords.w)

		SetModelAsNoLongerNeeded(shellModel)
	end
end

function spawnShellProps()
	for k, v in ipairs(Config.WeedLabProps) do
		if not HasModelLoaded(v.model) then
			RequestModel(v.model)
			while not HasModelLoaded(v.model) do
				Citizen.Wait(100)
			end
		end

		local prop = CreateObject(v.model, v.coords.x, v.coords.y, v.coords.z, false, false, false)
		SetEntityHeading(prop, v.coords.w)
		FreezeEntityPosition(prop, true)
		SetModelAsNoLongerNeeded(v.model)

		table.insert(_weedLabProps, prop)
	end

	local resinMachine = `bzzz_plants_weed_rosin2_c`

	Targeting:AddObject(resinMachine, "cannabis", {
		{
			icon = "hand",
			text = "Use Rosin Press",
			event = "Drugs:Client:WeedLab:UseRosinPress",
			data = {},
		}
	})
end

function deleteShellProps()
	for _, prop in ipairs(_weedLabProps) do
		if DoesEntityExist(prop) then
			DeleteObject(prop)
		end
	end
	_weedLabProps = {}
end
