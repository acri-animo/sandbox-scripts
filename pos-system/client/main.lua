local jobLabels = {
    ["al_dente"] = "Al Dente",
    ["burgershot"] = "Burger Shot",
}

AddEventHandler("Pos:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
    Callbacks = exports["lumen-base"]:FetchComponent("Callbacks")
    Notification = exports["lumen-base"]:FetchComponent("Notification")
    Targeting = exports["lumen-base"]:FetchComponent("Targeting")
    Action = exports["lumen-base"]:FetchComponent("Action")
    Keybinds = exports["lumen-base"]:FetchComponent("Keybinds")
    Jobs = exports["lumen-base"]:FetchComponent("Jobs")
    Inventory = exports["lumen-base"]:FetchComponent("Inventory")
    Sounds = exports["lumen-base"]:FetchComponent("Sounds")
end

AddEventHandler("Core:Shared:Ready", function()
    exports["lumen-base"]:RequestDependencies("Pos", {
        "Callbacks",
        "Notification",
        "Targeting",
        "Action",
        "Keybinds",
        "Jobs",
        "Inventory",
        "Sounds",
    }, function()
        RetrieveComponents()

        for k, v in ipairs(_posLocations) do
            -- Employee POS targeting zone
            Targeting.Zones:AddBox(v.id .. "-employee", "shop", v.coords, v.width, v.length, v.options, {
                {
                    icon = "shop",
                    text = "Open POS",
                    event = "Pos:Client:OpenPos",
                    data = {
                        job = v.job,
                        posType = "employee",
                    },
                    isEnabled = function()
                        return Jobs.Permissions:HasJob(v.job) and LocalPlayer.state.onDuty == v.job
                    end,
                },
                {
                    icon = "shop",
                    text = "Checkout",
                    event = "Pos:Client:OpenPos",
                    data = {
                        job = v.job,
                        posType = "customer",
                    },
                    isEnabled = function()
                        return true -- Customers don't need job permissions
                    end,
                },
            })
        end
    end)
end)

function checkPosJob(job)
    if not job then return false end
    return Jobs.Permissions:HasJob(job)
end

AddEventHandler("Pos:Client:OpenPos", function(entity, data)
    if not data or not data.job or not data.posType then 
        Notification:Error("Invalid POS data")
        return 
    end

    local jobName = jobLabels[data.job] or data.job

    local posData = {
        job = data.job,
        jobName = jobName,
        posType = data.posType,
        employee = {},
    }

    if data.posType == "employee" then
        Callbacks:ServerCallback("Pos:Server:FetchEmployeeInfo", { job = data.job }, function(response)
            if response.status then
                posData.employee = response.employee

                SetNuiFocus(true, true)
                SendNUIMessage({
                    action = "openPosSystem",
                    data = posData,
                })
            else
                Notification:Error("Failed to fetch employee info")
            end
        end)
    else
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "openPosSystem",
            data = posData,
        })
    end
end)

-- Fetch POS items
RegisterNUICallback("fetchPOSItems", function(data, cb)
    if not data or not data.job then
        Notification:Error("Invalid data")
        cb({
            status = false,
            message = "Invalid data",
        })
        return
    end

    Callbacks:ServerCallback("Pos:Server:FetchPOSItems", { job = data.job }, function(response)
        if response.status then
            cb({
                status = true,
                items = response.items,
                user = response.user,
            })
        else
            cb({
                status = false,
                message = response.message or "No items found",
            })
        end
    end)
end)

-- Fetch pending orders
RegisterNUICallback("fetchPOSOrder", function(data, cb)
    if not data or not data.job then
        Notification:Error("Invalid data")
        cb({
            status = false,
            message = "Invalid data",
        })
        return
    end

    Callbacks:ServerCallback("Pos:Server:FetchPOSOrder", { job = data.job }, function(response)
        if response.status then
            cb({
                status = true,
                orders = response.orders, -- Array of pending orders
            })
        else
            cb({
                status = false,
                message = response.message or "No orders found",
            })
        end
    end)
end)

-- Set a new order
RegisterNUICallback("posSetCart", function(data, cb)
    if not data or not data.job or not data.cart then
        Notification:Error("Invalid order data")
        cb({
            status = false,
            message = "Invalid order data",
        })
        return
    end

    Callbacks:ServerCallback("Pos:Server:SetPOSOrder", {
        job = data.job,
        cart = data.cart,
        discount = data.discount or 0,
        total = data.total,
        employeeName = data.employeeName,
    }, function(response)
        if response.status then
            Notification:Success("Order set successfully")
            cb({
                status = true,
                orderId = response.order,
            })
        else
            cb({
                status = false,
                message = response.message or "Failed to set order",
            })
        end
    end)
end)

RegisterNUICallback("clearPosCheckout", function(data, cb)
    if not data or not data.job then
        Notification:Error("Invalid job data")
        cb({
            status = false,
            message = "Invalid job data",
        })
        return
    end

    print("Clearing checkout for job:", data.job)

    Callbacks:ServerCallback("Pos:Server:ClearCheckoutCart", { job = data.job }, function(response)
        if response.status then
            cb({
                status = true,
                message = "Checkout cleared successfully",
            })
        else
            cb({
                status = false,
                message = response.message or "Failed to clear checkout",
            })
        end
    end)
end)

-- Checkout an order
RegisterNUICallback("posCheckout", function(data, cb)
    if not data then
        Notification:Error("Invalid checkout data")
        cb({
            status = false,
            message = "Invalid checkout data",
        })
        return
    end

    Callbacks:ServerCallback("Pos:Server:Checkout", {
        total = data.total,
        employeeName = data.employeeName,
        paymentMethod = data.paymentMethod,
        job = data.job,
        cart = data.cart,
        discount = data.discount or 0,
    }, function(response)
        if response.status then
            Sounds.Play:One("pos_checkout.ogg", 0.15)
            cb({
                status = true,
                money = "rich",
            })
        else
            cb({
                status = false,
                money = "broke",
                message = response.message or "Not enough funds",
            })
        end
    end)
end)


-- Close POS
RegisterNUICallback("closePosSystem", function(data, cb)
    SetNuiFocus(false, false)
    cb({ status = true })
end)

-- Receive real-time order updates
AddEventHandler("Pos:Client:UpdateOrders", function(job, orders)
    SendNUIMessage({
        action = "updateOrders",
        data = {
            job = job,
            orders = orders,
        },
    })
end)