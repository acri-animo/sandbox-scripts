local lootedVehicles = {}

local unifiedLootTable = {
    { tier = 1, minLevel = 0, maxLevel = 2, loot = {
        { item = "rolex", amount = 1, chance = 30 },
        { item = "meter_coins", amount = math.random(1,2), chance = 50 },
        { item = "chain", amount = 1, chance = 30 },
        { item = "bandage", amount = math.random(1,2), chance = 50 },
        { item = "ring", amount = 1, chance = 50 },
    }},
    { tier = 2, minLevel = 3, maxLevel = 6, loot = {
        { item = "rolex", amount = math.random(1,2), chance = 50 },
        { item = "earrings", amount = 2, chance = 60 },
        { item = "meter_coins", amount = math.random(2,3), chance = 50 },
        { item = "ring", amount = math.random(1,2), chance = 50 },
        { item = "bandage", amount = math.random(3,5), chance = 50 },
    }},
    { tier = 3, minLevel = 7, maxLevel = 10, loot = {
        { item = "diamond", amount = 1, chance = 10 },
        { item = "valuegoods", amount = 1, chance = 1 },
        { item = "meter_coins", amount = math.random(2,4), chance = 50 },
        { item = "rolex", amount = math.random(2,3), chance = 60 },
        { item = "earrings", amount = 2, chance = 70 },
        { item = "ring", amount = 3, chance = 60 },
        { item = "bandage", amount = math.random(5,7), chance = 50 },
    }},
}

local _smashNGrabZones = {
    { coords = vector3(-1181.219, -742.152, 19.969), radius = 450.0 },
    { coords = vector3(-1142.696, -212.923, 37.946), radius = 450.0 },
    { coords = vector3(-173.884, 211.549, 88.876), radius = 450.0 },
    { coords = vector3(955.016, -1506.384, 30.986), radius = 450.0 },
    { coords = vector3(1723.943, -1587.205, 112.565), radius = 450.0 },
    { coords = vector3(411.185, -2067.237, 21.462), radius = 450.0 },
}

AddEventHandler("PettyCrime:Server:Setup", function()
    Reputation:Create("CarRobbery", "Smash N Grab", {
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

    Callbacks:RegisterServerCallback("PettyCrime:SmashNGrab:GetZone", function(source, data, cb)
        local char = Fetch:CharacterSource(source)
        local randomIndex = math.random(1, #_smashNGrabZones)
        local zone = _smashNGrabZones[randomIndex]

        cb(zone)
    end)

    Callbacks:RegisterServerCallback("PettyCrime:SmashNGrab:CollectLoot", function(source, data, cb)
        if not data or not data.entity then
            cb(false)
            return
        end

        local src = source
        local entity = data.entity

        if lootedVehicles[entity] then
            Execute:Client(src, "Notification", "Error", "Vehicle has already been looted.", 6000)
            cb(false)
            return
        end

        lootedVehicles[entity] = true
        
        local char = Fetch:CharacterSource(src)
        local playerRepLevel = Reputation:GetLevel(source, "CarRobbery") or 0

        local selectedLootTable = nil
        for _, tierData in ipairs(unifiedLootTable) do
            if playerRepLevel >= tierData.minLevel and playerRepLevel <= tierData.maxLevel then
                selectedLootTable = tierData.loot
                break
            end
        end

        if selectedLootTable then
            for _, loot in pairs(selectedLootTable) do
                if math.random(1, 100) <= loot.chance then
                    Inventory:AddItem(char:GetData("SID"), loot.item, loot.amount, {}, 1)
                end
            end
        end

        Vehicles:Delete(entity, function() end)

        Reputation.Modify:Add(src, "CarRobbery", 50)

        cb(true)
    end)
end)

RegisterNetEvent("SmashNGrab:Server:AlertPolice", function(coords)
    local src = source
    Robbery:TriggerPDAlert(src, coords, "10-90", "Vehice Robbery", {
        icon = 843,
        size = 0.9,
        color = 3,
        duration = (60 * 5),
    })
end)