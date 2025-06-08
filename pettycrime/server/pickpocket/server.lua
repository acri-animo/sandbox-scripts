local pedsRobbed = {}

local pickPocketLoot = {
    { item = "nothing", chance = 50, minAmount = 0, maxAmount = 0  },
    { item = "cash", chance = 40, minAmount = 15, maxAmount = 30 },
    { item = "meter_coins", chance = 30, minAmount = 2, maxAmount = 4 },
    { item = "goldcoins", chance = 30, minAmount = 2, maxAmount = 4 },
    { item = "earrings", chance = 10, minAmount = 1, maxAmount = 1 },
    { item = "watch", chance = 10, minAmount = 1, maxAmount = 1 },
    { item = "rolex", chance = 10, minAmount = 1, maxAmount = 1 },
    { item = "ring", chance = 10, minAmount = 1, maxAmount = 1 },
    { item = "chain", chance = 10, minAmount = 1, maxAmount = 1 },
}

local function getRandomLoot()
    local totalWeight = 0
    for _, loot in ipairs(pickPocketLoot) do
        totalWeight = totalWeight + loot.chance
    end
    
    local random = math.random(1, totalWeight)
    local currentWeight = 0
    
    for _, loot in ipairs(pickPocketLoot) do
        currentWeight = currentWeight + loot.chance
        if random <= currentWeight then
            return loot
        end
    end
end

local function getReputationMultiplier(repLevel)
    return 1.0 + (repLevel / 4)
end

AddEventHandler("PettyCrime:Server:Setup", function()
    Reputation:Create("PickPocket", "Pick Pocket", {
        { label = "Rank 1", value = 1000 },
        { label = "Rank 2", value = 2000 },
        { label = "Rank 3", value = 4000 },
        { label = "Rank 4", value = 8000 },
        { label = "Rank 5", value = 16000 },
        { label = "Rank 6", value = 32000 },
        { label = "Rank 7", value = 64000 },
        { label = "Rank 8", value = 128000 },
        { label = "Rank 9", value = 256000 },
        { label = "Rank 10", value = 500000 },
    }, false)

    Callbacks:RegisterServerCallback("PettyCrime:Server:PickPocket", function(source, data, cb)
        local char = Fetch:CharacterSource(source)
        local netId = data.netId

        if char == nil then
            return cb(false)
        end

        if pedsRobbed[netId] then
            return cb(false)
        end
        
        local ppRep = Reputation:GetLevel(source, "PickPocket") or 0
        local multiplier = getReputationMultiplier(ppRep)
        local loot = getRandomLoot()
        local baseAmount = math.random(loot.minAmount, loot.maxAmount)
        local finalAmount = math.floor(baseAmount * multiplier)

        if loot.item == "cash" then
            Wallet:Modify(source, finalAmount)
            Reputation.Modify:Add(source, "PickPocket", 50)
        elseif loot.item == "nothing" then
            Execute:Client(source, "Notification", "Error", "You found nothing!", 6000)
        else
            Inventory:AddItem(char:GetData("SID"), loot.item, finalAmount, {}, 1)
            Reputation.Modify:Add(source, "PickPocket", 50)
        end
        
        pedsRobbed[netId] = true

        cb(true)
    end)
end)

RegisterNetEvent("PettyCrime:Server:PickPocket:AlertPolice", function(coords)
    local src = source
    Robbery:TriggerPDAlert(src, coords, "10-31", "Suspicious Activity", {
        icon = 843,
        size = 0.9,
        color = 3,
        duration = (60 * 5),
    })
end)