local robbedMeters = {}
local COOLDOWN_MILLISECONDS = 300 * 1000

local meterObjects = {
    `prop_parkingpay`,
    `prop_parknmeter_01`,
    `prop_parknmeter_02`,
}

AddEventHandler("PettyCrime:Client:Setup", function()
    PedInteraction:Add(
        "MeterCoinPed",
        GetHashKey("s_m_y_dealer_01"),
        vector3(414.507, 343.906, 101.421),
        343.011,
        25.0,
        {
            {
                icon = "users",
                text = "Got coins?",
                event = "PettyCrime:Client:ExchangeCoins",
                isEnabled = function()
                    local repLevel = Reputation:GetLevel("MeterRobbery")
                    return repLevel and repLevel >= 3
                end,
            },
        }
    )

    for k, v in pairs(meterObjects) do
        Targeting:AddObject(v, "user-secret", {
            {
                text = "Break open parking meter",
                icon = "dollar-sign",
                event = "PettyCrime:Client:StartMeterRobbery",
                data = {},
                isEnabled = function(data, entity)
                    if not DoesEntityExist(entity.entity) or LocalPlayer.state.MeterRobbery or HasObjectBeenBroken(entity.entity) then
                        return false
                    end

                    if not NetworkGetEntityIsNetworked(entity.entity) then
                        NetworkRegisterEntityAsNetworked(entity.entity)
                    end

                    local netId = NetworkGetNetworkIdFromEntity(entity.entity)
                    return netId ~= 0 and not (robbedMeters[netId] and GetGameTimer() < robbedMeters[netId].cooldownUntil)
                end,
            }
        }, 3.0)
    end
end)

function DoRobMeterProgress(label, duration, anim, canCancel, cb)
    Progress:Progress({
        name = "robbing_meter",
        duration = duration,
        label = label,
        useWhileDead = false,
        canCancel = canCancel,
        ignoreModifier = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            anim = anim,
        },
    }, function(status)
        if cb then
            cb(status)
        end
    end)
end

RegisterNetEvent("PettyCrime:Client:StartMeterRobbery", function(entity, data)
    if not entity or not DoesEntityExist(entity.entity) then
        Notification:Error("Invalid parking meter.")
        return
    end

    if not Inventory.Check.Player:HasItem("screwdriver", 1) then
        Notification:Error("You are missing something.")
        return
    end

    local player = LocalPlayer.state.ped
    local playerCoords = GetEntityCoords(player)

    if not NetworkGetEntityIsNetworked(entity.entity) then
        NetworkRegisterEntityAsNetworked(entity.entity)
    end

    local meterNetId = NetworkGetNetworkIdFromEntity(entity.entity)
    if robbedMeters[meterNetId] and GetGameTimer() < robbedMeters[meterNetId].cooldownUntil then
        Notification:Error("This meter was recently tampered with.")
        return
    end

    if math.random(1, 100) >= 60 then
        Citizen.SetTimeout(5000, function()
            TriggerServerEvent("PettyCrime:Server:ParkingMeter:AlertPolice", playerCoords)
        end)
    end

    DoRobMeterProgress(
        "Breaking into parking meter",
        (math.random(25, 30) * 1000),
        "parkingmeter",
        true,
        function(status)
            if status then return end

            Minigame.Play:RoundSkillbar(2.0, 3, {
                onSuccess = function(data)
                    while LocalPlayer.state.doingAction do
                        Citizen.Wait(100)
                    end

                    DoRobMeterProgress(
                        "Collecting coins",
                        (math.random(12, 15) * 1000),
                        "parkingmeter",
                        false,
                        function(status)
                            if status then return end
                            
                            Callbacks:ServerCallback("PettyCrime:ParkingMeter:CollectCoins", { netId = meterNetId }, function(success)
                                if success then
                                    robbedMeters[meterNetId] = { cooldownUntil = GetGameTimer() + COOLDOWN_MILLISECONDS }
                                    Notification:Success("You have successfully robbed the parking meter.")
                                else
                                    robbedMeters[meterNetId] = { cooldownUntil = GetGameTimer() + COOLDOWN_MILLISECONDS }
                                    Notification:Error("This meter was recently tampered with.")
                                end
                            end)
                        end
                    )
                end,
                onFail = function(data)
                    while LocalPlayer.state.doingAction do
                        Citizen.Wait(100)
                    end
                    TriggerServerEvent("PettyCrime:Server:ParkingMeter:AlertPolice", playerCoords)
                end
            }, {
                playableWhileDead = false,
                animation = {
                    anim = "parkingmeter",
                },
            }, {})
        end
    )
end)

RegisterNetEvent("PettyCrime:Client:ExchangeCoins", function()
    local meterRep = Reputation:GetLevel("MeterRobbery")
    TriggerServerEvent("PettyCrime:Server:ExchangeMeterCoins", meterRep)
end)