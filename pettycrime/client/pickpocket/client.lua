local pickPocketPed = nil
local pedsHit = {}

AddEventHandler("PettyCrime:Client:AttemptPickPocket", function(entityData, data)
    pickPocketPed = entityData.entity
    local player = LocalPlayer.state.ped
    local pedState = Entity(pickPocketPed).state

    if pedState.pickingPocket then
        return
    end

    if pedsHit[pickPocketPed] then
        Notification:Error("You have already pickpocketed this local!")
        return
    end

    pedState.pickingPocket = true
    
    local success = exports.bl_ui:Progress(3, 60)

    if success then
        TriggerEvent("PettyCrime:Client:PickPocket")
    else
        TriggerEvent("PettyCrime:Client:PickPocketFail")
    end
end)

AddEventHandler("PettyCrime:Client:PickPocket", function()
    local pedNetId = NetworkGetNetworkIdFromEntity(pickPocketPed)
    Callbacks:ServerCallback("PettyCrime:Server:PickPocket", { netId = pedNetId }, function(success)
        if success then
            local player = LocalPlayer.state.ped
            ClearPedTasks(player)
            pedsHit[pickPocketPed] = true
            pickPocketPed = nil
        end
    end)
end)

AddEventHandler("PettyCrime:Client:PickPocketFail", function()
    local player = LocalPlayer.state.ped
    local pedState = Entity(pickPocketPed).state
    local coords = GetEntityCoords(player)

    FreezeEntityPosition(pickPocketPed, false)
    ClearPedTasks(pickPocketPed)
    ClearPedTasks(player)

    local chance = math.random(100)

    if chance <= 30 then
        TriggerServerEvent("PettyCrime:Server:PickPocket:AlertPolice", coords)
    end

    -- Make ped hostile and attack player
    PlayPedAmbientSpeechNative(pickPocketPed, "GENERIC_INSULT_HIGH", "SPEECH_PARAMS_FORCE")
    SetPedCombatAttributes(pickPocketPed, 46, true)
    SetPedCombatAttributes(pickPocketPed, 5, true)
    SetPedFleeAttributes(pickPocketPed, 0, false)
    SetPedCombatAbility(pickPocketPed, 100)
    SetPedCombatRange(pickPocketPed, 2)
    SetPedCombatMovement(pickPocketPed, 2)
    TaskCombatPed(pickPocketPed, player, 0, 16)

    pickPocketPed = nil

    Notification:Error("You failed to pickpocket the local!")
end)