local _joiner = nil
local _working = false
local _finished = false
local _graves = nil
local _tasks = 0
local _blips = {}
local _blip = nil
local _state = 0
local eventHandlers = {}
local _activePeds = {}

AddEventHandler("Labor:Client:Setup", function()
    PedInteraction:Add("HalloweenJob", `cs_dreyfuss`, vector3(-1684.823, -291.388, 50.890), 148.318, 50.0, {
        {
            icon = "clipboard",
            text = "Start Job",
            event = "Halloween:Client:StartJob",
            tempjob = "Halloween",
            isEnabled = function()
                return not _working
            end,
        },
        {
            icon = "handshake",
            text = "Finish Job",
            event = "Halloween:Client:TurnIn",
            tempjob = "Halloween",
            isEnabled = function()
                return _working and _state == 3
            end,
        },
        {
            icon = "money-bill",
            text = "Sell Bones",
            event = "Halloween:Client:SellBones",
        },
    }, 'coffin-cross', 'WORLD_HUMAN_SMOKING')

    PedInteraction:Add("GraveDigJobStarter", `g_m_m_chicold_01`, vector3(-956.471, -1302.913, 17.020), 144.159, 30.0, {
        {
            icon = "clipboard",
            text = "Talk to Phantom Guard",
            event = "Halloween:Client:Enable",
            data = {},
        },
    }, 'block-question', 'WORLD_HUMAN_SMOKING')

    PedInteraction:Add("OrganVendor", `s_m_m_scientist_01`, vector3(-1185.020, -530.854, 42.049), 42.616, 30.0, {
        {
            icon = "lungs",
            text = "Sell items",
            event = "Halloween:Client:SellOrganMenu",
            data = {},
        },
    }, 'block-question', 'WORLD_HUMAN_SMOKING')

end)


local _doing = false
function DigAction(id)
    Progress:ProgressWithTickEvent({
        name = 'digging_action',
        duration = math.random(5,7) * 1000,
        label = 'Digging Grave',
        tickrate = 1000,
        useWhileDead = false,
        canCancel = true,
        vehicle = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableCombat = true,
        },
        animation = {
            anim = "dig",
        },
    }, function()
        if not _doing then return end
        if _graves ~= nil then
            for k, v in ipairs(_graves) do
                if v.id == id then
                    return
                end
            end
        end
        Progress:Cancel()
    end, function(cancelled)
        _doing = false
        if not cancelled then
            Callbacks:ServerCallback("Halloween:GraveDigger", id)
            TriggerEvent("Halloween:Client:SpawnZombie", id)
        end
    end)
end


RegisterNetEvent("Halloween:Client:OnDuty", function(joiner, time)
    _joiner = joiner
    DeleteWaypoint()
    SetNewWaypoint(-1693.668, -289.686)
    _blip = Blips:Add("HalloweenStart", "Cemetery Groundskeeper", { x = -1693.668, y = -289.686, z = 0 }, 480, 2, 1.4)

    eventHandlers["keypress"] = AddEventHandler('Keybinds:Client:KeyUp:primary_action', function()
        if _doing then return end
        if _working and not _finished then
            local closest = nil
            for k, v in ipairs(_graves) do
                local dist = #(vector3(LocalPlayer.state.myPos.x, LocalPlayer.state.myPos.y, LocalPlayer.state.myPos.z) - vector3(v.coords.x, v.coords.y, v.coords.z))
                if dist <= 2.0 then
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
                DigAction(closest.point.id)
            else
                _doing = false
            end
        end
    end)

    eventHandlers["startup"] = RegisterNetEvent(string.format("Halloween:Client:%s:Startup", joiner), function (graves)
        Blips:Remove("HalloweenStart")

        if _graves ~= nil then return end
        _working = true
        _tasks = 0
        _graves = graves

        for k, v in ipairs(_graves) do
            Blips:Add(string.format("Grave:%s", v.id), "Grave Digging", v.coords, 594, 0, 0.8)
        end

        Citizen.CreateThread(function()
            while _working do
                local closest = nil
                for k, v in ipairs(_graves) do
                    local dist = #(vector3(LocalPlayer.state.myPos.x, LocalPlayer.state.myPos.y, LocalPlayer.state.myPos.z) - vector3(v.coords.x, v.coords.y, v.coords.z))
                    if dist <= 20 then
                        DrawMarker(27, v.coords.x, v.coords.y, v.coords.z + 0.25, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 1.0, 112, 209, 244, 250, false, false, 2, false, false, false, false)
                    end
                end
                Citizen.Wait(5)
            end
        end)
    end)

    eventHandlers["action"] = RegisterNetEvent(string.format("Halloween:Client:%s:Action", joiner), function(data)
        for k, v in ipairs(_graves) do
            if v.id == data then
                Blips:Remove(string.format("Grave:%s", v.id))
                table.remove(_graves, k)
                break
            end
        end
    end)

    eventHandlers["return"] = RegisterNetEvent(string.format("Halloween:Client:%s:EndHalloween", joiner), function()
        _tasks = _tasks + 1
        _graves = {}
        _state = 3
        DeleteWaypoint()
        SetNewWaypoint(-1693.668, -289.686)
        _blip = Blips:Add("HalloweenStart", "Zombie Leader", { x = -1693.668, y = -289.686, z = 0 }, 480, 2, 1.4)
    end)
end)


