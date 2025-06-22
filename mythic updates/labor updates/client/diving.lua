local _joiner = nil
local _working = false
local _actionLabel = nil
local _actionBaseDur = nil
local _actionAnim = nil
local _finished = false
local _tasks = 0
local _blips = {}
local _blip = nil
local eventHandlers = {}
local _nodes = nil
local _state = 0
local _divingCrates = {}


-- Setup event
AddEventHandler("Labor:Client:Setup", function()
    -- Ped to start job
    PedInteraction:Add("DivingJob", `s_m_y_uscg_01`, vector3(-1799.363, -1224.240, 0.596), 143.265, 25.0, {
        {
            icon = "clipboard",
            text = "Start Job",
            event = "Diving:Client:StartJob",
            tempjob = "Diving",
            isEnabled = function()
                return not _working
            end,
        },
        {
            icon = "sailboat",
            text = "Borrow Dinghy",
            event = "Diving:Client:SpawnBoat",
            tempjob = "Diving",
            isEnabled = function()
                return _working and _state == 1
            end,
        },
        {
            icon = "mask-snorkel",
            text = "Buy Scuba Tank ($500)",
            event = "Diving:Client:BuyScuba",
            tempjob = "Diving",
            isEnabled = function()
                return _working
            end,
        },
        {
            icon = "handshake",
            text = "Finish Job",
            event = "Diving:Client:TurnIn",
            tempjob = "Diving",
            isEnabled = function()
                return _working and _state == 3
            end,
        },
    }, 'person-swimming', 'WORLD_HUMAN_CLIPBOARD')
end)

------------
-- Functions
------------

-- Progress bar for opening crates
local _doing = false
function DoDiveAction(id)
    FreezeEntityPosition(LocalPlayer.state.ped, true)

    Progress:ProgressWithTickEvent({
        name = 'diving_action',
        duration = math.random(3,5) * 1000,
        label = 'Opening Crate',
        tickrate = 1000,
        useWhileDead = false,
        canCancel = true,
        vehicle = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableCombat = true,
        },
        animation = _actionAnim,
    }, function()
        if not _doing then return end
        if _nodes ~= nil then
            for k, v in ipairs(_nodes) do
                if v.id == id then
                    return
                end
            end
        end
        Progress:Cancel()
    end, function(cancelled)
        _doing = false
        if not cancelled then
            Callbacks:ServerCallback("Diving:CompleteNode", id)
            FreezeEntityPosition(LocalPlayer.state.ped, false)
        else
            FreezeEntityPosition(LocalPlayer.state.ped, false)
        end
    end)
end

-- Function to delete diving crates
function DeleteDivingCrates()
    if _divingCrates[_joiner] then
        for _, crate in pairs(_divingCrates[_joiner]) do
            if DoesEntityExist(crate) then
                DeleteObject(crate)
            end
        end
        _divingCrates[_joiner] = nil
    end
end

-- Function to spawn dynamic crate prop
function SpawnDiveObject(model, coords, cb)
    local model = (type(model) == 'number' and model or GetHashKey(model))
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end
    coords = vector3(coords.x, coords.y, coords.z)
    local obj = CreateObject(model, coords.x, coords.y, coords.z, false, false, true)
    SetModelAsNoLongerNeeded(model)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    if cb then
        cb(obj)
    end
end

-- Function to spawn tier 1 crates
function SpawnRegDivingCrates(nodes, joiner)
    _divingCrates[joiner] = {}
    for _, location in ipairs(nodes) do
        Wait(1)
        SpawnDiveObject('sm_prop_smug_crate_s_bones', location.coords, function(obj)
            table.insert(_divingCrates[joiner], obj)
        end)
    end
end

-- Function to spawn tier 2 crates
function SpawnMidDivingCrates2(nodes, joiner)
    _divingCrates[joiner] = {}
    for _, location in ipairs(nodes) do
        Wait(1)
        SpawnDiveObject('ba_prop_battle_antique_box', location.coords, function(obj)
            table.insert(_divingCrates[joiner], obj)
        end)
    end
end

-- Function to spawn tier 3 crates
function SpawnMidDivingCrates3(nodes, joiner)
    _divingCrates[joiner] = {}
    for _, location in ipairs(nodes) do
        Wait(1)
        SpawnDiveObject('sm_prop_smug_crate_s_jewellery', location.coords, function(obj)
            table.insert(_divingCrates[joiner], obj)
        end)
    end
end

------------------
-- Events/Handlers
------------------

