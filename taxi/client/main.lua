local _working = false
local _currentPassenger = nil
local _currentDestination = nil
local _currentBlip = nil
local _vehicle = nil

local function getTaxiRep()
    return Reputation:GetLevel("Taxi") or 0
end

AddEventHandler("Taxi:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Logger = exports["lumen-base"]:FetchComponent("Logger")
    Callbacks = exports["lumen-base"]:FetchComponent("Callbacks")
    PedInteraction = exports["lumen-base"]:FetchComponent("PedInteraction")
    Notification = exports["lumen-base"]:FetchComponent("Notification")
    Polyzone = exports["lumen-base"]:FetchComponent("Polyzone")
    Reputation = exports["lumen-base"]:FetchComponent("Reputation")
    Progress = exports["lumen-base"]:FetchComponent("Progress")
    NetSync = exports["lumen-base"]:FetchComponent("NetSync")
    Action = exports["lumen-base"]:FetchComponent("Action")
    Keybinds = exports["lumen-base"]:FetchComponent("Keybinds")
    Inventory = exports["lumen-base"]:FetchComponent("Inventory")
	ListMenu = exports["lumen-base"]:FetchComponent("ListMenu")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["lumen-base"]:RequestDependencies("Taxi", {
		"Logger",
		"Callbacks",
		"PedInteraction",
		"Notification",
		"Polyzone",
		"Reputation",
		"Progress",
		"NetSync",
		"Action",
		"Keybinds",
		"Inventory",
		"ListMenu",
	}, function(error)
		if #error > 0 then
			return
		end

		RetrieveComponents()
		TriggerEvent("Taxi:Client:Setup")
	end)
end)

AddEventHandler("Taxi:Client:Setup", function()
	PedInteraction:Add("TaxiPed", GetHashKey("mp_m_boatstaff_01"), Config.StartPedCoords, Config.StartPedHeading, 25.0, {
		{
			icon = "list",
			text = "Open Job Menu",
			event = "Taxi:Client:OpenJobMenu",
		},
	}, "taxi")
end)

