local _joiner = nil
local _working = false
local _blip = nil
local eventHandlers = {}
local _deliveries = {}
local _currentDelivery = nil
local _state = 0
local _isTimeTrial = false
local _timeLimit = 0
local _startTime = 0
local _locations = nil
local onBike = false

local JOB_MENU_CONFIG = {
    paleto = {
        name = "Paleto",
        routes = {
            { label = "Paleto 1", description = "Paleto Route 1 Description.", route = 0, minRep = 0 },
        },
        trials = {
            { area = "paleto", route = 0, tiers = { "easy", "medium", "hard" } },
            { area = "paleto", route = 3, tiers = { "easy", "medium", "hard" }, minRep = 3 },
        }
    },
}


local function generateMenuItems(areaKey)
    local config = JOB_MENU_CONFIG[areaKey]
    local repLevel = Reputation:GetLevel("Newspaper")

    local routeItems = {}
    for _, route in ipairs(config.routes) do
        table.insert(routeItems, {
            label = config.name .. " " .. route.label,
            description = route.description,
            event = "Newspaper:Client:StartJob",
            data = { area = areaKey, route = route.route },
            disabled = repLevel < route.minRep
        })
    end

    local trialItems = {}
    for _, trial in ipairs(config.trials) do
        for _, tierName in ipairs(trial.tiers) do -- No need for tierIndex here
            table.insert(trialItems, {
                label = string.format("%s - %s Trial", config.name, tierName:gsub("^%l", string.upper)), -- Capitalize for display
                description = "Deliver newspapers as fast as you can!",
                event = "Newspaper:Client:StartTimeTrial",
                data = { area = trial.area, route = trial.route, tier = tierName }, -- Use tierName directly
                disabled = trial.minRep and repLevel < trial.minRep
            })
        end
    end

    return {
        main = {
            label = "Newspaper Job",
            items = {
                { label = "Standard Routes", description = "Select a route to deliver newspapers.", submenu = "routes" },
                { label = "Time Trials", description = "Test your delivery skills against the clock.", submenu = "trials" }
            }
        },
        routes = {
            label = "Routes",
            items = routeItems
        },
        trials = {
            label = "Time Trials",
            items = trialItems
        }
    }
end

-- Startup event
AddEventHandler("Labor:Client:Setup", function()
    -- Ped to start job
    PedInteraction:Add("NewspaperJob", GetHashKey("s_m_y_construct_01"), vector3(-421.708, 6137.136, 30.877), 224.212, 35.0, {
        {
            icon = "handshake-angle",
            text = "Open Job Menu",
            event = "Newspaper:Client:JobPedMenu",
            tempjob = "Newspaper",
            isEnabled = function()
                return not _working
            end,
        },
        {
            icon = "bicycle",
            text = "Rent Bicycle",
            event = "Newspaper:Client:SpawnBicycle",
            tempjob = "Newspaper",
            isEnabled = function()
                return _working and _state == 1
            end,
        },
        {
            icon = "newspaper",
            text = "Purchase Newspapers ($300 for 15)",
            event = "Newspaper:Client:PurchaseNewspapers",
            tempjob = "Newspaper",
            isEnabled = function()
                return _working and _state == 1
            end,
        },
        {
            icon = "money-check-dollar",
            text = "Complete Job",
            event = "Newspaper:Client:TurnIn",
            tempjob = "Newspaper",
            isEnabled = function()
                return _working and _state == 3
            end,
        },
    }, "newspaper")
end)

------------------
-- Events/Handlers
------------------

