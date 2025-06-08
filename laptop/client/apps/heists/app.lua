local _heisting = nil
local wasHeisting = false
local isTeamLeader = nil

RegisterNetEvent("Characters:Client:Logout")
AddEventHandler("Characters:Client:Logout", function()
    LocalPlayer.state:set("isHeisting", false)
    _heisting = nil
    wasHeisting = false
end)

RegisterNUICallback("Heist:Start", function(data, cb)
    Callbacks:ServerCallback("LaptopHeists:Start", data, cb)
end)

RegisterNUICallback("Heist:Admin:GetBans", function(data, cb)
    Callbacks:ServerCallback("LaptopHeists:Admin:GetBans", data, cb)
end)

RegisterNUICallback("Heist:ExitQueue", function(data, cb)
    Callbacks:ServerCallback("LaptopHeists:ExitQueue", {}, cb)
end)

RegisterNUICallback("Heist:EnterQueue", function(data, cb)
    Callbacks:ServerCallback("LaptopHeists:EnterQueue", {}, cb)
end)

RegisterNUICallback("Heist:Admin:CreateContract", function(data, cb)
    Callbacks:ServerCallback("LaptopHeists:Admin:CreateContract", data, cb)
end)

RegisterNUICallback("Heist:Admin:Ban", function(data, cb)
    Callbacks:ServerCallback("LaptopHeists:Admin:Ban", data, cb)
end)

RegisterNUICallback("Heist:Admin:Unban", function(data, cb)
    Callbacks:ServerCallback("LaptopHeists:Admin:Unban", data, cb)
end)

RegisterNUICallback("GetHeistsData", function(data, cb)
    Callbacks:ServerCallback("LaptopHeists:GetData", {}, cb)
end)

RegisterNetEvent("Laptop:ClientHeists:Start", function(data)
    LocalPlayer.state:set("isHeisting", true)
    _heisting = data
    wasHeisting = true

    if _heisting and _heisting.pickupLocation then
        ClearGpsPlayerWaypoint()
        SetNewWaypoint(_heisting.pickupLocation.x, _heisting.pickupLocation.y)

        Blips:Add(
            "heist-pickup",
            "[Heist]: Pickup Equipment",
            _heisting.pickupLocation,
            501,
            5,
            1.0,
            2,
            false,
            false
        )

        CreateThread(function()
            while _heisting and LocalPlayer.state.loggedIn do
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(playerCoords - _heisting.pickupLocation)
                
                if distance < 10.0 then
                    TriggerServerEvent("Laptop:ServerHeists:AtPickupPoint", _heisting.teamId)
                    break
                end
                
                Wait(1000)
            end
        end)
    end
end)

RegisterNetEvent("Laptop:ClientHeists:End", function(cancelled)
    if _heisting then
        LocalPlayer.state:set("isHeisting", false)
        _heisting = nil

        Blips:Remove("heist-location")
        TriggerEvent("Status:Client:Update", "heisting-timer", 0)
        Notification.Persistent:Remove("heisting-status")
    end
end)

RegisterNetEvent("Laptop:Client:Teams:Set", function(teamData)
    if not teamData and wasHeisting then
        Laptop.Notification:Remove("HEIST_CONTRACT")
        
        if _heisting then
            LocalPlayer.state:set("isHeisting", false)
            _heisting = nil

            Blips:Remove("heist-location")
            TriggerEvent("Status:Client:Update", "heisting-timer", 0)
            Notification.Persistent:Remove("heisting-status")
        end

        isTeamLeader = nil
    else
        local mySID = LocalPlayer.state.Character:GetData("SID")
        
        isTeamLeader = false
        for _, member in ipairs(teamData.Members) do
            if member.SID == mySID then
                isTeamLeader = member.Leader or false
                break
            end
        end
    end
end)

RegisterNetEvent("Laptop:ClientHeists:StartPickupPhase", function(data)
    LocalPlayer.state.isHeisting = true
    LocalPlayer.state:set("isHeisting", true)
    _heisting = data

    ClearGpsPlayerWaypoint()
    SetNewWaypoint(data.pickupLocation.x, data.pickupLocation.y)

    Blips:Add(
        "heist-pickup",
        "[Heist]: Equipment Pickup",
        data.pickupLocation,
        501,
        5,
        1.0,
        2,
        false,
        false
    )

    CreateThread(function()
        while LocalPlayer.state.loggedIn and _heisting and isTeamLeader do
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            if #(coords - data.pickupLocation) < 5.0 then
                TriggerServerEvent("Laptop:ServerHeists:LeaderPickup", data.teamId)
                break
            end
            Wait(1000)
        end
    end)
end)

RegisterNetEvent("Laptop:ClientHeists:ContinueToBank", function(data)
    ClearGpsPlayerWaypoint()
    SetNewWaypoint(data.bankLocation.x, data.bankLocation.y)

    Blips:Add(
        "heist-location",
        "[Heist]: Bank Location",
        data.bankLocation,
        500,
        25,
        1.0,
        2,
        false,
        false
    )
end)

RegisterNetEvent("Laptop:ClientHeists:RemoveBlip", function(blipId)
    Blips:Remove(blipId)
end)

function CompleteHeist(moneyAmount)
    if not _heisting or not LocalPlayer.state.isHeisting then
        return false
    end
    if not isTeamLeader then
        return false
    end
    TriggerServerEvent("Laptop:ServerHeists:CompleteHeist", _heisting.teamId, moneyAmount)
    return true
end

exports("CompleteHeist", CompleteHeist)


RegisterCommand("complete", function(source, args, rawCommand)
    local moneyAmount = tonumber(args[1])
    
    if moneyAmount and moneyAmount > 0 then
        if _heisting and _heisting.teamId then
            TriggerServerEvent("Laptop:ServerHeists:CompleteHeist", _heisting.teamId, moneyAmount)
            print("Heist complete, sending money: " .. moneyAmount)
        else
            print("No heisting in progress.")
        end
    else
        print("Invalid money amount.")
    end
end, false)
