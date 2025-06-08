local _inPoly = nil
local _polys = {}

AddEventHandler("Gym:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
    Logger = exports["lumen-base"]:FetchComponent("Logger")
    Callbacks = exports["lumen-base"]:FetchComponent("Callbacks")
    PedInteraction = exports["lumen-base"]:FetchComponent("PedInteraction")
    Notification = exports["lumen-base"]:FetchComponent("Notification")
    Polyzone = exports["lumen-base"]:FetchComponent("Polyzone")
    Targeting = exports["lumen-base"]:FetchComponent("Targeting")
    Minigame = exports["lumen-base"]:FetchComponent("Minigame")
    Reputation = exports["lumen-base"]:FetchComponent("Reputation")
    Progress = exports["lumen-base"]:FetchComponent("Progress")
    NetSync = exports["lumen-base"]:FetchComponent("NetSync")
    Action = exports["lumen-base"]:FetchComponent("Action")
    Keybinds = exports["lumen-base"]:FetchComponent("Keybinds")
    Inventory = exports["lumen-base"]:FetchComponent("Inventory")
end

AddEventHandler("Core:Shared:Ready", function()
    exports["lumen-base"]:RequestDependencies("Gym", {
        "Logger",
        "Callbacks",
        "PedInteraction",
        "Notification",
        "Polyzone",
        "Targeting",
        "Minigame",
        "Reputation",
        "Progress",
        "NetSync",
        "Action",
        "Keybinds",
        "Inventory",
    }, function(error)
        if #error > 0 then
            return
        end
        RetrieveComponents()
        TriggerEvent("Gym:Client:Setup")
    end)
end)

AddEventHandler("Gym:Client:Setup", function()
    PedInteraction:Add("GymPed", GetHashKey("a_m_y_beach_03"), vector3(-1201.103, -1577.631, 3.608), 306.561, 25.0, {
        {
            icon = "dumbbell",
            text = "Purchase Gym Pass - $500",
            event = "Gym:Client:PurchasePass",
        },
        -- {
        --     icon = "list-check",
        --     text = "Open Task Menu",
        --     event = "Gym:Client:OpenTaskMenu",
        -- },
    }, "dumbbell")

    _polys = {}
    for k, v in ipairs(_exercisesBeach) do
        Polyzone.Create:Box(v.id, v.coords, v.width, v.length, v.options)
        _polys[v.id] = true
    end
end)

AddEventHandler("Gym:Client:PurchasePass", function()
    Callbacks:ServerCallback("Gym:PurchasePass", {}, function(success)
        if success then
            Notification:Success("You have purchased a gym pass!", 5000)
        else
            Notification:Error("Check bank balance", 5000)
        end
    end)
end)

AddEventHandler("Gym:Client:OpenTaskMenu", function()
    print("Opening task menu")
end)

AddEventHandler("Polyzone:Enter", function(id, testedPoint, insideZones, data)
    if _polys[id] then
        LocalPlayer.state:set("inGymPoly", id, true)
        _inPoly = id

        Action:Show("lumen_gym", "{keybind}primary_action{/keybind} Start Exercise")
    end
end)

AddEventHandler("Polyzone:Exit", function(id, testedPoint, insideZones, data)
    if _polys[id] then
        if LocalPlayer.state.inGymPoly == id then
            LocalPlayer.state:set("inGymPoly", nil, true)
        end
        _inPoly = nil
        Action:Hide("lumen_gym")
    end
end)

AddEventHandler("Keybinds:Client:KeyUp:primary_action", function()
    if LocalPlayer.state.inGymPoly == nil then
        return
    end

    if not Inventory.Check.Player:HasItem("gym_pass", 1) then
        Notification:Error("You need a gym pass to use the gym equipment.", 5000)
        return
    end

    local data = {}

    for k, v in ipairs(_exercisesBeach) do
        if v.id == LocalPlayer.state.inGymPoly then
            data = v
            break
        end
    end

    for k, v in ipairs(_exercisesPrison) do
        if v.id == LocalPlayer.state.inGymPoly then
            data = v
            break
        end
    end

    local workoutData = {
        id = data.id,
        name = data.type,
        action = data.action,
        position = data.position,
        heading = data.pHeading,
        anim = data.anim,
    }

    TriggerEvent("Gym:Client:StartExercise", workoutData)
end)

function getCooldownDur(repLevel)
    local baseCooldown = 60000
    local reduction = math.min(0.9, 0.01 * repLevel)
    return math.floor(baseCooldown * (1 - reduction))
end

function isExerciseOnCooldown(eType)
    if not eType or type(eType) ~= "string" then
        return false
    end

    local cooldowns = LocalPlayer.state.exerciseCooldown or {}
    local lastPerformed = cooldowns[eType] and cooldowns[eType].time or 0
    local repLevel = Reputation:GetLevel("Gym") or 0
    local cdDuration = getCooldownDur(repLevel)
    local currentTime = GetGameTimer()

    if currentTime - lastPerformed < cdDuration then
        Notification:Error("Try again after some rest", 5000)
        return true
    end

    if cooldowns[eType] then
        cooldowns[eType] = nil
        LocalPlayer.state:set("exerciseCooldown", cooldowns, true)
    end

    return false
end

function setExerciseCD(eType)
    if not eType or type(eType) ~= "string" then
        return
    end

    local cooldowns = LocalPlayer.state.exerciseCooldown or {}
    local currentTime = GetGameTimer()

    cooldowns[eType] = {
        type = eType,
        time = currentTime,
    }

    LocalPlayer.state:set("exerciseCooldown", cooldowns, true)
end

function performWorkout(eType, animation, string, cb)
    Progress:Progress({
        name = "gym_progress_" .. eType,
        duration = math.random(15000, 25000),
        label = string,
        useWhileDead = false,
        canCancel = true,
        vehicle = false,
        animation = {
            anim = animation,
        },
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableCombat = true,
        },
    }, function(cancelled)
        if not cancelled then
            Callbacks:ServerCallback("Gym:UpdateRep", { type = eType, amount = 1 }, function(success)
                if success then
                    setExerciseCD(eType)
                    Notification:Success("Excercise completed", 3500)
                    if cb then
                        cb(true)
                    end
                else
                    Notification:Error("Failed to complete exercise", 5000)
                    if cb then
                        cb(false)
                    end
                end
            end)
        else
            if cb then
                cb(false)
            end
        end
    end)