RegisterNetEvent("Diving:Client:OnDuty", function(joiner, time)
    _joiner = joiner
    DeleteWaypoint()
    SetNewWaypoint(-1799.363, -1224.240)
    _blip = Blips:Add("DivingStart", "Underwater Salvage Supervisor", { x = -1799.363, y = -1224.240, z = 0 }, 480, 2, 1.4)

    eventHandlers["keypress"] = AddEventHandler('Keybinds:Client:KeyUp:primary_action', function()
        if _doing then return end
        if _working and not _finished then
            local closest = nil
            for k, v in ipairs(_nodes) do
                local dist = #(vector3(LocalPlayer.state.myPos.x, LocalPlayer.state.myPos.y, LocalPlayer.state.myPos.z) - vector3(v.coords.x, v.coords.y, v.coords.z))
                if dist <= 3.0 then
                    if closest == nil or dist < closest.dist then
                        closest = {
                            dist = dist,
                            point = v,
                        }
                    end
                end
            end

            if closest ~= nil then
                _doing = true
                TaskTurnPedToFaceCoord(LocalPlayer.state.ped, closest.point.coords.x, closest.point.coords.y, closest.point.coords.z, 1.0)
                Citizen.Wait(1000)
                DoDiveAction(closest.point.id)
            else
                _doing = false
            end
        end
    end)

    eventHandlers["startup"] = RegisterNetEvent(string.format("Diving:Client:%s:Startup", joiner), function(nodes, actionLabel, baseDur, anim, boxType)
        Blips:Remove("DivingStart")
    
        if _nodes ~= nil then return end
        _actionLabel = actionLabel
        _actionBaseDur = baseDur
        _actionAnim = anim
        _working = true
        _tasks = 0
        _nodes = nodes
    
        -- Spawn different crates based on the box type
        if boxType == "jewellery" then
            SpawnMidDivingCrates3(nodes, _joiner)
        elseif boxType == "antique" then
            SpawnMidDivingCrates2(nodes, _joiner)
        elseif boxType == "regular" then
            SpawnRegDivingCrates(nodes, _joiner)
        end
    
        for k, v in ipairs(_nodes) do
            Blips:Add(string.format("DivingNode-%s", v.id), "Diving Action", v.coords, 594, 0, 0.8)
        end
    
        Citizen.CreateThread(function()
            while _working do
                local closest = nil
                for k, v in ipairs(_nodes) do
                    local dist = #(vector3(LocalPlayer.state.myPos.x, LocalPlayer.state.myPos.y, LocalPlayer.state.myPos.z) - vector3(v.coords.x, v.coords.y, v.coords.z))
                    if dist <= 30.0 then
                        DrawMarker(1, v.coords.x, v.coords.y, v.coords.z + 0.5, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 1.0, 112, 209, 244, 250, false, false, 2, false, false, false, false)

                        if dist <= 3.0 then
                            Action:Show("diving_node", "{keybind}primary_action{/keybind} Open Crate")
                        else
                            Action:Hide("diving_node")
                        end
                    end
                end
                Citizen.Wait(5)
            end
        end)
    end)

    eventHandlers["actions"] = RegisterNetEvent(string.format("Diving:Client:%s:Action", joiner), function(data)
        for k, v in ipairs(_nodes) do
            if v.id == data then
                Blips:Remove(string.format("DivingNode-%s", v.id))
                Action:Hide("diving_node")
                table.remove(_nodes, k)
                break
            end
        end
    end)

    eventHandlers["return"] = RegisterNetEvent(string.format("Diving:Client:%s:EndDiving", joiner), function()
        _tasks = _tasks + 1
        _nodes = {}
        _state = 3
        DeleteWaypoint()
        SetNewWaypoint(-1799.363, -1224.240)
        _blip = Blips:Add("DivingStart", "Underwater Salvage Supervisor", { x = -1799.363, y = -1224.240, z = 0 }, 480, 2, 1.4)
    end)
end)

AddEventHandler("Diving:Client:TurnIn", function()
    local divingRep = Reputation:GetLevel("Diving")

    Callbacks:ServerCallback('Diving:TurnIn', { divingRep = divingRep, joiner = _joiner })
end)

AddEventHandler("Diving:Client:StartJob", function()
    Callbacks:ServerCallback('Diving:StartJob', _joiner, function(state)
        if not state then
            Notification:Error("Unable To Start Job")
        else
            _state = 1
        end
    end)
end)

AddEventHandler("Diving:Client:SpawnBoat", function()
    Callbacks:ServerCallback("Diving:SpawnBoat", {}, function() end)
end)

AddEventHandler("Diving:Client:BuyScuba", function()
    Callbacks:ServerCallback("Diving:BuyScubaGear", {}, function(success)
        if success then
            Notification:Success("You have purchased a scuba tank.")
        else
            Notification:Error("You do not have enough money.")
        end
    end)
end)

RegisterNetEvent("Diving:Client:OffDuty", function(time)
    for k, v in pairs(eventHandlers) do
        RemoveEventHandler(v)
    end

    if _nodes ~= nil then
        for k, v in ipairs(_nodes) do
            Blips:Remove(string.format("DivingNode-%s", v.id))
        end
    end

    if _blip ~= nil then
        Blips:Remove("DivingStart")
    end

    DeleteDivingCrates()

    _joiner = nil
    _state = 0
    _working = false
    _finished = false
    _blips = {}
    eventHandlers = {}
    _nodes = nil
end)