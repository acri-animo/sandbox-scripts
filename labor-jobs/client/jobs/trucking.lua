local _joiner = nil
local _working = false
local _blip = nil
local _state = 0
local dropoffPedCoords = nil
local dropoffPedHandle = nil
local trailerBlip = nil
local dropoffBlip = nil
local allHostilesDead = false
local damageThreshold = 980
local _dropProgString = nil
local _dropLoc = nil
local _targetString = nil
local _jobData = nil
local hostilePeds = {}
local eventHandlers = {}

local JobsConfig = {
    legal = {
        { label = 'Industrial Delivery', description = 'Deliver construction materials to job sites.', level = 0 },
        { label = 'Meat Delivery', description = 'Supply fresh meat to butcher shops.', level = 2 },
        { label = 'Alcohol Delivery', description = 'Deliver alcohol to bars, stores, and breweries.', level = 4 },
        { label = 'Farm Supply Delivery', description = 'Transport seeds, tools, and fertilizers to farms.', level = 6 },
        { label = 'Pharmaceutical Delivery', description = 'Deliver medicines to hospitals and clinics.', level = 8 },
        { label = 'Fuel Delivery', description = 'Refill underground tanks at gas stations.', level = 10 },
        { label = 'Vehicle Delivery', description = 'Transport luxury cars to private clients.', level = 15 }
    },
    illegal = {
        { label = 'Drug Shipment Delivery', description = 'Smuggle narcotics to secret drop-offs.', level = 3 },
        { label = 'High-Value Material Delivery', description = 'Deliver rare materials to black market dealers.', level = 5 },
        { label = 'Stolen Jewelry Delivery', description = 'Move stolen jewelry to private pawns.', level = 7 },
        { label = 'Stolen Electronics Delivery', description = 'Transport stolen electronics to clients.', level = 9 },
        { label = 'Ammo Shipment Delivery', description = 'Deliver ammunition to underground arms dealers.', level = 11 },
        { label = 'Illegal Firearm Delivery', description = 'Move weapons to criminal organizations.', level = 13 },
        { label = 'Counterfeit Money Delivery', description = 'Distribute fake currency to buyers.', level = 15 },
        { label = 'Human Organs Delivery', description = 'Deliver harvested organs for illicit trade.', level = 17 },
        { label = 'Nuclear Material Delivery', description = 'Transport nuclear substances to dangerous buyers.', level = 20 }
    }
}

------------
-- Functions
------------

-- Check if player has VPN item
local function illJobItemCheck()
    return Inventory.Check.Player:HasItem("vpn", 1)
end

-- Get player's trucking rep level to determine job availability
local function GetReputationLevel()
    return Reputation:GetLevel("Trucking")
end

-- Generate Job Items for ListMenu
local function GenerateJobItems(jobType, reputation)
    local items = {}
    local hasVPN = illJobItemCheck()

    for _, job in ipairs(JobsConfig[jobType]) do
        local isDisabled = false

        if jobType == "illegal" then
            isDisabled = not hasVPN or reputation < job.level
        else
            isDisabled = reputation < job.level
        end

        local event = jobType == "legal" and 'Trucking:Client:StartJibbityJob' or 'Trucking:Client:StartIllJibbity'

        table.insert(items, {
            label = job.label,
            description = job.description,
            event = event,
            data = { level = job.level, type = jobType },
            disabled = isDisabled
        })
    end

    return items
end

