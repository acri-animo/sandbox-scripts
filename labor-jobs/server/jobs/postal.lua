local _JOB = "Postal"

local _joiners = {}
local _Postal = {}
local _usedMailboxes = {}

local _lootTable = {
    "plastic",
    "iron_bar",
    "aluminum",
    "copper",
    "steel",
}

local postalRoutes = {
    {
        id = 1,
        coords = vector3(-20.631, -1611.848, 29.250),
        location = "South Side",
        radius = 400,
    },
    {
        id = 2,
        coords = vector3(-776.767, -931.633, 18.103),
        location = "Little Seoul",
        radius = 400,
    },
    {
        id = 3,
        coords = vector3(-1052.427, 456.051, 75.545),
        location = "Rockford Hills",
        radius = 400,
    },
    {
        id = 4,
        coords = vector3(962.873, -568.295, 58.862),
        location = "Mirror Park",
        radius = 400,
    },
}

AddEventHandler("Labor:Server:Startup", function()
    Callbacks:RegisterServerCallback("Postal:StartJob", function(source, data, cb)
        if _Postal[data] == nil then
            _Postal[data] = { state = 0 }
        end
        if _Postal[data].state == 0 then
            _Postal[data].state = 1
            Labor.Offers:Task(_joiners[source], _JOB, "Grab a postal van")
            Labor.Workgroups:SendEvent(data, string.format("Postal:Client:%s:Startup", data))
            cb(true)
        else
            cb(false)
        end
    end)

    local _isSpawningVan = false
    Callbacks:RegisterServerCallback("Postal:PostalSpawn", function(source, data, cb)
        if _isSpawningVan then
            cb(false)
            return
        end
        
        local job = _Postal[_joiners[source]]

        if _joiners[source] == nil or job.van ~= nil or job.state ~= 1 then
            cb(false)
            return
        end

        _isSpawningVan = true
        Vehicles:SpawnTemp(source, `boxville2`, 'automobile', vector3(64.487, 122.632, 79.148), 157.757, function(veh, VIN)
            Vehicles.Keys:Add(source, VIN)
            job.van = veh

            local availableRoutes = {}
            for k, v in ipairs(postalRoutes) do
                table.insert(availableRoutes, k)
            end

            local randomRoute = math.random(#availableRoutes)
            job.route = deepcopy(postalRoutes[availableRoutes[randomRoute]])
            table.remove(availableRoutes, randomRoute)
            job.routes = availableRoutes
            job.state = 2
            Labor.Workgroups:SendEvent(_joiners[source], string.format("Postal:Client:%s:NewRoute", _joiners[source]), job.route)
            Labor.Offers:Start(
                _joiners[source],
                _JOB,
                string.format("Deliver Mail in %s", job.route["location"]),
                5
            )
        
            _isSpawningVan = false
            cb(veh)
        end)          
    end)

    Callbacks:RegisterServerCallback("Postal:PostalSpawnRemove", function(source, data, cb)
        local job = _Postal[_joiners[source]]

        if _joiners[source] == nil or job.van == nil or job.state ~= 3 then
            cb(false)
            return
        end

        local vanCoords = GetEntityCoords(job.van)
        local pedCoords = GetEntityCoords(GetPlayerPed(source))
        local distance = #(pedCoords - vanCoords)
        if distance <= 30 then
            Vehicles:Delete(job.van, function()
                job.van = nil
                job.state = 4
                Labor.Workgroups:SendEvent(_joiners[source], string.format("Postal:Client:%s:ReturnVan", _joiners[source]))
                Labor.Offers:Task(_joiners[source], _JOB, "Speak with the Postal Manager")
            end)
        else
            Execute:Client(source, "Notification", "Error", "Van Needs To Be Close By")
        end
    end)

    Callbacks:RegisterServerCallback("Postal:MailDeposit", function(source, data, cb)
        local job = _Postal[_joiners[source]]

        if _joiners[source] == nil or job.state ~= 2 then
            cb(false)
            return
        end

        if job.mailboxes == nil then
           job.mailboxes = {}
        end

        if job.mailboxes[data.mailboxEntity] == nil then
            job.mailboxes[data.mailboxEntity] = true
        else
            Execute:Client(source, "Notification", "Error", "You've already used this mailbox")
            cb(false)
            return
        end

        local char = Fetch:CharacterSource(source)
        if char:GetData("TempJob") == _JOB then
            local luck = math.random(100)
            if luck >= 50 then
                Inventory:AddItem(char:GetData("SID"), _lootTable[math.random(#_lootTable)], 1, {}, 1)
            end

            if Labor.Offers:Update(_joiners[source], _JOB, 1, true) then
                if job.tasks <= 2 then
                    job.tasks = job.tasks + 1
                    local randomRoute = math.random(#job.routes)
                    job.route = deepcopy(postalRoutes[job.routes[randomRoute]])
                    table.remove(job.routes, randomRoute)
                    Labor.Offers:Start(
                        _joiners[source],
                        _JOB,
                        string.format("Deliver Mail in %s", job.route.location),
                        5
                    )

                    Labor.Workgroups:SendEvent(_joiners[source], string.format("Postal:Client:%s:NewRoute", _joiners[source]), job.route)
                else
                    job.state = 3
                    Labor.Workgroups:SendEvent(_joiners[source], string.format("Postal:Client:%s:EndRoutes", _joiners[source]))
                    Labor.Offers:Task(_joiners[source], _JOB, "Return your van")
                end
            end
            cb(true)
        else
            cb(false)
        end
    end)    

    Callbacks:RegisterServerCallback("Postal:TurnIn", function(source, data, cb)
        local job = _Postal[_joiners[source]]
        if _joiners[source] == nil and job.tasks <= 3 then
            Execute:Client(source, "Notification", "Error", "You didn't deliver all the mail")
            cb(false)
            return
        end

        local char = Fetch:CharacterSource(source)
        if char:GetData("TempJob") == _JOB and job.state == 4 then
            Labor.Offers:ManualFinish(_joiners[source], _JOB)
            cb(true)
        else
            Execute:Client(source, "Notification", "Error", "Unable To Finish Job")
            cb(false)
        end
    end)
end)

------------------
-- Events/Handlers
------------------

AddEventHandler("Postal:Server:OnDuty", function(joiner, members, isWorkgroup)
    _joiners[joiner] = joiner
    _Postal[joiner] = {
        joiner = joiner,
        isWorkgroup = isWorkgroup,
        started = os.time(),
        state = 0,
        tasks = 0,
    }

    local char = Fetch:CharacterSource(joiner)
    char:SetData("TempJob", _JOB)
    Phone.Notification:Add(joiner, "Job Activity", "You started a job", os.time(), 6000, "labor", {})
    TriggerClientEvent("Postal:Client:OnDuty", joiner, joiner, os.time())

    Labor.Offers:Task(joiner, _JOB, "Speak with the Postal Manager")
    if #members > 0 then
        for k, v in ipairs(members) do
            _joiners[v.ID] = joiner
            local member = Fetch:CharacterSource(v.ID)
            member:SetData("TempJob", _JOB)
            Phone.Notification:Add(v.ID, "Job Activity", "You started a job", os.time(), 6000, "labor", {})
            TriggerClientEvent("Postal:Client:OnDuty", v.ID, joiner, os.time())
        end
    end
end)

AddEventHandler("Postal:Server:OffDuty", function(source, joiner)
    _joiners[source] = nil
    TriggerClientEvent("Postal:Client:OffDuty", source)
end)

AddEventHandler("Postal:Server:FinishJob", function(joiner)
    _Postal[joiner] = nil
    _usedMailboxes[joiner] = nil
end)