AddEventHandler("Halloween:Client:TurnIn", function()
    Callbacks:ServerCallback('Halloween:TurnIn', _joiner)
end)

AddEventHandler("Halloween:Client:Enable", function()
    Callbacks:ServerCallback('Halloween:Enable', {})
end)

AddEventHandler("Halloween:Client:StartJob", function()
    Callbacks:ServerCallback('Halloween:StartJob', _joiner, function(state)
        if not state then
            Notification:Error("Unable To Start Job")
        else
            _state = 1
        end
    end)
end)

AddEventHandler("Halloween:Client:SellBones", function()
    Callbacks:ServerCallback("Halloween:Server:SellBones", {}, function(success)
        if success then
            Notification:Success("You sold the bones!")
        else
            Notification:Error("Failed to sell the bones.")
        end
    end)
end)

AddEventHandler("Halloween:Client:SpawnZombie", function(graveId)
    local zombieModel = `u_m_y_zombie_01`
    local nonZombieModels = {
        `ig_old_man1a`,
        `ig_old_man2`,
        `a_m_o_acult_01`,
        `a_m_o_acult_02`,
        `a_m_y_acult_01`,
        `a_m_y_acult_02`,
    }

    local isZombie = math.random(1, 100) <= 10
    local model = isZombie and zombieModel or nonZombieModels[math.random(#nonZombieModels)]

    loadModel(model)

    local pCoords = GetEntityCoords(PlayerPedId())
    local pHeading = GetEntityHeading(PlayerPedId())
    local frontx = GetEntityForwardX(PlayerPedId())

    local zombiePed = CreatePed(4, model, pCoords.x + frontx, pCoords.y, pCoords.z, pHeading - 180, false, true)
    SetEntityAsMissionEntity(zombiePed, true, true)

    _activePeds[zombiePed] = { ped = zombiePed, graveId = graveId }

    if isZombie then
        StopPedSpeaking(zombiePed, true)
        DisablePedPainAudio(zombiePed, true)
        SetPedArmour(zombiePed, 50)
        SetPedAccuracy(zombiePed, 25)
        SetPedFleeAttributes(zombiePed, 0, false)
        TaskCombatPed(zombiePed, PlayerPedId(), 0, 16)
    else
        loadAnim("dead")
        StopPedSpeaking(zombiePed, true)
        DisablePedPainAudio(zombiePed, true)
        TaskPlayAnim(zombiePed, "dead", "dead_a", 3.0, -3.0, -1, 1, 0, 0, 0, 0)
        SetEntityHealth(zombiePed, 0)
        RemoveAnimDict("dead")
    end

    SetModelAsNoLongerNeeded(model)

    local bodyType
    local graveRep = Reputation:GetLevel("Halloween") or 1
    local organChance = math.min(graveRep * 10, 40)
    local randomChance = math.random(1, 100)

    if randomChance <= organChance then
        bodyType = "organs"
    else
        bodyType = "bones"
    end

    Targeting:AddPed(zombiePed, "knife-kitchen", {
        {
            icon = "bone",
            text = "Salvage Bones",
            event = "Halloween:Client:SalvageBones",
            data = { type = bodyType, ped = zombiePed },
            minDist = 3.0,
            isEnabled = function(data, entity)
                return _working and IsPedDeadOrDying(entity.entity)
            end,
        },
    }, 3.0)
end)


RegisterNetEvent("Halloween:Client:OffDuty", function(time)
    for k, v in pairs(eventHandlers) do
        RemoveEventHandler(v)
    end

    if _graves ~= nil then
        for k, v in ipairs(_graves) do
            Blips:Remove(string.format("Grave:%s", v.id))
        end
    end

    if _blip ~= nil then
        Blips:Remove("HalloweenStart")
    end

    for ped, data in pairs(_activePeds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    _activePeds = {}

    _joiner = nil
    _state = 0
    _working = false
    _finished = false
    _blips = {}
    eventHandlers = {}
    _graves = nil
end)


local stageComplete = 0
function DoDigGame(data, base, cb)
	local size = 10 - (stageComplete * 2)
	if size <= 1 then
		size = 2
	end

	Minigame.Play:RoundSkillbar(base + (0.2 * stageComplete), size, {
		onSuccess = function()
            Citizen.Wait(400)

			if stageComplete >= (data.stages or 3) then
				stageComplete = 0

				cb(true)
			else
				stageComplete += 1
				DoDigGame(data, base, cb)
			end
		end,
		onFail = function()
			stageComplete = 0
            TriggerServerEvent("Halloween:Server:NotifyPigs", coords)

			cb(false)
		end,
	}, {
		useWhileDead = false,
		vehicle = false,
		animation = {
            animDict = "Scenario",
			anim = "CODE_HUMAN_MEDIC_KNEEL",
            flags = 2,
		},
	})
end

AddEventHandler("Halloween:Client:SalvageBones", function(entity, data)
    if not data or not data.type or not data.ped then
        Notification:Error("Invalid data provided.")
        return
    end

    local loot = data.type
    local targetPed = data.ped

    if loot == "organs" then
        DoDigGame({ stages = 3 }, 2.0, function(status)
            if status then
                while LocalPlayer.state.doingAction do
                    Citizen.Wait(100)
                end
                Progress:Progress({
                    name = 'salvaging_organs',
                    duration = math.random(12000,15000),
                    label = 'Salvaging Organs',
                    useWhileDead = false,
                    canCancel = true,
                    vehicle = false,
                    animation = {
                        anim = "kneel",
                    },
                    controlDisables = {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableCombat = true,
                    },
                }, function(cancelled)
                    if not cancelled then
                        Callbacks:ServerCallback("Halloween:GetLoot", { loot = loot }, function(lumen)
                            if lumen then
                                if DoesEntityExist(targetPed) then
                                    DeleteEntity(targetPed)
                                    _activePeds[targetPed] = nil
                                end
                                Notification:Success("You looted the body!")
                            end
                        end)
                    end
                end)
            end
        end)
    else
        Progress:Progress({
            name = 'salvaging_bones',
            duration = math.random(12000,15000),
            label = 'Salvaging Bones',
            useWhileDead = false,
            canCancel = true,
            vehicle = false,
            animation = {
                anim = "medic",
            },
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableCombat = true,
            },
        }, function(cancelled)
            if not cancelled then
                Callbacks:ServerCallback("Halloween:GetLoot", { loot = loot }, function(success) 
                    if success then
                        if DoesEntityExist(targetPed) then
                            DeleteEntity(targetPed)
                            _activePeds[targetPed] = nil
                        end
                        Notification:Success("You looted the body!")
                    else
                        Notification:Error("Failed to loot the body.")
                    end
                end)
            end
        end)
    end
end)


AddEventHandler("Halloween:Client:SellOrganMenu", function()
    ListMenu:Show({
        main = {
            label = "Sell Human Organs",
            items = {
                {
                    label = 'Kidney',
                    description = 'Sell human kidneys',
                    event = 'Halloween:Client:SellOrgans',
                    data = { organ = "kidney" },
                    disabled = not Inventory.Check.Player:HasItem("kidney", 1)
                },
                {
                    label = 'Liver',
                    description = 'Sell human liver',
                    event = 'Halloween:Client:SellOrgans',
                    data = { organ = "liver" },
                    disabled = not Inventory.Check.Player:HasItem("liver", 1)
                },
                {
                    label = 'Lung',
                    description = 'Sell human lung',
                    event = 'Halloween:Client:SellOrgans',
                    data = { organ = "lung" },
                    disabled = not Inventory.Check.Player:HasItem("lung", 1)
                },
                {
                    label = 'Heart',
                    description = 'Sell human heart',
                    event = 'Halloween:Client:SellOrgans',
                    data = { organ = "heart" },
                    disabled = not Inventory.Check.Player:HasItem("heart", 1)
                },
                {
                    label = 'Brain',
                    description = 'Sell human brain',
                    event = 'Halloween:Client:SellOrgans',
                    data = { organ = "brain" },
                    disabled = not Inventory.Check.Player:HasItem("brain", 1)
                },
            }
        }
    })
end)

AddEventHandler("Halloween:Client:SellOrgans", function(data)
    Callbacks:ServerCallback("Halloween:Server:SellOrgans", data, function(success)
        if success then
            Notification:Success("You sold the organ(s)!")
        else
            Notification:Error("Failed to sell the organ.")
        end
    end)
end)