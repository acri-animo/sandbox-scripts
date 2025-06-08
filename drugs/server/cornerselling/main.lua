local _storePedEntity = {}

AddEventHandler("Drugs:Server:Startup", function()
    Reputation:Create("CornerDealing", "CornerDealing", {
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
    
    Callbacks:RegisterServerCallback("Drugs:GetSellMenu", function(source, data, cb)
        local char = Fetch:CharacterSource(source)
        local SID = char and char:GetData("SID")
        
        if not char then 
            cb(false) 
            return 
        end
    
        local items = {}
        local drugRep = Reputation:GetLevel(source, "CornerDealing") or 0
        local multiplier = 1.0 + (drugRep * _cornerSelling.repMultiplier)
    
        local weedCount = Inventory.Items:GetCount(SID, 1, "weed_baggy")
        if weedCount > 0 then
            local weedAmount = math.floor(_cornerSelling.baseWeed * multiplier)
            table.insert(items, {
                label = "Sell Weed",
                description = "Requires " .. weedAmount .."x Baggy of Weed",
                event = "Drugs:Client:SellDrugs",
                data = {
                    item = "weed_baggy",
                    amount = weedAmount,
                    netId = data.netId,
                },
            })
        end
    
        local oxyCount = Inventory.Items:GetCount(SID, 1, "oxy")
        if oxyCount > 0 then
            local oxyAmount = math.floor(_cornerSelling.baseOxy * multiplier)
            table.insert(items, {
                label = "Sell Oxy",
                description = "Requires " .. oxyAmount .."x Oxy",
                event = "Drugs:Client:SellDrugs",
                data = {
                    item = "oxy",
                    amount = oxyAmount,
                    netId = data.netId
                },
            })
        end
    
        local methCount = Inventory.Items:GetCount(SID, 1, "meth_bag")
        if methCount > 0 then
            table.insert(items, {
                label = "Sell Meth",
                description = "Requires 1x Bag of Meth",
                event = "Drugs:Client:SellDrugs",
                data = {
                    item = "meth_bag",
                    amount = 1,
                    netId = data.netId
                },
            })
        end
    
        local cokeCount = Inventory.Items:GetCount(SID, 1, "coke_bag")
        if cokeCount > 0 then
            table.insert(items, {
                label = "Sell Cocaine",
                description = "Requires 1x Bag of Coke",
                event = "Drugs:Client:SellDrugs",
                data = {
                    item = "coke_bag",
                    amount = 1,
                    netId = data.netId
                },
            })
        end

        local moonshineCount = Inventory.Items:GetCount(SID, 1, "moonshine")
        if moonshineCount > 0 then
            table.insert(items, {
                label = "Sell Moonshine",
                description = "Requires 1x Moonshine",
                event = "Drugs:Client:SellDrugs",
                data = {
                    item = "moonshine",
                    amount = 1,
                    netId = data.netId
                },
            })
        end
    
        cb(items)
    end)

    Callbacks:RegisterServerCallback("Drugs:CompleteSale", function(source, data, cb)
        local char = Fetch:CharacterSource(source)
    
        if not char then cb(false) return end
    
        local SID = char:GetData("SID")
        local amount = data.amount or 0
        local repLevel = Reputation:GetLevel(source, "CornerDealing") or 0
        
        local copsOnDuty = GlobalState["Duty:police"] or 0
        local multiplier = 1.0
        local giveRep = false
    
        if copsOnDuty >= 1 then
            multiplier = 1.0 + (repLevel * _cornerSelling.moneyMultiplier)
            giveRep = true
        end
    
        local baseRollChance = _cornerSelling.chanceForRolls
        local adjRollChance = baseRollChance - (repLevel * 5)
        adjRollChance = math.max(adjRollChance, 0)
        local chance = math.random(100)
    
        local repTable = {
            weed_baggy = 25,
            oxy = 30,
            meth_bag = 40,
            coke_bag = 50,
            moonshine = 100,
        }

        local repAmount = (repTable[data.item] or 0) * amount
        print(repAmount)
        local cashAdd = 0
    
        if data.item == "meth_bag" or data.item == "coke_bag" or data.item == "moonshine" then
            local slot = Inventory.Items:GetFirst(SID, data.item, 1)
            if not Inventory.Items:RemoveId(SID, 1, slot) then
                cb(false)
                return
            end
    
            if data.item == "meth_bag" then
                cashAdd = (_cornerSelling.baseMethPayment * multiplier) * (slot.Quality / 100)
                Wallet:Modify(source, cashAdd)
            elseif data.item == "coke_bag" then
                cashAdd = (_cornerSelling.baseCokePayment * multiplier) * (slot.Quality / 100)
                Wallet:Modify(source, cashAdd)
            elseif data.item == "moonshine" then
                cashAdd = (_cornerSelling.baseMoonshinePayment * multiplier) * (slot.Quality / 100)
                Wallet:Modify(source, cashAdd)
            end
        elseif data.item == "weed_baggy" or data.item == "oxy" then
            local itemCount = Inventory.Items:GetCount(SID, 1, data.item) or 0
            if itemCount < amount then
                Execute:Client(source, "Notification", "Error", "You tried to scam me, fuck off!", 3000)
                cb(false)
                return
            end
    
            if not Inventory.Items:Remove(SID, 1, data.item, amount) then
                cb(false)
                return
            end
    
            if data.item == "weed_baggy" then
                if chance <= adjRollChance then
                    local weedRollAmount = math.floor(_cornerSelling.baseWeedRolls * amount * multiplier)
                    Inventory:AddItem(SID, "moneyroll", weedRollAmount, {}, 1)
                else
                    cashAdd = math.floor(_cornerSelling.baseWeedPayment * amount * multiplier)
                    Wallet:Modify(source, cashAdd)
                end
            elseif data.item == "oxy" then
                if chance <= adjRollChance then
                    local oxyRollAmount = math.floor(_cornerSelling.baseOxyRolls * amount * multiplier)
                    Inventory:AddItem(SID, "moneyroll", oxyRollAmount, {}, 1)
                else
                    cashAdd = math.floor(_cornerSelling.baseOxyPayment * amount * multiplier)
                    Wallet:Modify(source, cashAdd)
                end
            end
        end
    
        if giveRep then
            Reputation.Modify:Add(source, "CornerDealing", repAmount)
        end
    
        cb(true)
    end)    
end)