AddEventHandler("Taxi:Client:OpenJobMenu", function()
    Callbacks:ServerCallback("Taxi:Server:OpenMenu", {}, function(success, taxiData)
        if success and taxiData ~= nil then
            if not _working then
                ListMenu:Show({
                    main = {
                        label = "Taxi Job Menu",
                        items = {
                            {
                                label = "Start Shift",
                                description = "Start your shift as a taxi driver.",
                                submenu = "rentals",
                            },
                            {
                                label = "Lifetime Earnings",
                                description = string.format("You have earned $%s in total.", taxiData.earnings),
                            },
                        }
                    },
                    rentals = {
                        label = "Taxi Rentals",
                        items = {
                            {
                                label = "Crown Vic",
                                description = "Tier 1: $25 - $50",
                                data = {
                                    vehicle = "taxi",
                                    tier = 1,
                                },
                                event = "Taxi:Client:StartShift",
                            },
                            {
                                label = "Buffalo",
                                description = "Tier 2: $35 - $60",
                                data = {
                                    vehicle = "nkstxtaxi",
                                    tier = 2,
                                },
                                event = "Taxi:Client:StartShift",
                                disabled = getTaxiRep() < 2,
                            },
                            {
                                label = "Landstalker XL",
                                description = "Tier 3: $50 - $75",
                                data = {
                                    vehicle = "nklandstalker2taxi",
                                    tier = 3,
                                },
                                event = "Taxi:Client:StartShift",
                                disabled = getTaxiRep() < 4,
                            },
                            {
                                label = "Rhinehart",
                                description = "Tier 4: $65 - $90",
                                data = {
                                    vehicle = "nkrhineharttaxi",
                                    tier = 4,
                                },
                                event = "Taxi:Client:StartShift",
                                disabled = getTaxiRep() < 6,
                            },
                            {
                                label = "Granger 3600LX",
                                description = "Tier 5: $100 - $125",
                                data = {
                                    vehicle = "nkgranger2taxi",
                                    tier = 5,
                                },
                                event = "Taxi:Client:StartShift",
                                disabled = getTaxiRep() < 8,
                            },
                            {
                                label = "Baller ST",
                                description = "Tier 6: $120 - $145",
                                data = {
                                    vehicle = "nkballer7taxi",
                                    tier = 6,
                                },
                                event = "Taxi:Client:StartShift",
                                disabled = getTaxiRep() < 10,
                            },
                            {
                                label = "Omnis E-GT",
                                description = "Tier 7: $150 - $175",
                                data = {
                                    vehicle = "nkomnisegttaxi",
                                    tier = 7,
                                },
                                event = "Taxi:Client:StartShift",
                                disabled = getTaxiRep() < 12,
                            },
                            {
                                label = "Fugitive",
                                description = "Tier 8: $175 - $200",
                                data = {
                                    vehicle = "nkfugitivetaxi",
                                    tier = 8,
                                },
                                event = "Taxi:Client:StartShift",
                                disabled = getTaxiRep() < 14,
                            },
                            {
                                label = "Komoda",
                                description = "Tier 9: $200 - $225",
                                data = {
                                    vehicle = "nkkomodataxi",
                                    tier = 9,
                                },
                                event = "Taxi:Client:StartShift",
                                disabled = getTaxiRep() < 16,
                            },
                            {
                                label = "Jugular",
                                description = "Max Tier: $225 - $250",
                                data = {
                                    vehicle = "nkjugulartaxi",
                                    tier = 10,
                                },
                                event = "Taxi:Client:StartShift",
                                disabled = getTaxiRep() < 18,
                            },
                        }
                    }
                })
            else
                ListMenu:Show({
                    main = {
                        label = "Taxi Job Menu",
                        items = {
                            {
                                label = "End Shift",
                                description = "End your shift and return vehicle.",
                                event = "Taxi:Client:EndShift",
                            },
                        }
                    }
                })
            end
        end
    end)
end)

AddEventHandler("Taxi:Client:StartShift", function(data)
	if not data or not data.vehicle or not data.tier then
		Notification:Error("Invalid data provided to start shift.")
		return
	end

	if _working then
		Notification:Error("You are already working a shift.")
		return
	end

	local model = data.vehicle
	local tier = data.tier

	Callbacks:ServerCallback("Taxi:Server:StartShift", {
		model = model,
		tier = tier
	}, function(success, vehNetId)
		if success then
			_working = true
			_vehicle = NetToVeh(vehNetId)
			startTaxiRoute()
		end
	end)
end)