RegisterNetEvent("Newspaper:Client:OnDuty", function(joiner, time)
    _joiner = joiner
    DeleteWaypoint()
    SetNewWaypoint(-421.708, 6137.136)

    _blip = Blips:Add("NewspaperStart", "Newspaper Manager", { x = -421.708, y = 6137.136, z = 0 }, 162, 1, 1.4)

    eventHandlers["startup"] = RegisterNetEvent(string.format("Newspaper:Client:%s:Startup", joiner), function(locations)
        _working = true
        _deliveries = locations
    end)

    eventHandlers["startupTrial"] = RegisterNetEvent(string.format("Newspaper:Client:%s:StartupTrial", joiner), function(data)
        _isTimeTrial = true
        _working = true
        _deliveries = data.locations
        _locations = data.locations
        _timeLimit = data.timeLimit
        _startTime = GetGameTimer() / 1000
        _state = 1
    
        Citizen.CreateThread(function()
            while _isTimeTrial and _state ~= 3 do
                if _state == 2 then
                    local elapsed = GetGameTimer() / 1000 - _startTime
                    local remaining = math.max(0, _timeLimit - elapsed)
    
                    TriggerServerEvent("Newspaper:Server:UpdateTimeTrial", _joiner, remaining, #_deliveries, elapsed)
    
                    if remaining <= 0 then
                        Notification:Error("Time's up!")
                        break
                    end
                end
                Citizen.Wait(1000)
            end
        end)
    end)

    eventHandlers["spawn-bicycle"] = AddEventHandler("Newspaper:Client:SpawnBicycle", function()
        Callbacks:ServerCallback("Newspaper:SpawnBicycle", {}, function(success)
            if success then
                _state = 2
                SetNextDeliveryWaypoint()
            else
                Notification:Error("Failed to spawn bicycle and newspapers.")
            end
        end)
    end)

    eventHandlers["throw-newspaper"] = AddEventHandler("Newspaper:Client:ThrowNewspaper", function()
        if _currentDelivery then
            Citizen.CreateThread(function()
                local playerPed = PlayerPedId()
                local throwPromptShown = false
                local waitingForThrow = false
    
                while _currentDelivery do
                    local playerPos = GetEntityCoords(playerPed)
                    local targetPos = vector3(_currentDelivery.x, _currentDelivery.y, _currentDelivery.z)
                    local distance = #(playerPos - targetPos)
    
                    if distance < 30.0 then
                        DrawMarker(3, targetPos.x, targetPos.y, targetPos.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 134, 133, 239, 100, false, true, 2, false, false, false, false)
                        local vehicle = GetVehiclePedIsIn(playerPed, false)
                        if vehicle ~= 0 and IsThisModelABicycle(GetEntityModel(vehicle)) then
                            onBike = true
                            waitingForThrow = true
                            if not throwPromptShown then
                                Action:Show("newspaper_throw","Hold (RMB) & Press (LMB) to throw.")
                                throwPromptShown = true
                            end

                            local hasWeapon = HasPedGotWeapon(playerPed, `WEAPON_NEWSPAPER`, false)
                            local isAiming = IsControlPressed(0, 25)
                            local isThrowing = IsControlJustPressed(0, 24) -- Left Mouse Button

                            if hasWeapon and isAiming and isThrowing then
                                Citizen.Wait(2000) -- Wait for newspaper to land
                                if IsProjectileTypeWithinDistance(_currentDelivery.x, _currentDelivery.y, _currentDelivery.z, `WEAPON_NEWSPAPER`, 7.0, true) then
                                    Callbacks:ServerCallback("Newspaper:CompleteDelivery", _joiner, function(success)
                                        if success then
                                            table.remove(_deliveries, 1)
                                            Notification:Success("Newspaper delivered!")

                                            if #_deliveries > 0 then
                                                SetNextDeliveryWaypoint()
                                            else
                                                Notification:Info("All newspapers delivered!")
                                                SetNewWaypoint(-421.708, 6137.136)
                                                _currentDelivery = nil
                                                _state = 3
                                            end
                                        else
                                            Notification:Error("Failed to deliver newspaper.")
                                        end
                                    end)
                                    Action:Hide("newspaper_throw")
                                    break
                                else
                                    Notification:Error("Newspaper missed the target!")
                                    waitingForThrow = false
                                end
                            end
                        end
                    else
                        if throwPromptShown then
                            Action:Hide("newspaper_throw")
                            throwPromptShown = false
                        end
                    end
                    Citizen.Wait(0)
                end
            end)
        end
    end)

    eventHandlers["turn-in"] = AddEventHandler("Newspaper:Client:TurnIn", function()
        for k, v in ipairs(_locations) do
            ClearAreaOfProjectiles(v.x, v.y, v.z, 15.0, 0)
        end
        
        Callbacks:ServerCallback("Newspaper:TurnIn", _joiner)
    end)
end)

AddEventHandler('Vehicles:Client:ExitVehicle', function(pCurrentVehicle)
    if pCurrentVehicle ~= 0 and IsThisModelABicycle(GetEntityModel(pCurrentVehicle)) and _working then
        Notification:Error("You must be on a bicycle to continue the job.")
        Action:Hide("newspaper_throw")
    end
end)

function SetNextDeliveryWaypoint()
    if #_deliveries > 0 then
        _currentDelivery = _deliveries[1]
        DeleteWaypoint()
        SetNewWaypoint(_currentDelivery.x, _currentDelivery.y)
        Notification:Info("Deliver the newspaper to the next house.")
        TriggerEvent("Newspaper:Client:ThrowNewspaper")
    end
end

AddEventHandler("Newspaper:Client:JobPedMenu", function()
    ListMenu:Show(generateMenuItems("paleto"))
end)

AddEventHandler("Newspaper:Client:StartJob", function(data)
    local area = data.area
    local route = data.route
    local joiner = _joiner

    Callbacks:ServerCallback("Newspaper:StartJob", { joiner = joiner, area = area, route = route }, function(success)
        if not success then
            Notification:Error("Unable to start job.")
        else
            _state = 1
        end
    end)
end)

AddEventHandler("Newspaper:Client:StartTimeTrial", function(data)
    local area = data.area
    local route = data.route
    local tier = data.tier
    local joiner = _joiner

    Callbacks:ServerCallback("Newspaper:StartTimeTrial", { 
        joiner = joiner, 
        area = area, 
        route = route, 
        tier = tier 
    }, function(success)
        if not success then
            Notification:Error("Unable to start job.")
        else
            _state = 1
        end
    end)
end)

AddEventHandler("Newspaper:Client:PurchaseNewspapers", function()
    Callbacks:ServerCallback("Newspaper:PurchaseNewspapers", {}, function(success)
        if success then
            Notification:Success("Purchased newspapers.")
        else
            Notification:Error("You do not have enough money in your bank account.")
        end
    end)
end)

RegisterNetEvent("Newspaper:Client:OffDuty", function(time)
    for k, v in pairs(eventHandlers) do
        RemoveEventHandler(v)
    end

    if _blip ~= nil then
        Blips:Remove("NewspaperStart")
        RemoveBlip(_blip)
        _blip = nil
    end

    DeleteWaypoint()
    _joiner = nil
    _working = false
    _currentDelivery = nil
    _deliveries = {}
    _isTimeTrial = false
    _timeLimit = 0
    _startTime = 0
    _state = 0
    eventHandlers = {}
end)