local currentRobberyData = nil
local lootedVehicles = {}
local smashInProgress = false
local _currentZone = nil
local _blip = nil
local spawnedProps = {}

local packageProps = {
    "prop_cs_duffel_01",
    "prop_cs_duffel_01b",
    "prop_cs_shopping_bag",
    "hei_prop_hei_paper_bag",
    "prop_carrier_bag_01",
    "prop_beachbag_03",
    "prop_beachbag_06",
}

local function startSmashNGrabThread(zone)
    if not smashInProgress then
        return
    end

    Citizen.CreateThread(function()
        while smashInProgress do
            if _currentZone ~= nil then
                Citizen.Wait(0)
    
                local dist = #(
                    vector3(LocalPlayer.state.myPos.x, LocalPlayer.state.myPos.y, LocalPlayer.state.myPos.z) 
                    - vector3(zone.coords.x, zone.coords.y, zone.coords.z)
                )

                if dist <= (zone.radius / 2) then
                    LocalPlayer.state.inSmashNGrabZone = true
                else
                    LocalPlayer.state.inSmashNGrabZone = false
                end
            end
            Citizen.Wait(1000)
        end
    end)
end

local function stopSmashNGrabThread()
    if _blip ~= nil then
        RemoveBlip(_blip)
        _blip = nil
    end

    -- Clean up spawned props
    for vehicle, prop in pairs(spawnedProps) do
        if DoesEntityExist(prop) then
            DeleteEntity(prop)
        end
    end
    spawnedProps = {}

    if smashInProgress then
        smashInProgress = false
        _currentZone = nil
        LocalPlayer.state.inSmashNGrabZone = false
    end
end

local function createBoxCars(zone)
    if not zone or not zone.coords then return end

    local cars = lib.getNearbyVehicles(zone.coords, zone.radius, false)

    print("Cars in zone: ", #cars)

    for _, car in ipairs(cars) do
        local vehicle = car.entity
        if DoesEntityExist(vehicle) and not IsVehicleEngineOn(vehicle) then
            if not lootedVehicles[vehicle] and not spawnedProps[vehicle] then
                if math.random(1, 100) <= 50 then

                    local propModel = packageProps[math.random(1, #packageProps)]
                    RequestModel(propModel)
                    while not HasModelLoaded(propModel) do
                        Citizen.Wait(10)
                    end

                    local boneIndex = GetEntityBoneIndexByName(vehicle, "seat_pside_f")
                    if boneIndex ~= -1 then

                        local bonePos = GetWorldPositionOfEntityBone(vehicle, boneIndex)
                        local propPos = vector3(bonePos.x, bonePos.y, bonePos.z + 0.2)
                        local propRot = vector3(0.0, 0.0, 0.0)

                        local prop = CreateObject(GetHashKey(propModel), propPos.x, propPos.y, propPos.z, false, false, false)
                        if DoesEntityExist(prop) then
                            AttachEntityToEntity(prop, vehicle, boneIndex, 0.0, 0.0, 0.2, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                            spawnedProps[vehicle] = prop
                            print("Spawned prop " .. propModel .. " on vehicle " .. vehicle)
                        end

                        SetModelAsNoLongerNeeded(propModel)
                    else
                        print("Vehicle " .. vehicle .. " has no seat_pside_f bone")
                    end
                end
            end
        end
    end
end

AddEventHandler("PettyCrime:Client:Setup", function()
    PedInteraction:Add("SmashNGrabPed", `a_m_o_tramp_01`, vector3(887.022, -171.287, 76.110), 151.010, 25.0, {
        {
            icon = "hands",
            text = "Smash and Grab",
            event = "SmashNGrab:Client:InitializeZone",
            data = {},
        },
        {
			icon = "list-timeline",
			text = "View Current Requests",
			event = "Laptop:Client:LSUnderground:Chopping:GetPublicList",
			rep = { id = "CarRobbery", level = 3 },
		},
    }, 'user-hoodie', 'WORLD_HUMAN_SMOKING')
end)

AddEventHandler("SmashNGrab:Client:InitializeZone", function(data)
    if smashInProgress then
        Notification:Error("You already have a location to hit...")
        return
    end

    Callbacks:ServerCallback("PettyCrime:SmashNGrab:GetZone", {}, function(zone)
        if not zone or not zone.coords then
            Notification:Error("Invalid zone data.")
            return
        end

        _currentZone = zone
        smashInProgress = true

        _deadline = GetGameTimer() + (10 * 60 * 1000) -- 10 minutes from now
        Notification:Success("I know a good spot but you have to be quick. You have 5 minutes.")

        _blip = AddBlipForRadius(zone.coords.x, zone.coords.y, zone.coords.z, (zone.radius / 2) + 0.0)
        SetBlipColour(_blip, 3)
        SetBlipAlpha(_blip, 95)

        createBoxCars(zone)
        startSmashNGrabThread(zone)
    end)
end)

AddEventHandler("SmashNGrab:Client:LootVehicle", function(data)
    if not data or not data.entity then
        Notification:Error("Invalid vehicle data.")
        return
    end

    if not LocalPlayer.state.inSmashNGrabZone then return end

    if _deadline and GetGameTimer() > _deadline then
        Notification:Error("Time's up! The Smash and Grab opportunity has expired.")
        stopSmashNGrabThread()
        return
    end

    local entity = data.entity

    if lootedVehicles[entity] then
        Notification:Error("This vehicle has already been looted.")
        return
    end

    local policeCount = GlobalState["Duty:police"] or 0
    -- local policeCount = 1

    if policeCount < 1 then
        Notification:Error("There's nobody to catch you...")
        return
    end

    local windowBroken = false

    for windowIndex = 0, 3 do
        if not IsVehicleWindowIntact(entity, windowIndex) then
            windowBroken = true
            break
        end
    end

    if not windowBroken then
        Notification:Error("You need to break a window first.")
        return
    end

    currentRobberyData = { entity = entity }
    local chance = math.random(1, 100)
    if chance <= 40 then
        TriggerServerEvent("SmashNGrab:Server:AlertPolice", GetEntityCoords(entity))
    end

    Progress:Progress({
        name = "smash_n_grab",
        duration = math.random(5000, 10000),
        label = "Grabbing Items...",
        useWhileDead = false,
        canCancel = true,
        ignoreModifier = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            anim = "mechanic",
        },
    }, function(cancelled)
        if not cancelled then
            Callbacks:ServerCallback("PettyCrime:SmashNGrab:CollectLoot", currentRobberyData, function(success)
                if success then
                    -- Remove the prop when looted
                    if spawnedProps[entity] and DoesEntityExist(spawnedProps[entity]) then
                        DeleteEntity(spawnedProps[entity])
                        spawnedProps[entity] = nil
                    end
                    stopSmashNGrabThread()
                    lootedVehicles[entity] = true
                    currentRobberyData = nil
                    _deadline = nil
                    Notification:Success("You successfully looted the vehicle.")
                else
                    Notification:Error("Failed to loot the vehicle.")
                end
            end)
        end
    end)
end)