-- Get Random Dropoff Location
local function getRandomDropoffLocation(dropCoords)
    if dropCoords then
        return dropCoords[math.random(1, #dropCoords)]
    else
        print("No dropoff locations found")
    end
end

-- Spawn Illegal Trucking Peds
local function SetupTruckPeds(peds)
	for k, v in ipairs(peds) do
		--print("Setting up ped with Network ID: ", v) -- Debug print
		while not DoesEntityExist(NetworkGetEntityFromNetworkId(v)) do
			Citizen.Wait(1)
		end

		local ped = NetworkGetEntityFromNetworkId(v)

		local interior = GetInteriorFromEntity(ped)
		if interior ~= 0 then
			local roomHash = GetRoomKeyFromEntity(ped)
			if roomHash ~= 0 then
				ForceRoomForEntity(ped, interior, roomHash)
				--print("Ped entity created: ", ped) -- Debug print
			end
		end

		DecorSetBool(ped, "ScriptedPed", true)
		SetEntityAsMissionEntity(ped, 1, 1)
        SetEntityMaxHealth(ped, 1150)
        SetEntityHealth(ped, 1150)
        SetPedArmour(ped, 350)
		SetPedRelationshipGroupDefaultHash(ped, `BOBCAT_SECURITY`)
		SetPedRelationshipGroupHash(ped, `BOBCAT_SECURITY`)
		SetPedRelationshipGroupHash(ped, `HATES_PLAYER`)
        SetCanAttackFriendly(ped, false, true)
		SetPedAsCop(ped)

		TaskTurnPedToFaceEntity(ped, PlayerPedId(), 1.0)
	end

	for k, v in ipairs(peds) do
		local ped = NetworkGetEntityFromNetworkId(v)
        table.insert(hostilePeds, ped)

		SetPedCombatAttributes(ped, 0, 1)
		SetPedCombatAttributes(ped, 3, 1)
		SetPedCombatAttributes(ped, 5, 1)
		SetPedCombatAttributes(ped, 46, 1)
		SetPedSeeingRange(ped, 3000.0)
		SetPedHearingRange(ped, 3000.0)
		SetPedAlertness(ped, 3)
		SetPedCombatRange(ped, 2)
		SetPedCombatMovement(ped, 2)
		SetPedCanSwitchWeapon(ped, true)
		SetPedSuffersCriticalHits(ped, false)
		SetRunSprintMultiplierForPlayer(ped, 1.49)
		TaskCombatHatedTargetsInArea(ped, GetEntityCoords(ped), 200.0, false)
		SetPedAsEnemy(ped, true)
		SetPedFleeAttributes(ped, 0, 0)

		local _, cur = GetCurrentPedWeapon(ped, true)
		SetPedInfiniteAmmo(ped, true, cur)
		SetPedDropsWeaponsWhenDead(ped, false)

		SetEntityInvincible(ped, false)

		TaskGoToEntityWhileAimingAtEntity(ped, PlayerPedId(), PlayerPedId(), 16.0, true, 0, 15, 1, 1, 1566631136)
		TaskCombatPed(ped, PlayerPedId(), 0, 16)
	end

    Citizen.CreateThread(function()
        Citizen.Wait(300000)
        for i, ped in ipairs(hostilePeds) do
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
                table.remove(hostilePeds, i)
            end
        end
    end)
end

-- Monitor tanker/truck damage for fuel delivery job
local function MonitorTankerDamageClient(truck, trailer)
    if truck and trailer then
        -- Store the initial health values
        local initialTruckBodyHealth = GetVehicleBodyHealth(truck)
        local initialTruckHealth = GetVehicleEngineHealth(truck)
        local initialTrailerHealth = GetVehicleEngineHealth(trailer)

        Citizen.CreateThread(function()
            while DoesEntityExist(truck) and DoesEntityExist(trailer) do
                local currentTruckBodyHealth = GetVehicleBodyHealth(truck)
                local currentTruckHealth = GetVehicleEngineHealth(truck)
                local currentTrailerHealth = GetVehicleEngineHealth(trailer)

                if (initialTruckBodyHealth - currentTruckBodyHealth) >= 10 then
                    Notification:Error("Tanker exploded due to damage!")
                    AddExplosion(GetEntityCoords(truck), 2, 10.0, true, false, 1.0)
                    AddExplosion(GetEntityCoords(trailer), 2, 10.0, true, false, 1.0)
                    break
                end

                if (initialTruckHealth - currentTruckHealth) >= 10 or (initialTrailerHealth - currentTrailerHealth) >= 20 then
                    Notification:Error("Tanker exploded due to damage!")
                    AddExplosion(GetEntityCoords(truck), 2, 10.0, true, false, 1.0)
                    AddExplosion(GetEntityCoords(trailer), 2, 10.0, true, false, 1.0)
                    break
                end

                initialTruckBodyHealth = currentTruckBodyHealth
                initialTruckHealth = currentTruckHealth
                initialTrailerHealth = currentTrailerHealth

                Citizen.Wait(1000)
            end
        end)
    end
end

------------------
-- Events/Handlers
------------------

AddEventHandler("Labor:Client:Setup", function()
    PedInteraction:Add("TruckingJob", GetHashKey("s_m_m_trucker_01"), vector3(1239.328, -3173.741, 6.105), 275.467, 25.0, {
        {
            icon = "clipboard-list",
            text = "Open Job Menu",
            event = "Trucking:Client:JobPedMenu",
            tempjob = "Trucking",
            isEnabled = function()
                return not _working
            end,
        },
        {
            icon = "truck-moving",
            text = "Get Truck & Trailer",
            event = "Trucking:Client:TruckTrailerSpawn",
            tempjob = "Trucking",
            isEnabled = function()
                return _working and _state == 1
            end,
        },
        {
            icon = "check",
            text = "Return Truck",
            event = "Trucking:Client:CompleteJob",
            tempjob = "Trucking",
            isEnabled = function()
                return _working and _state == 4
            end,
        },
    }, "truck")

    Callbacks:RegisterClientCallback("Trucking:Client:SpawnMfPeds", function(data, cb)
        SetupTruckPeds(data.peds)
    end)
end)

AddEventHandler("Trucking:Client:JobPedMenu", function()
    local reputation = GetReputationLevel()

    if not _working then
        ListMenu:Show({
            main = {
                label = 'Trucking Job',
                items = {
                    {
                        label = 'Legal Jobs',
                        description = 'Complete a variety of blue-collar trucking jobs.',
                        submenu = 'legal'
                    },
                    {
                        label = 'Illegal Jobs',
                        description = 'Riskier take but it might pay off.',
                        submenu = 'illegal',
                        disabled = not illJobItemCheck() and reputation < 3
                    }
                }
            },
            legal = {
                label = 'Legal Trucking Jobs',
                items = GenerateJobItems('legal', reputation)
            },
            illegal = {
                label = 'Illegal Trucking Jobs',
                items = GenerateJobItems('illegal', reputation)
            }
        })
    else
        ListMenu:Show({
            main = {
                label = 'Trucking Job',
                items = {
                    {
                        label = 'Return Truck',
                        description = 'End trucking job.',
                        event = 'Trucking:Client:EndJob',
                        disabled = not _state == 4
                    },
                    {
                        label = 'End Job',
                        description = 'End trucking job.',
                        event = 'Trucking:Client:EndJob',
                        disabled = not _state == 4
                    }
                }
            }
        })
    end
end)

RegisterNetEvent("Trucking:Client:OnDuty", function(joiner, time)
    _joiner = joiner
    DeleteWaypoint()
    SetNewWaypoint(1239.328, -3173.741)
    _blip = Blips:Add("TruckingStart", "Trucking Manager", { x = 1239.328, y = -3173.741, z = 7.105 }, 480, 2, 1.4)

    eventHandlers["startup"] = RegisterNetEvent(string.format("Trucking:Client:%s:Startup", joiner), function(location, trgtStrg, dropStrng, dropPed)
        _working = true
        _dropProgString = dropStrng
        _dropLoc = location
        _targetString = trgtStrg
        _dropoffPed = dropPed

        dropoffPedCoords = _dropLoc
        dropoffPedHandle = PedInteraction:Add("TruckingDropoff", GetHashKey(_dropoffPed), vector3(dropoffPedCoords.x, dropoffPedCoords.y, dropoffPedCoords.z), dropoffPedCoords.w, 25.0, {
            {
                icon = "truck-moving",
                text = _targetString,
                event = "Trucking:Client:DropoffTrailer",
                tempjob = "Trucking",
                isEnabled = function()
                    return _working and _state == 3
                end,
            },
        }, "truck")
        dropoffBlip = AddBlipForCoord(dropoffPedCoords.x, dropoffPedCoords.y, dropoffPedCoords.z)
        SetBlipSprite(dropoffBlip, 1)
        SetBlipColour(dropoffBlip, 2)
        SetBlipAsShortRange(dropoffBlip, false)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Dropoff Location")
        EndTextCommandSetBlipName(dropoffBlip)
    end)

    eventHandlers["update-waypoint"] = RegisterNetEvent(string.format("Trucking:Client:%s:UpdateWaypoint", joiner), function(location, coords)
        if location == "dropoff" then
            SetNewWaypoint(dropoffPedCoords.x, dropoffPedCoords.y)
        elseif location == "docks" then
            SetNewWaypoint(1239.328, -3173.741)
        elseif location == "trailer" and coords then
            SetNewWaypoint(coords.x, coords.y)
    
            if trailerBlip ~= nil then
                RemoveBlip(trailerBlip)
            end

            trailerBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
            SetBlipSprite(trailerBlip, 477)
            SetBlipColour(trailerBlip, 5)
            SetBlipScale(trailerBlip, 1.0)
            SetBlipAsShortRange(trailerBlip, false)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Trailer Location")
            EndTextCommandSetBlipName(trailerBlip)
        end
    end)

    eventHandlers["truck-spawn"] = RegisterNetEvent("Trucking:Client:TruckTrailerSpawn", function()
        if _state == 1 then
            Callbacks:ServerCallback("Trucking:TruckTrailerSpawn", {}, function(reject)
                if reject then
                    _state = 2
                    if _jobData.level == 10 then
                        Citizen.CreateThread(function()
                            while true do
                                Citizen.Wait(1000)
                                if _state == 3 then
                                    local playerPed = PlayerPedId()
                                    local vehicle = GetVehiclePedIsIn(playerPed, false)
                                    if vehicle and DoesEntityExist(vehicle) then
                                        local retval, trailer = GetVehicleTrailerVehicle(vehicle)
                                        if retval and DoesEntityExist(trailer) then
                                            MonitorTankerDamageClient(vehicle, trailer)
                                            break
                                        end
                                    end
                                end
                            end
                        end)
                    end
                else
                    Notification:Error("Unable to spawn truck and trailer")
                end
            end)
        else
            Notification:Error("Unable to spawn truck and trailer due to state")
        end
    end)

    eventHandlers["dropoff-trailer"] = AddEventHandler("Trucking:Client:DropoffTrailer", function()
        Progress:Progress({
            name = "dropoff_trailer",
            duration = 5000,
            label = _dropProgString,
            useWhileDead = false,
            canCancel = false,
            vehicle = false,
            animation = {
                anim = "type4",
            },
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableCombat = true,
            },
        }, function(cancelled)
            if not cancelled then
                local playerPed = PlayerPedId()
                local pedCoords = GetEntityCoords(playerPed)
    
                Callbacks:ServerCallback("Trucking:DropoffTrailer", { 
                    pedCoords = { x = pedCoords.x, y = pedCoords.y, z = pedCoords.z },
                }, function(success)
                    if success then
                        Notification:Success("Trailer dropped off successfully!")
                        _state = 4
                        PedInteraction:Remove("TruckingDropoff")
                        dropoffPedHandle = nil
                        RemoveBlip(dropoffBlip)
                        dropoffBlip = nil
                    else
                        Notification:Error("Unable to drop off trailer")
                    end
                end)
            end
        end)
    end)
    
    eventHandlers["complete-job"] = AddEventHandler("Trucking:Client:CompleteJob", function()
        Callbacks:ServerCallback("Trucking:CompleteJob", {}, function(success)
            if success then
                Notification:Success("Job completed successfully!")
                _state = 0
                _working = false
                isIllegal = false
                TriggerEvent("Trucking:Client:OffDuty")
            else
                Notification:Error("Unable to complete job")
            end
        end)
    end)

end)

AddEventHandler("Trucking:Client:StartJibbityJob", function(data)
    _jobData = data
    local joiner = _joiner
    local jType = data.type
    local jLevel = data.level

    Callbacks:ServerCallback("Trucking:StartJob", { joiner = joiner, type = jType, level = jLevel }, function(reject)
        if reject then
            _state = 1
            Citizen.CreateThread(function()
                while true do
                    if _state == 1 or _state == 2 then
                        Citizen.Wait(1000)
                        local playerPed = PlayerPedId()
                        local vehicle = GetVehiclePedIsIn(playerPed, false)
                        if vehicle and DoesEntityExist(vehicle) then
                            local isAttached = false
                            local retval, trailer = GetVehicleTrailerVehicle(vehicle)
                            if retval and DoesEntityExist(trailer) then
                                isAttached = true
                            end
                
                            if isAttached then
                                trailerCoords = GetEntityCoords(trailer)
                                TriggerServerEvent("Trucking:Server:TrailerHitched")
                                _state = 3
                                if trailerBlip ~= nil then
                                    RemoveBlip(trailerBlip)
                                    trailerBlip = nil
                                end
                                break
                            end
                        end
                    end
                end
            end)
        else
            Notification:Error("Unable to start job")
        end
    end)
end)

AddEventHandler("Trucking:Client:StartIllJibbity", function(data)
    _jobData = data
    local joiner = _joiner
    local jType = data.type
    local jLevel = data.level

    Callbacks:ServerCallback("Trucking:StartJob", { joiner = joiner, type = jType, level = jLevel }, function(reject)
        if reject then
            _state = 1
            Citizen.CreateThread(function()
                local isAttached = false
                while true do
                    Citizen.Wait(1000)
                    local playerPed = PlayerPedId()
                    local vehicle = GetVehiclePedIsIn(playerPed, false)
                    if vehicle and DoesEntityExist(vehicle) then
                        local retval, trailer = GetVehicleTrailerVehicle(vehicle)
                        if retval and DoesEntityExist(trailer) and not isAttached then
                            isAttached = true
                            TriggerServerEvent("Trucking:Server:TrailerHitched")
                            _state = 3
                            if trailerBlip ~= nil then
                                RemoveBlip(trailerBlip)
                                trailerBlip = nil
                            end
                        end
                    end

                    if _state == 3 then
                        local playerCoords = GetEntityCoords(playerPed)
                        local distance = #(playerCoords - vector3(dropoffPedCoords.x, dropoffPedCoords.y, dropoffPedCoords.z))
                        if distance <= 40 then
                            Callbacks:ServerCallback("Trucking:SpawnMfPeds", { coords = dropoffPedCoords }, function() end)
                            break
                        end
                    end
                end
            end)
        else
            Notification:Error("Unable to start job")
        end
    end)
end)

RegisterNetEvent("Trucking:Client:OffDuty", function(time)
    for k, v in pairs(eventHandlers) do
        RemoveEventHandler(v)
    end

    if _blip ~= nil then
        Blips:Remove("TruckingStart")
        RemoveBlip(_blip)
        _blip = nil
    end

    if dropoffPedHandle ~= nil then
        PedInteraction:Remove(dropoffPedHandle)
        dropoffPedHandle = nil
    end

    if trailerBlip ~= nil then
        RemoveBlip(trailerBlip)
        trailerBlip = nil
    end

    if dropoffBlip ~= nil then
        RemoveBlip(dropoffBlip)
        dropoffBlip = nil
    end

    eventHandlers = {}
    _joiner = nil
    _working = false
    _state = 0
    isTanker = false
    isIllegal = false
    allHostilesDead = false
    _jobData = nil
end)

Citizen.CreateThread(function()
    while _state == 3 do
        Citizen.Wait(100)
        if dropoffPedCoords then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - vector3(dropoffPedCoords.x, dropoffPedCoords.y, dropoffPedCoords.z))

            if distance <= 40 then
                Callbacks:ServerCallback("Trucking:SpawnMfPeds", { coords = dropoffPedCoords }, function() end)
                break
            end
        end
    end
end)