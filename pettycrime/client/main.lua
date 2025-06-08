AddEventHandler("PettyCrime:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
    Logger = exports["lumen-base"]:FetchComponent("Logger")
    Callbacks = exports["lumen-base"]:FetchComponent("Callbacks")
    PedInteraction = exports["lumen-base"]:FetchComponent("PedInteraction")
    Progress = exports["lumen-base"]:FetchComponent("Progress")
    Notification = exports["lumen-base"]:FetchComponent("Notification")
    Polyzone = exports["lumen-base"]:FetchComponent("Polyzone")
    Targeting = exports["lumen-base"]:FetchComponent("Targeting")
    Minigame = exports["lumen-base"]:FetchComponent("Minigame")
    Action = exports["lumen-base"]:FetchComponent("Action")
    EmergencyAlerts = exports["lumen-base"]:FetchComponent("EmergencyAlerts")
    Reputation = exports["lumen-base"]:FetchComponent("Reputation")
    NetSync = exports["lumen-base"]:FetchComponent("NetSync")
    Inventory = exports["lumen-base"]:FetchComponent("Inventory")
end

AddEventHandler("Core:Shared:Ready", function()
    exports["lumen-base"]:RequestDependencies("PettyCrime", {
        "Logger",
        "Callbacks",
        "PedInteraction",
        "Progress",
        "Notification",
        "Polyzone",
        "Targeting",
        "Minigame",
        "Action",
        "EmergencyAlerts",
        "Reputation",
        "NetSync",
        "Inventory"
    }, function(error)
        if #error > 0 then
            return
        end

        RetrieveComponents()
        TriggerEvent("PettyCrime:Client:Setup")
    end)
end)