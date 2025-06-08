AddEventHandler("PettyCrime:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
    Fetch = exports["lumen-base"]:FetchComponent("Fetch")
    Logger = exports["lumen-base"]:FetchComponent("Logger")
    Callbacks = exports["lumen-base"]:FetchComponent("Callbacks")
    Inventory = exports["lumen-base"]:FetchComponent("Inventory")
    Loot = exports["lumen-base"]:FetchComponent("Loot")
    Wallet = exports["lumen-base"]:FetchComponent("Wallet")
    Execute = exports["lumen-base"]:FetchComponent("Execute")
    EmergencyAlerts = exports["lumen-base"]:FetchComponent("EmergencyAlerts")
    Vendor = exports["lumen-base"]:FetchComponent("Vendor")
    Reputation = exports["lumen-base"]:FetchComponent("Reputation")
    Robbery = exports["lumen-base"]:FetchComponent("Robbery")
    Middleware = exports["lumen-base"]:FetchComponent("Middleware")
    Vehicles = exports["lumen-base"]:FetchComponent("Vehicles")
end

AddEventHandler("Core:Shared:Ready", function()
    exports["lumen-base"]:RequestDependencies("PettyCrime", {
        "Fetch",
        "Logger",
        "Callbacks",
        "Inventory",
        "Loot",
        "Wallet",
        "Execute",
        "EmergencyAlerts",
        "Vendor",
        "Reputation",
        "Robbery",
        "Middleware",
        "Vehicles",
    }, function(error)
        if #error > 0 then
            return
        end

        RetrieveComponents()
        TriggerEvent("PettyCrime:Server:Setup")
    end)
end)