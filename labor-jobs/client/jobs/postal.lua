local _joiner = nil
local _working = false
local _blip = nil
local _blips = {}
local eventHandlers = {}
local _entities = {}
local _state
local _route = nil
local location = nil

local postalBoxes = {
    `prop_postbox_01a`,
    `prop_postbox_ss_01a`,
    `prop_letterbox_01`,
    `prop_letterbox_02`,
    `prop_letterbox_03`,
    `prop_letterbox_04`,
    `prop_news_disp_01a`,
    `prop_news_disp_02a`,
    `prop_news_disp_02d`,
}

AddEventHandler("Labor:Client:Setup", function()
    PedInteraction:Add("PostalJob", GetHashKey("s_m_m_postal_01"), vector3(78.886, 112.563, 80.168), 164.319, 25.0, {
        {
            icon = "handshake-angle",
            text = "Start Work",
            event = "Postal:Client:StartJob",
            tempjob = "Postal",
            isEnabled = function()
                return not _working
            end,
        },
        {
            icon = "truck-fast",
            text = "Borrow Postal Van",
            event = "Postal:Client:PostalSpawn",
            tempjob = "Postal",
            isEnabled = function()
                return _working and _state == 1
            end,
        },
        {
            icon = "reply-all",
            text = "Return Postal Van",
            event = "Postal:Client:PostalSpawnRemove",
            tempjob = "Postal",
            isEnabled = function()
                return _working and _state == 3
            end,
        },
        {
            icon = "money-check-dollar",
            text = "Complete Job",
            event = "Postal:Client:TurnIn",
            tempjob = "Postal",
            isEnabled = function()
                return _working and _state == 4
            end,
        },
    }, "envelopes-bulk")
end)

------------------
-- Events/Handlers
------------------

RegisterNetEvent("Postal:Client:OnDuty", function(joiner, time)
    _joiner = joiner
    DeleteWaypoint()
    SetNewWaypoint(78.886, 112.563)

    _blip = Blips:Add("PostalStart", "Postal Manager", { x = 78.886, y = 112.563, z = 0 }, 480, 2, 1.4)

    eventHandlers["startup"] = RegisterNetEvent(string.format("Postal:Client:%s:Startup", joiner), function()
        _working = true
        for k, v in ipairs(postalBoxes) do
            Targeting:AddObject(v, "envelope", {
                {
                    icon = "hand",
                    text = "Collect Mail",
                    event = "Postal:Client:MailDeposit",
                    data = "Postal",
                    isEnabled = function(data, entity)
                        if not _working or _state ~= 2 or not entity.entity or not LocalPlayer.state.inPostalZone then
                            return false
                        end

                        local entity = entity.entity

                        if not NetworkGetEntityIsNetworked(entity) then
                            NetworkRegisterEntityAsNetworked(entity)
                        end

                        local netId = NetworkGetNetworkIdFromEntity(entity)
                        return netId ~= 0 and (not _entities[netId])
                    end,                    
                },
            }, 3.0)
        end

        Citizen.CreateThread(function()
            while _working do
                if _route ~= nil then
                    local dist = #(
                        vector3(LocalPlayer.state.myPos.x, LocalPlayer.state.myPos.y, LocalPlayer.state.myPos.z)
                        - vector3(_route.coords.x, _route.coords.y, _route.coords.z)
                    )
                    if dist <= (_route.radius / 2) then
                        LocalPlayer.state.inPostalZone = true
                    else
                        LocalPlayer.state.inPostalZone = false
                    end
                end
                Citizen.Wait(1000)
            end
        end)
    end)

    eventHandlers["new-route"] = RegisterNetEvent(string.format("Postal:Client:%s:NewRoute", joiner), function(r)
		_state = 2
		_route = r
		DeleteWaypoint()
		SetNewWaypoint(_route.coords)

		if _blip ~= nil then
			Blips:Remove("PostalStart")
			RemoveBlip(_blip)
			_blip = nil
		end
		_blip = AddBlipForRadius(_route.coords.x, _route.coords.y, _route.coords.maxZ, (_route.radius / 2) + 0.0)
		SetBlipColour(_blip, 3)
		SetBlipAlpha(_blip, 90)
	end)

    eventHandlers["mail-deposit"] = AddEventHandler("Postal:Client:MailDeposit", function(entity, data)
        local entity = entity.entity

        if not entity or not DoesEntityExist(entity) then
            Notification:Error("Invalid mailbox.")
            return
        end

        if not NetworkGetEntityIsNetworked(entity) then
            NetworkRegisterEntityAsNetworked(entity)
        end

        local netId = NetworkGetNetworkIdFromEntity(entity)
        if netId == 0 then
            Notification:Error("Invalid mailbox.")
            return
        end

        -- Progress bar when collecting mail
        Progress:Progress({
            name = "mail_deposit",
            duration = math.random(20, 25) * 1000,
            label = "Collecting Mail",
            useWhileDead = false,
            canCancel = true,
            vehicle = false,
            animation = {
                anim = "search",
            },
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableCombat = true,
            },
        }, function(cancelled)
            if not cancelled then
                Callbacks:ServerCallback("Postal:MailDeposit", { mailboxEntity = netId }, function(s)
                    if s then
                        _entities[netId] = true
                    end
                end)
            end
        end)
    end)

    eventHandlers["spawn-van"] = AddEventHandler("Postal:Client:PostalSpawn", function()
        Callbacks:ServerCallback("Postal:PostalSpawn", {}, function(animo)
            if not animo then
                Notification:Error("Attempting to spawn postal van you pepega.")
                return
            end
            SetEntityAsMissionEntity(entity)
        end)
    end)
    
    eventHandlers["end-pickup"] = RegisterNetEvent(string.format("Postal:Client:%s:EndRoutes", joiner), function()
        DeleteWaypoint()
        SetNewWaypoint(78.886, 112.563)
        if _blip ~= nil then
            Blips:Remove("PostalStart")
            RemoveBlip(_blip)
            _blip = nil
        end
        _blip = Blips:Add("PostalStart", "Postal Manager", { x = 78.886, y = 112.563, z = 0 }, 480, 2, 1.4)
        _state = 3
    end)

    eventHandlers["despawn-van"] = AddEventHandler("Postal:Client:PostalSpawnRemove", function()
        Callbacks:ServerCallback("Postal:PostalSpawnRemove", {})
    end)

    eventHandlers["return-van"] = RegisterNetEvent(string.format("Postal:Client:%s:ReturnVan", joiner), function()
        _state = 4
    end)

    eventHandlers["turn-in"] = AddEventHandler("Postal:Client:TurnIn", function()
        Callbacks:ServerCallback("Postal:TurnIn", _joiner)
    end)
end)

AddEventHandler("Postal:Client:StartJob", function()
    Callbacks:ServerCallback("Postal:StartJob", _joiner, function(success)
        if not success then
            Notification:Error("Unable To Start Job")
        end
        _state = 1
    end)
end)

RegisterNetEvent("Postal:Client:OffDuty", function(time)
    for k, v in pairs(eventHandlers) do
        RemoveEventHandler(v)
    end

    for k, v in ipairs(postalBoxes) do
        Targeting:RemoveObject(v)
    end

    if _blip ~= nil then
        Blips:Remove("PostalStart")
        RemoveBlip(_blip)
        _blip = nil
    end

    eventHandlers = {}
    _joiner = nil
    _working = false
    MailObject = nil
    _state = 0
end)