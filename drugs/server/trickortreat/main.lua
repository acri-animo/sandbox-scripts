local hitDoors = {}

local candyItems = {
    { item = "candy_corn", minAmount = 1, maxAmount = 3 },
    { item = "lollipop", minAmount = 1, maxAmount = 2 },
    { item = "gummy_worms", minAmount = 1, maxAmount = 3 },
    { item = "sour_gobbles", minAmount = 1, maxAmount = 1 },
    { item = "fruit_zaps", minAmount = 1, maxAmount = 1 },
    { item = "choco_cups", minAmount = 1, maxAmount = 1 },
    { item = "pretzels", minAmount = 1, maxAmount = 1 },
}

local bonusItems = {
    { item = "orange_gummy", minAmount = 1, maxAmount = 1 },
    { item = "apple_gummy", minAmount = 1, maxAmount = 1 },
    { item = "grape_gummy", minAmount = 1, maxAmount = 1 },
    { item = "blueberry_gummy", minAmount = 1, maxAmount = 1 },
}

local function getRandomItem(items)
    return items[math.random(#items)]
end

RegisterNetEvent("Drugs:Server:TrickOrTreat")
AddEventHandler("Drugs:Server:TrickOrTreat", function(doorId)
    local source = source
    local char = Fetch:CharacterSource(source)
    local SID = char:GetData("SID")

    if not char then return end

    if not hitDoors[source] then
        hitDoors[source] = {}
    end

    if hitDoors[source][doorId] then
        Execute:Client(source, "Notification", "Error", "You greedy bitch!")
        return
    end

    hitDoors[source][doorId] = true

    local chance = math.random(1, 100)

    if chance >= 20 then
        local candy = getRandomItem(candyItems)
        local amount = math.random(candy.minAmount, candy.maxAmount)
        Inventory:AddItem(SID, candy.item, amount, {}, 1)

        if math.random(1, 100) <= 25 then
            local bonus = getRandomItem(bonusItems)
            Inventory:AddItem(SID, bonus.item, 1, {}, 1)
        end

        Execute:Client(source, "Notification", "Success", "Happy Halloween lumen!")
    else
        Execute:Client(source, "Notification", "Error", "You got tricked bitch!")
        TriggerClientEvent('Drugs:Client:TrickBitch', source)
    end
end)
