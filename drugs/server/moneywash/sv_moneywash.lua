--[[AddEventHandler("Drugs:Server:Startup", function()
    Reputation:Create("Moneywash", "Money Laundering", {
        { label = "Rank 1", value = 1500 },
        { label = "Rank 2", value = 2500 },
        { label = "Rank 3", value = 3500 },
        { label = "Rank 4", value = 5000 },
        { label = "Rank 5", value = 7000 },
        { label = "Rank 6", value = 9000 },
        { label = "Rank 7", value = 12000 },
        { label = "Rank 8", value = 15000 },
        { label = "Rank 9", value = 18000 },
        { label = "Rank 10", value = 22000 },
    }, false)
end)]]

RegisterServerEvent('lumen:server:giveMwItem')
AddEventHandler('lumen:server:giveMwItem', function(data)
    local source = source
    local char = Fetch:CharacterSource(source)
    local SID = char:GetData("SID")

    if char ~= nil then
        if data.type == "wash" then
            Inventory.Items:Remove(SID, 1, "moneyroll", data.amount)
            Inventory:AddItem(SID, "wetcash", data.amount, {}, 1)
            Execute:Client(source, "Notification", "Success", "You washed " .. data.amount .. " money rolls and received " .. data.amount .. " wet money rolls.")
        elseif data.type == "dry" then
            Inventory.Items:Remove(SID, 1, "wetcash", data.amount)
            Wallet:Modify(source, data.amount * 100)
        elseif data.type == "wash_band" then
            Inventory.Items:Remove(SID, 1, "moneyband", data.amount)
            Inventory:AddItem(SID, "wetcash2", data.amount, {}, 1)
            Execute:Client(source, "Notification", "Success", "You washed " .. data.amount .. " money bands and received " .. data.amount .. " wet money bands.")
        elseif data.type == "dry_band" then
            Inventory.Items:Remove(SID, 1, "wetcash2", data.amount)
            Wallet:Modify(source, data.amount * 1000)
        end
    else
        Execute:Client(source, "Notification", "Error", "Failed to find character data.")
    end
end)