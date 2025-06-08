-- Trick or Treat Bitch --

local ped = nil
local visitedDoors = {}

AddEventHandler("Drugs:Client:Startup", function()
    for k, v in ipairs(_trickDoors) do
        Targeting.Zones:AddBox("trickortreat-" .. k, "candy-corn", v.coords, v.length, v.width, v.options, {
            {
                icon = "candy-corn",
                text = "Knock on Door",
                event = "Drugs:Client:TrickOrTreat",
                data = { id = k }
            },
        }, 3.0, true)
    end
end)

AddEventHandler("Drugs:Client:TrickOrTreat", function(data)
    local player = PlayerPedId()
    local doorId = data.id

    if visitedDoors[doorId] then
        Notification:Error("You greedy bitch!")
        return
    end

    visitedDoors[doorId] = true

    loadAnimDict("timetable@jimmy@doorknock@")
    TaskPlayAnim(player, "timetable@jimmy@doorknock@", "knockdoor_idle", 8.0, 8.0, -1, 3, 0, false, false, false)
    Wait(3000)
    spawnHalPed(doorId)
end)

function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end
end

function spawnHalPed(doorId)
    local hash = GetHashKey(_trickPeds[math.random(#_trickPeds)])

    if not HasModelLoaded(hash) then
        RequestModel(hash)
        Wait(10)
    end

    while not HasModelLoaded(hash) do
        Wait(10)
    end

    local playerPos = GetEntityCoords(PlayerPedId())
    local playerHeading = GetEntityHeading(PlayerPedId())
    local frontx = GetEntityForwardX(PlayerPedId())
    local spawnPos = vector3(playerPos.x + frontx, playerPos.y, playerPos.z - 1)

    ped = CreatePed(5, hash, spawnPos.x, spawnPos.y, spawnPos.z, playerHeading + 180, true, false)

    SetEntityAsMissionEntity(ped, true, true)
    local netId = NetworkGetNetworkIdFromEntity(ped)
    SetNetworkIdCanMigrate(netId, true)
    SetNetworkIdExistsOnAllMachines(netId, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    PlayPedAmbientSpeechNative(ped, "GENERIC_HI", "SPEECH_PARAMS_FORCE_NORMAL_CLEAR")
    TaskTurnPedToFaceEntity(PlayerPedId(), ped, 1000)
    TaskTurnPedToFaceEntity(ped, PlayerPedId(), 1000)
    Wait(1000)
    loadAnimDict("mp_safehouselost@")
    TaskPlayAnim(ped, "mp_safehouselost@", "package_dropoff", 8.0, 1.0, -1, 16, 0, 0, 0, 0)
    Wait(3000)

    -- Cleanup
    DeleteEntity(ped)
    TriggerServerEvent('Drugs:Server:TrickOrTreat', doorId)
    RemoveAnimDict("mp_safehouselost@")
    SetModelAsNoLongerNeeded(hash)
end


RegisterNetEvent("Drugs:Client:TrickBitch")
AddEventHandler("Drugs:Client:TrickBitch", function()
    local player = PlayerPedId()
    local tricks = {
        function()
            StartEntityFire(player)
            Citizen.Wait(3000)
            StopEntityFire(player)
        end,
        function()
            local coords = GetEntityCoords(player)
            ShootSingleBulletBetweenCoords(
                coords.x, coords.y, coords.z + 0.1,
                coords.x, coords.y, coords.z, 
                0, true, `WEAPON_TASER`, player, true, true, -1.0
            )
        end,
        function()
            SetPedToRagdoll(player, 3000, 3000, 0, false, false, false)
        end
    }

    local randomTrick = tricks[math.random(#tricks)]
    randomTrick()
end)
