function loadAnimDict(pDict)
	while not HasAnimDictLoaded(pDict) do
		RequestAnimDict(pDict)
		Citizen.Wait(5)
	end
end

AddEventHandler("Drugs:Client:ShowSellMenu", function(entityData, data)
    local ped = entityData.entity
    local playerPed = LocalPlayer.state.ped
    local netId = NetworkGetNetworkIdFromEntity(ped)
    local repLevel = Reputation:GetLevel("CornerDealing") or 0
    local maxRep = 20
    local denyChance = math.min(repLevel * (_cornerSelling.baseDenyChance / maxRep), _cornerSelling.baseDenyChance)
    local adjDenyChance = _cornerSelling.baseDenyChance - denyChance

    local chance = math.random(100)
    if chance <= adjDenyChance then
        local denyMessage = _cornerSelling.denyNotis[math.random(1, #_cornerSelling.denyNotis)]
        local pedSpeech = _cornerSelling.pedDenySpeech[math.random(1, #_cornerSelling.pedDenySpeech)]
        Notification:Error(denyMessage)
        PlayAmbientSpeech1(ped, pedSpeech, 'Speech_Params_force')
        ClearPedTasksImmediately(ped)
        ClearPedTasksImmediately(playerPed)
        return
    end

    Callbacks:ServerCallback("Drugs:GetSellMenu", { netId = netId }, function(data)
        if data ~= nil and #data > 0 then
            ListMenu:Show({
                main = {
                    label = "Drug Selling Menu",
                    items = data,
                },
            })
        else
            Notification:Error("You don't have anything to sell idiot...")
            ClearPedTasks(ped)
            ClearPedTasks(playerPed)
        end
    end)
end)

AddEventHandler("Drugs:Client:SellDrugs", function(data)
    local ped = NetworkGetEntityFromNetworkId(data.netId)
    local playerPed = PlayerPedId()

    if not DoesEntityExist(ped) then
        Notification:Error("The ped fucking poofed or glitched")
        return
    end

    TaskTurnPedToFaceEntity(ped, playerPed, 1000)
    TaskTurnPedToFaceEntity(playerPed, ped, 1000)
    Citizen.Wait(1000)

    Callbacks:ServerCallback("Drugs:CompleteSale", {
        item = data.item,
        amount = data.amount,
    }, function(res)
        if res then
            local ent = Entity(ped)
            Entity(ped).state:set("drugSell", true, true)
            local pdalert = math.random(100)
            if pdalert >= 60 then
                EmergencyAlerts:CreateIfReported(100.0, "oxysale", true)
            end

            if not IsPedStopped(ent) then
                ClearPedTasksImmediately(ent)
            end

            loadAnimDict("mp_safehouselost@")
	        ClearPedTasks(ent)
	        TaskPlayAnim(ent, "mp_safehouselost@", "package_dropoff", 8.0, -8.0, -1, 0, 0, false, false, false)
            PlayAmbientSpeech1(ent, 'GENERIC_THANKS', 'Speech_Params_Force')
            Animations.Emotes:Play("handoff", false, 3000, true, true)
            RemoveAnimDict("mp_safehouselost@")
        else
            ClearPedTasksImmediately(ent)
            ClearPedTasksImmediately(playerPed)
        end
    end)
end)