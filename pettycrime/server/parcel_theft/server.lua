local _working = false

local parcelLootTable = {
    standard = {
        { item = "earrings", amount = 1, chance = 30 },
        { item = "ring", amount = 1, chance = 30 },
        { item = "weed_joint", amount = 1, chance = 25 },
        { item = "bandage", amount = 1, chance = 14 },
        { item = "valuegoods", amount = 1, chance = 1 },
    },
    medium = {
        { item = "rolex", amount = math.random(1,2), chance = 20 },
        { item = "chain", amount = math.random(1,2), chance = 20 },
        { item = "ring", amount = math.random(1,2), chance = 20 },
        { item = "boombox", amount = 1, chance = 20 },
        { item = "house_art", amount = 1, chance = 18 },
        { item = "valuegoods", amount = 1, chance = 2 },
    },
    high = {
        { item = "rolex", amount = math.random(2,3), chance = 15 },
        { item = "earrings", amount = math.random(2,3), chance = 15 },
        { item = "ring", amount = math.random(2,3), chance = 15 },
        { item = "chain", amount = math.random(1,2), chance = 20 },
        { item = "boombox", amount = 1, chance = 10 },
        { item = "house_art", amount = 1, chance = 10 },
        { item = "microwave", amount = 1, chance = 10 },
        { item = "golfclubs", amount = 1, chance = 10 },
        { item = "valuegoods", amount = 1, chance = 5 },
    }
}

local _parcelTheftZones = {
    {
        coords = vector3(1127.498, -554.159, 56.809),
        radius = 450.0,
        locations = {
            vector4(1203.249, -557.837, 68.401, 271.117),
            vector4(1271.131, -682.850, 65.032, 107.985),
            vector4(1327.788, -535.931, 71.441, 345.123),
            vector4(1112.957, -390.746, 67.734, 246.025),
            vector4(1099.572, -437.891, 66.594, 181.022),
            vector4(1061.137, -378.566, 67.231, 47.019),
            vector4(1013.839, -468.318, 63.289, 218.482),
            vector4(943.918, -463.689, 60.396, 309.655),
            vector4(923.756, -524.829, 58.575, 208.253),
            vector4(920.254, -570.712, 57.366, 21.943),
        },
    },
    {
        coords = vector3(225.860, -1918.983, 24.085),
        radius = 450.0,
        locations = {
            vector4(192.307, -1883.245, 24.057, 325.555),
            vector4(148.909, -1904.139, 22.532, 161.455),
            vector4(54.357, -1873.310, 21.806, 330.447),
            vector4(29.534, -1854.295, 23.069, 224.617),
            vector4(72.384, -1939.015, 20.369, 141.244),
            vector4(144.171, -1969.996, 17.858, 26.592),
            vector4(269.978, -1917.328, 25.180, 237.739),
            vector4(294.864, -1973.164, 21.901, 48.454),
            vector4(317.166, -2043.266, 19.936, 150.568),
            vector4(364.733, -2064.628, 20.744, 238.584),
        },
    },
    {
        coords = vector3(-527.119, 662.067, 141.052),
        radius = 450.0,
        locations = {
            vector4(-494.711, 739.255, 162.031, 149.333),
            vector4(-559.203, 664.321, 144.455, 163.053),
            vector4(-662.451, 679.177, 152.911, 172.348),
            vector4(-477.022, 648.487, 143.387, 202.533),
            vector4(-353.532, 667.485, 168.070, 346.806),
            vector4(-308.187, 643.081, 175.131, 297.963),
            vector4(-519.070, 594.581, 119.837, 106.553),
            vector4(-406.937, 566.340, 123.606, 337.522),
            vector4(-580.462, 491.984, 107.903, 192.697),
            vector4(-704.190, 589.833, 140.962, 183.210),
        },
    },
}

AddEventHandler("PettyCrime:Server:Setup", function()
    Reputation:Create("ParcelTheft", "Parcel Theft", {
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

    Callbacks:RegisterServerCallback("Parcel:Server:GetZone", function(source, data, cb)
        local char = Fetch:CharacterSource(source)
        local randomIndex = math.random(1, #_parcelTheftZones)
        local zone = _parcelTheftZones[randomIndex]

        cb(zone)
    end)

    Callbacks:RegisterServerCallback("Parcel:Server:CollectParcel", function(source, data, cb)
        local src = source
        local char = Fetch:CharacterSource(src)

        if not char or not char:GetData("SID") then
            cb(false)
            return
        end

        Inventory:AddItem(char:GetData("SID"), "parcel_box", 1, {}, 1)

        local randomChance = math.random(1, 100)
        if randomChance <= 10 then
            Robbery:TriggerPDAlert(
                src,
                data.coords,
                "10-90",
                "Parcel Theft",
                {
                    icon = 843,
                    size = 0.9,
                    color = 3,
                    duration = (60 * 5),
                },
                {
                    icon = "box",
                    details = "Parcel Theft",
                }, 
                false,
                false
            )
        end
            
        cb(true)
    end)

    Callbacks:RegisterServerCallback("Parcel:Server:TurnInParcels", function(source, data, cb)
        local char = Fetch:CharacterSource(source)
        local playerSID = char:GetData("SID")

        if not char or not playerSID then cb(false) return end

        local parcels = Inventory.Items:GetCount(playerSID, 1, "parcel_box") or 0
        if parcels < 1 then
            cb(false)
            return
        end

        Inventory.Items:Remove(playerSID, 1, "parcel_box", parcels)

        local playerRep = Reputation:GetLevel(source, "ParcelTheft") or 0
        local selectedLootTable = nil

        if playerRep >= 0 and playerRep < 2 then
            selectedLootTable = parcelLootTable.standard
        elseif playerRep >= 2 and playerRep < 6 then
            selectedLootTable = parcelLootTable.medium
        elseif playerRep >= 6 then
            selectedLootTable = parcelLootTable.high
        end

        if selectedLootTable then
            for i = 1, parcels do
                local totalChance = 0
                for _, loot in pairs(selectedLootTable) do
                    totalChance = totalChance + loot.chance
                end

                local randomValue = math.random(1, totalChance)
                local currentChance = 0

                for _, loot in pairs(selectedLootTable) do
                    currentChance = currentChance + loot.chance
                    if randomValue <= currentChance then
                        Inventory:AddItem(playerSID, loot.item, loot.amount, {}, 1)
                        break
                    end
                end
            end
        end

        Reputation.Modify:Add(source, "ParcelTheft", 5 * parcels)

        cb(true)
    end)
end)