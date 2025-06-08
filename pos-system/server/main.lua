local posItemsCache = {}

local jobMatchLabel = {
    ["al_dente"] = "Al Dente",
    ["burgershot"] = "Burgershot",
}

AddEventHandler("Pos:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
    Fetch = exports["lumen-base"]:FetchComponent("Fetch")
    Logger = exports["lumen-base"]:FetchComponent("Logger")
    Callbacks = exports["lumen-base"]:FetchComponent("Callbacks")
    Inventory = exports["lumen-base"]:FetchComponent("Inventory")
    Banking = exports["lumen-base"]:FetchComponent("Banking")
    Wallet = exports["lumen-base"]:FetchComponent("Wallet")
    Execute = exports["lumen-base"]:FetchComponent("Execute")
    Reputation = exports["lumen-base"]:FetchComponent("Reputation")
end

AddEventHandler("Core:Shared:Ready", function()
    exports["lumen-base"]:RequestDependencies("Pos", {
        "Fetch",
        "Logger",
        "Callbacks",
        "Inventory",
        "Banking",
        "Wallet",
        "Execute",
        "Reputation",
    }, function(error)
        if #error > 0 then
            return
        end
        RetrieveComponents()
        RegisterPOSCallbacks()

        local jobs = MySQL.query.await('SELECT job, pos_items FROM pos_system')
        for _, row in ipairs(jobs) do
            posItemsCache[row.job] = json.decode(row.pos_items) or {}
        end
    end)
end)

function RegisterPOSCallbacks()
    Callbacks:RegisterServerCallback("Pos:Server:FetchPOSItems", function(source, data, cb)
        if not data or not data.job then
            Execute:Client(source, "Notification", "Error", "Invalid job data provided.")
            return cb({ status = false, message = "Invalid job data provided." })
        end

        local job = data.job
        local items = posItemsCache[job]

        if not items then
            Execute:Client(source, "Notification", "Error", "No POS items found for job: " .. job)
            return cb({ status = false, message = "No POS items found for this job." })
        end

        local itemList = {}
        for itemName, itemData in pairs(items) do
            local invItem = Inventory.Items:GetData(itemName)
            local itemLabel = invItem and invItem.label or itemData.label or itemName
            local itemPicture = nil

            if itemData.category ~= "Specials" then
                local imageName = invItem and (invItem.iconOverride or itemName) or itemName
                itemPicture = string.format("nui://lumen-inventory/ui/images/items/%s.webp", imageName)
            end

            table.insert(itemList, {
                item = itemName,
                label = itemLabel,
                price = itemData.price or 0,
                category = itemData.category or "Uncategorized",
                picture = itemPicture or itemData.picture,
            })
        end

        -- print(json.encode(itemList))
        cb({ status = true, items = itemList })
    end)

    Callbacks:RegisterServerCallback("Pos:Server:RefreshPOSItems", function(source, data, cb)
        if not data or not data.job then
            Execute:Client(source, "Notification", "Error", "Invalid job data provided.")
            return cb({ status = false, message = "Invalid job data provided." })
        end

        local job = data.job

        local response = MySQL.query.await('SELECT `pos_items` FROM `pos_system` WHERE `job` = ?', { job })

        if not response or #response == 0 then
            Execute:Client(source, "Notification", "Error", "No POS items found for job: " .. job)
            return cb({ status = false, message = "No POS items found for this job." })
        end

        local posItems = response[1].pos_items
        local items = json.decode(posItems)

        if not items then
            Logger:Error("Pos", "Failed to decode POS items for job: " .. job)
            Execute:Client(source, "Notification", "Error", "Failed to decode POS items.")
            return cb({ status = false, message = "Failed to decode POS items." })
        end

        posItemsCache[job] = items

        local itemList = {}
        for itemName, itemData in pairs(items) do
            local invItem = Inventory.Items:GetData(itemName)
            local itemLabel = invItem and invItem.label or itemData.label or itemName
            local itemPicture = nil

            if itemData.category ~= "Specials" then
                local imageName = invItem and (invItem.iconOverride or itemName) or itemName
                itemPicture = string.format("nui://lumen-inventory/ui/images/items/%s.webp", imageName)
            end

            table.insert(itemList, {
                item = itemName,
                label = itemLabel,
                price = itemData.price or 0,
                category = itemData.category or "Uncategorized",
                picture = itemPicture or itemData.picture,
            })
        end

        -- print(json.encode(itemList))
        cb({ status = true, items = itemList })
    end)

    Callbacks:RegisterServerCallback("Pos:Server:CreatePOSItem", function(source, data, cb)
        if not data or not data.job or not data.doc then
            Execute:Client(source, "Notification", "Error", "Invalid job or document data provided.")
            return cb(false)
        end

        local job = data.job
        local doc = data.doc

        local response = MySQL.query.await('SELECT `pos_items` FROM `pos_system` WHERE `job` = ?', { job })

        if not response or #response == 0 then
            Execute:Client(source, "Notification", "Error", "No POS items found for job: " .. job)
            return cb({ status = false, message = "No POS items found for this job." })
        end

        local posItems = response[1].pos_items
        local items = json.decode(posItems)

        if not items then
            Logger:Error("Pos", "Failed to decode POS items for job: " .. job)
            Execute:Client(source, "Notification", "Error", "Failed to decode POS items.")
            return cb({ status = false, message = "Failed to decode POS items." })
        end

        if items[doc.item] then
            Execute:Client(source, "Notification", "Error", "Item '" .. doc.item .. "' already exists in the POS system.")
            return cb({ status = false, message = "Item already exists in the POS system." })
        end

        items[doc.item] = {
            picture = doc.picture,
            price = tonumber(doc.price),
            category = doc.category
        }

        local updatedItemsJson = json.encode(items)
        local updateResult = MySQL.update.await('UPDATE `pos_system` SET `pos_items` = ? WHERE `job` = ?', { updatedItemsJson, job })

        if not updateResult or updateResult == 0 then
            Execute:Client(source, "Notification", "Error", "Failed to update POS items in the database.")
            return cb({ status = false, message = "Failed to update POS items in the database." })
        end

        posItemsCache[job] = items

        Execute:Client(source, "Notification", "Success", "Successfully added new item '" .. doc.item .. "' to Specials.")
        cb({ status = true, message = "Item added successfully." })
    end)

    Callbacks:RegisterServerCallback("Pos:Server:UpdatePOSItemPrice", function(source, data, cb)
        if not data or not data.job or not data.itemName or not data.price then
            Execute:Client(source, "Notification", "Error", "Invalid job or item data provided.")
            return cb({ status = false, message = "Invalid job or item data provided." })
        end

        local job = data.job
        local itemName = data.itemName
        local newPrice = tonumber(data.price)
        local response = MySQL.query.await('SELECT `pos_items` FROM `pos_system` WHERE `job` = ?', { job })

        if not response or #response == 0 then
            Execute:Client(source, "Notification", "Error", "No POS items found for job: " .. job)
            return cb({ status = false, message = "No POS items found for this job." })
        end

        local posItems = response[1].pos_items
        local items = json.decode(posItems)

        if not items or not items[itemName] then
            Execute:Client(source, "Notification", "Error", "Item '" .. itemName .. "' not found in the POS system.")
            return cb({ status = false, message = "Item not found in the POS system." })
        end

        items[itemName].price = newPrice

        local updatedItemsJson = json.encode(items)
        local updateResult = MySQL.update.await('UPDATE `pos_system` SET `pos_items` = ? WHERE `job` = ?', { updatedItemsJson, job })

        if not updateResult or updateResult == 0 then
            Execute:Client(source, "Notification", "Error", "Failed to update POS items in the database.")
            return cb({ status = false, message = "Failed to update POS items in the database." })
        end

        posItemsCache[job] = items
        
        Execute:Client(source, "Notification", "Success", "Successfully updated item '" .. itemName .. "' price to $" .. newPrice)
        cb({ status = true, message = "Item price updated successfully." })
    end)

    Callbacks:RegisterServerCallback("Pos:Server:FetchEmployeeInfo", function(source, data, cb)
        if not data or not data.job then
            Execute:Client(source, "Notification", "Error", "Invalid job data provided.")
            return cb({ status = false, message = "Invalid job data provided." })
        end

        local char = Fetch:CharacterSource(source)
        local userName = string.format("%s %s", char:GetData("First"), char:GetData("Last"))
        local job = data.job
        local playerGrade
        local playerJobs = char:GetData("Jobs")

        for k, v in pairs(playerJobs) do
            if v.Id == job then
                playerGrade = v.Grade
                break
            end
        end

        local userInfo = {
            name = userName,
            grade = playerGrade.Name,
        }

        -- print(json.encode(userInfo))

        cb({ status = true, employee = userInfo })
    end)

    Callbacks:RegisterServerCallback("Pos:Server:Checkout", function(source, data, cb)
        if not data or not data.total then
            Execute:Client(source, "Notification", "Error", "Invalid data provided.")
            return cb({ status = false, message = "Invalid data provided." })
        end

        -- print(json.encode(data))

        local src = source
        local char = Fetch:CharacterSource(src)
        local SID = char:GetData("SID")
        local total = tonumber(data.total)

        if data.paymentMethod == "bank" then
            local bankAcc = Banking.Accounts:GetPersonal(SID)

            if bankAcc.Balance < total then
                Execute:Client(src, "Notification", "Error", "Insufficient funds in bank account.")
                return cb({ status = false, message = "Insufficient funds in bank account." })
            end

            local jobName = jobMatchLabel[data.job] or data.job
            Banking.Balance:Withdraw(bankAcc.Account, total, {
                type = "withdraw",
                title = jobName .. " POS Purchase",
                description = "Purchased items from POS.",
            })

            givePosOrgMoney(data.job, total)
            GlobalState[string.format("PosOrder:%s", data.job)] = nil
            Execute:Client(src, "Notification", "Success", "Purchase successful! Total: $" .. total)
            return cb({ status = true, message = "Purchase successful!" })
        elseif data.paymentMethod == "cash" then
            if not Wallet:Has(src, total) then
                Execute:Client(src, "Notification", "Error", "Insufficient cash in wallet.")
                return cb({ status = false, message = "Insufficient cash in wallet." })
            end

            Wallet:Modify(src, -total)
            givePosOrgMoney(data.job, total)
            GlobalState[string.format("PosOrder:%s", data.job)] = nil
            Execute:Client(src, "Notification", "Success", "Purchase successful! Total: $" .. total)
            return cb({ status = true, message = "Purchase successful!" })
        end
    end)

    Callbacks:RegisterServerCallback("Pos:Server:SetPOSOrder", function(source, data, cb)
        if not data or not data.job then
            Execute:Client(source, "Notification", "Error", "Invalid data provided.")
            return cb({ status = false, message = "Invalid data provided." })
        end

        local job = data.job
        local globalCart = {
            job = job,
            cart = data.cart,
            discount = data.discount or 0,
            total = data.total,
            employeeName = data.employeeName,
            timestamp = os.time(),
        }

        -- local orderIdRan = math.random(100, 999)
        local globalStateKey = string.format("PosOrder:%s", job)

        GlobalState[globalStateKey] = globalCart

        -- print(json.encode(GlobalState[globalStateKey])) -- For debugging

        cb({ status = true, orderId = orderIdRan })
    end)

    Callbacks:RegisterServerCallback("Pos:Server:FetchPOSOrder", function(source, data, cb)
        if not data or not data.job then
            Execute:Client(source, "Notification", "Error", "Invalid job data provided.")
            return cb({ status = false, message = "Invalid job data provided." })
        end

        local job = data.job

        local pendingOrder = GlobalState[string.format("PosOrder:%s", job)]

        if not pendingOrder then
            Execute:Client(source, "Notification", "Error", "No orders found for this job.")
            return cb({ status = true, message = "No orders found for this job." })
        end

        -- print(json.encode(pendingOrder))
        cb({ status = true, orders = pendingOrder or {} })
    end)

    Callbacks:RegisterServerCallback("Pos:Server:ClearCheckoutCart", function(source, data, cb)
        if not data or not data.job then
            Execute:Client(source, "Notification", "Error", "Invalid job data provided.")
            return cb({ status = false, message = "Invalid job data provided." })
        end

        local job = data.job
        local globalStateKey = string.format("PosOrder:%s", job)

        GlobalState[globalStateKey] = nil

        cb({ status = true, message = "Checkout cart cleared." })
    end)
end

function givePosOrgMoney(job, amount)
    local orgAccount = Banking.Accounts:GetOrganization(job)
    local jobName = jobMatchLabel[job] or job

    Banking.Balance:Deposit(orgAccount.Account, amount, {
        type = "deposit",
        title = jobName .. " POS Sale",
        description = "Sale from POS system.",
    })
end