function startTaxiRoute()
    local pickup = Config.Pickups[math.random(1, #Config.Pickups)]
    local pedModel = Config.PedModels[math.random(1, #Config.PedModels)]

    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Citizen.Wait(100)
    end
    _currentPassenger = CreatePed(4, pedModel, pickup.coords.x, pickup.coords.y, pickup.coords.z, pickup.coords.w, true, false)
    SetEntityAsMissionEntity(_currentPassenger, true, true)

    SetModelAsNoLongerNeeded(pedModel)

    if pickup.animation == "idle" then
        RequestAnimDict("amb@world_human_stand_impatient@male@no_sign@idle_a")
        while not HasAnimDictLoaded("amb@world_human_stand_impatient@male@no_sign@idle_a") do
            Citizen.Wait(100)
        end
        TaskPlayAnim(_currentPassenger, "amb@world_human_stand_impatient@male@no_sign@idle_a", "idle_a", 8.0, -8.0, -1, 1, 0, false, false, false)
    end

    _currentBlip = AddBlipForCoord(pickup.coords.x, pickup.coords.y, pickup.coords.z)
    SetBlipSprite(_currentBlip, 280)
    SetBlipColour(_currentBlip, 3)
    SetBlipRoute(_currentBlip, true)
	SetBlipRouteColour(_currentBlip, 5)

    Notification:Info("A passenger is waiting for you at " .. pickup.label .. ". Head over to pick them up.")

    Citizen.CreateThread(function()
        while _working and DoesEntityExist(_currentPassenger) do
            local playerPed = LocalPlayer.state.ped
            local playerVeh = GetVehiclePedIsIn(playerPed, false)
            local passengerCoords = GetEntityCoords(_currentPassenger)
            local playerCoords = GetEntityCoords(playerPed)
            if playerVeh == _vehicle and #(playerCoords - passengerCoords) < 5.0 and IsPedInVehicle(playerPed, _vehicle) then
                TaskEnterVehicle(_currentPassenger, _vehicle, -1, 2, 1.0, 1, 0)
                PlayPedAmbientSpeechNative(_currentPassenger, "GENERIC_HI", "SPEECH_PARAMS_STANDARD")
                RemoveBlip(_currentBlip)
                _currentBlip = nil
                Citizen.Wait(6000)
                setDestination()
                break
            end
            Citizen.Wait(500)
        end
    end)
end

function setDestination()
    _currentDestination = Config.Destinations[math.random(1, #Config.Destinations)]
    _currentBlip = AddBlipForCoord(_currentDestination.coords.x, _currentDestination.coords.y, _currentDestination.coords.z)
    SetBlipSprite(_currentBlip, 1)
    SetBlipColour(_currentBlip, 3)
    SetBlipRoute(_currentBlip, true)
	SetBlipRouteColour(_currentBlip, 5)

    Notification:Info("Destination set to " .. _currentDestination.label .. ". Drive the passenger there.")

    Citizen.CreateThread(function()
        local startCoords = GetEntityCoords(_currentPassenger)

        while _working and DoesEntityExist(_currentPassenger) do
            local passengerCoords = GetEntityCoords(_currentPassenger)
            local destCoords = vector3(_currentDestination.coords.x, _currentDestination.coords.y, _currentDestination.coords.z)

            if #(passengerCoords - destCoords) < 10.0 then
                local droppedPed = _currentPassenger
				Citizen.Wait(1500)
                TaskLeaveVehicle(droppedPed, _vehicle, 1)
                PlayPedAmbientSpeechNative(droppedPed, "GENERIC_THANKS", "SPEECH_PARAMS_STANDARD")
				Citizen.Wait(1250)
				ClearPedTasks(droppedPed)
				SetVehicleDoorShut(_vehicle, 3, true)
                SetEntityAsNoLongerNeeded(droppedPed)

                Callbacks:ServerCallback("Taxi:Server:CompleteFare", {}, function() end)

                RemoveBlip(_currentBlip)
                _currentBlip = nil
                _currentPassenger = nil
                _currentDestination = nil

                Citizen.CreateThread(function()
                    Citizen.Wait(15000)
                    if DoesEntityExist(droppedPed) then
                        SetEntityAsMissionEntity(droppedPed, true, true)
                        DeletePed(droppedPed)
                    end
                end)

                Citizen.Wait(5000)
                startTaxiRoute()
                break
            end

            Citizen.Wait(500)
        end
    end)
end

AddEventHandler("Taxi:Client:EndShift", function()
    if DoesEntityExist(_vehicle) then
        Callbacks:ServerCallback("Taxi:Server:EndShift", {}, function(success)
            if success then
                Notification:Success("Your shift has ended and the vehicle has been returned.")
            else
                Notification:Error("Your taxi rental must be close by.")
            end
        end)
    end
    if DoesEntityExist(_currentPassenger) then
        SetEntityAsMissionEntity(_currentPassenger, true, true)
        DeletePed(_currentPassenger)
    end
    if _currentBlip then
        RemoveBlip(_currentBlip)
    end
    _working = false
    _vehicle = nil
    _currentPassenger = nil
    _currentDestination = nil
    _currentBlip = nil
end)