local _joiner = nil
local _working = false
local _blip = nil
local _treeBlips = {}
local eventHandlers = {}
local _state = 0
local treeEntities = {}
local _treeLocations = {}
local _logs = {}

local function requestPropModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end
end

AddEventHandler("Labor:Client:Setup", function()
    PedInteraction:Add("LumberJob", GetHashKey("a_m_m_hillbilly_02"), vector3(-567.664, 5253.212, 69.487), 78.174, 25.0, {
        {
            icon = "handshake-angle",
            text = "Start Work",
            event = "Lumber:Client:StartJob",
            tempjob = "Lumber",
            isEnabled = function()
                return not _working
            end,
        },
        {
            icon = "money-check-dollar",
            text = "Complete Job",
            event = "Lumber:Client:TurnIn",
            tempjob = "Lumber",
            isEnabled = function()
                return _working and _state == 3
            end,
        },
    }, "tree")
end)

RegisterNetEvent("Lumber:Client:OnDuty", function(joiner, time)
    _joiner = joiner
    DeleteWaypoint()
    SetNewWaypoint(-567.664, 5253.212)

    _blip = Blips:Add("LumberStart", "Lumber Foreman", { x = -567.664, y = 5253.212, z = 69.487 }, 480, 2, 1.4)

    eventHandlers["startup"] = RegisterNetEvent(string.format("Lumber:Client:%s:Startup", joiner), function(locations)
        _working = true
        _state = 1
        _treeLocations = locations

        local model = GetHashKey("prop_tree_pine_01")
        requestPropModel(model)

        for k, v in ipairs(_treeLocations) do
            local tree = CreateObject(model, v.x, v.y, v.z, false, true, false)
            FreezeEntityPosition(tree, true)

            Targeting:AddEntity(tree, "tree", {
                {
                    icon = "tree",
                    text = "Saw down tree",
                    event = string.format("Lumber:Client:%s:Action", _joiner),
                    data = v,
                    isEnabled = function()
                        return _working and _state == 1
                    end,
                }
            }, 3.0)

            table.insert(treeEntities, tree)

            local blipName = "LumberTree" .. k
            local blip = Blips:Add(blipName, "Tree", { x = v.x, y = v.y, z = v.z }, 594, 25, 0.7)
            _treeBlips[k] = { blip = blipName, coords = v }
        end

        SetModelAsNoLongerNeeded(model)
    end)

    eventHandlers["actions"] = RegisterNetEvent(string.format("Lumber:Client:%s:Action", joiner), function(entity, data)
        local coords = vector3(data.x, data.y, data.z)

        Progress:Progress({
            name = "lumber_action",
            duration = math.random(3000, 5000),
            label = "Sawing tree",
            useWhileDead = false,
            canCancel = true,
            vehicle = false,
            animation = {
                anim = "idle",
            },
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableCombat = true,
            },
        }, function(cancelled)
            if not cancelled then
                local tree = entity.entity
                if DoesEntityExist(tree) then
                    DeleteEntity(tree)
                end

                Targeting:RemoveEntity(tree)

                Callbacks:ServerCallback("Lumber:CutTree", { location = coords }, function(success)
                    if success then
                        Notification:Success("Successfully cut down the tree.")
                    else
                        Notification:Error("Failed to cut down the tree.")
                    end
                end)
            end
        end)
    end)

    eventHandlers["removeblip"] = RegisterNetEvent(string.format("Lumber:Client:%s:RemoveTree", joiner), function(location)
        for k, v in ipairs(_treeBlips) do
            local blipCoords = vector3(v.coords.x, v.coords.y, v.coords.z)
            local locationCoords = vector3(location.x, location.y, location.z)
            
            if blipCoords == locationCoords then
                Blips:Remove(v.blip)
                table.remove(_treeBlips, k)
                break
            end
        end
    end)
end)

AddEventHandler("Lumber:Client:StartJob", function()
    Callbacks:ServerCallback("Lumber:StartJob", _joiner, function(success)
        if not success then
            Notification:Error("Failed to start Lumber job")
        end

        _state = 1
    end)
end)

RegisterNetEvent("Lumber:Client:OffDuty", function(time)
    for k, v in pairs(eventHandlers) do
        RemoveEventHandler(v)
    end

    for k, v in ipairs(treeEntities) do
        Targeting:RemoveEntity(v)
        DeleteObject(v)
        treeEntities[k] = nil
    end

    for k, v in pairs(_treeBlips) do
        Blips:Remove(v.blip)
    end

    if _blip ~= nil then
        Blips:Remove("LumberStart")
        _blip = nil
    end

    eventHandlers = {}
    _joiner = nil
    _working = false
    _state = 0
    _treeLocations = {}
    _treeBlips = {}
end)