local robbedMeters = {}
local COOLDOWN_SECONDS = 60 * 5

AddEventHandler("PettyCrime:Server:Setup", function()
    Reputation:Create("MeterRobbery", "Meter Robbery", {
        { label = "Rank 1", value = 1000 },
        { label = "Rank 2", value = 2000 },
        { label = "Rank 3", value = 4000 },
        { label = "Rank 4", value = 10000 },
        { label = "Rank 5", value = 16000 },
        { label = "Rank 6", value = 25000 },
        { label = "Rank 7", value = 35000 },
        { label = "Rank 8", value = 50000 },
        { label = "Rank 9", value = 75000 },
        { label = "Rank 10", value = 100000 },
    }, false)

    Callbacks:RegisterServerCallback("PettyCrime:ParkingMeter:CollectCoins", function(source, data, cb)
        local char = Fetch:CharacterSource(source)
        local meterKey = data.netId

        if not char then
            cb(false)
            return
        end

        if GlobalState["RobberiesDisabled"] then
            Execute:Client(
                source,
                "Notification",
                "Error",
                "Temporarily Disabled, Please See City Announcements",
                6000
            )
            cb(false)
            return
        end

        local currentTime = os.time()
        if not robbedMeters[meterKey] or (currentTime - robbedMeters[meterKey].timestamp) >= COOLDOWN_SECONDS then
            Inventory:AddItem(char:GetData("SID"), "meter_coins", math.random(3, 6), {}, 1)
            Reputation.Modify:Add(source, "MeterRobbery", math.random(50, 60))

            -- Store cooldown data
            robbedMeters[meterKey] = { timestamp = currentTime }
            cb(true)
        else
            cb(false)
        end
    end)
end)

RegisterNetEvent("PettyCrime:Server:ParkingMeter:AlertPolice", function(coords)
    local src = source
    Robbery:TriggerPDAlert(src, coords, "10-31", "Suspicious Activity", {
        icon = 843,
        size = 0.9,
        color = 3,
        duration = (60 * 5),
    })
end)

RegisterNetEvent("PettyCrime:Server:ExchangeMeterCoins", function(meterRep)
    local src = source
    local char = Fetch:CharacterSource(src)

    if not char then
        TriggerClientEvent("Notification:Error", src, "Character data could not be retrieved.")
        return
    end

    local coins = Inventory.Items:GetCount(char:GetData("SID"), 1, "meter_coins") or 0

    if coins and coins > 0 then
        local minMultiplier = 1.0
        local maxMultiplier = 1.0
        local chanceForMax = 0

        if meterRep >= 4 and meterRep < 5 then
            minMultiplier = 1.0
            maxMultiplier = 2.0
            chanceForMax = 20
        elseif meterRep >= 5 and meterRep < 6 then
            minMultiplier = 1.0
            maxMultiplier = 2.0
            chanceForMax = 40
        elseif meterRep >= 6 and meterRep < 7 then
            minMultiplier = 1.0
            maxMultiplier = 3.0
            chanceForMax = 30
        elseif meterRep >= 7 and meterRep < 8 then
            minMultiplier = 1.0
            maxMultiplier = 3.0
            chanceForMax = 40
        elseif meterRep >= 8 and meterRep < 9 then
            minMultiplier = 2.0
            maxMultiplier = 3.0
            chanceForMax = 30
        elseif meterRep >= 9 and meterRep < 10 then
            minMultiplier = 2.0
            maxMultiplier = 3.0
            chanceForMax = 40
        elseif meterRep >= 10 then
            minMultiplier = 2.0
            maxMultiplier = 4.0
            chanceForMax = 30
        end

        local finalMultiplier = minMultiplier
        if math.random(1, 100) <= chanceForMax then
            finalMultiplier = maxMultiplier
        end

        Inventory.Items:Remove(char:GetData("SID"), 1, "meter_coins", coins)
        local moneyRollReward = math.floor(coins * finalMultiplier)
        Inventory:AddItem(char:GetData("SID"), "moneyroll", moneyRollReward, {}, 1)
        Execute:Client(
            src,
            "Notification",
            "Success",
            "You exchanged " .. coins .. " coins for " .. moneyRollReward .. " money rolls.",
            6000
        )
    else
        Execute:Client(
            src,
            "Notification",
            "Error",
            "You don't have any coins to exchange.",
            6000
        )
    end
end)