end

function startSingleWorkout(eType, anim, string, position, heading)
    if isExerciseOnCooldown(eType) then
        return
    end

    SetEntityCoords(LocalPlayer.state.ped, position.x, position.y, position.z)
    SetEntityHeading(LocalPlayer.state.ped, heading)
    performWorkout(eType, anim, string)
end

-- function startDoubleWorkout(eType, anim, string, position, heading)
--     if isExerciseOnCooldown(eType) then
--         return
--     end

--     SetEntityCoords(LocalPlayer.state.ped, position.x, position.y, position.z)
--     SetEntityHeading(LocalPlayer.state.ped, heading)

--     performWorkout(eType, anim, string, function(success)
--         if success then
--             Minigame.Play:RoundSkillbar(2.0, 3, {
--                 onSuccess = function()
--                     Notification:Success("You are feeling pumped!", 5000)
--                     while LocalPlayer.state.doingAction do
--                         Citizen.Wait(100)
--                     end
--                     startSingleWorkout(eType, anim, string, position, heading)
--                 end,
--                 onFail = function()
--                     setExerciseCD(eType)
--                 end,
--             }, {
--                 useWhileDead = false,
--                 vehicle = false,
--                 controlDisables = {
--                     disableMovement = true,
--                     disableCarMovement = true,
--                     disableCombat = true,
--                 },
--                 animation = {
--                     anim = "idle",
--                 },
--             })
--         end
--     end)
-- end

AddEventHandler("Gym:Client:StartExercise", function(data)
    if data == nil then return end

    if LocalPlayer.state.inGymPoly == nil then
        Notification:Error("You are not in a gym area", 5000)
        return
    end

    if not LocalPlayer.state.exerciseCooldown then
        LocalPlayer.state:set("exerciseCooldown", {}, true)
    end

    Action:Hide("lumen_gym")

    local exerciseType = data.name
    local progString = data.action
    local position = data.position
    local heading = data.heading
    local animation = data.anim
    
    startSingleWorkout(exerciseType, animation, progString, position, heading)
end)