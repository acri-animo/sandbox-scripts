local _JOB = "Trucking"

local _joiners = {}
local _trucking = {}

-- Function to distribute loot based on job type, level, and reputation (only the group leader gets the reward otherwise it would be broken)
local function distributeLoot(source, job)
    local char = Fetch:CharacterSource(source)
    local SID = char:GetData("SID")
    local repLevel = Reputation:GetLevel(source, "Trucking")
    local multiplier = 1.0 + (repLevel * 0.1)

    for _, loot in ipairs(job.itemRewards) do
        local chance = math.random(100)
        if chance <= loot[1] then
            local amount = math.floor(loot[3] * multiplier)
            
            Inventory:AddItem(SID, loot[2], amount, {}, 1)
        end
    end
end

-- Function to get the vehicle/trailer model for the job
local function GetVehicleModelsForJob(data)
    local job = trucking.jobs[data.type][data.level]
    if job and job.truck and job.trailer then
        return job.truck, job.trailer
    end
    return nil, nil
end


-- Startup event
AddEventHandler("Labor:Server:Startup", function()
    Callbacks:RegisterServerCallback("Trucking:StartJob", function(source, data, cb)
        local joiner = data.joiner
    
        if _trucking[joiner] ~= nil and _trucking[joiner].state == 0 then
            -- The line below copies the job config based on the type of job player selects from the menu
            _trucking[joiner].job = deepcopy(trucking.jobs[data.type][data.level])
    
            if not _trucking[joiner].job then
                print("No job configuration found")
                cb(false)
                return
            end
            
            -- Establishes the job type and level for group
            _trucking[joiner].type = data.type
            _trucking[joiner].level = data.level
    
            -- Randomly selects a dropoff location for the job from the config
            local randomDropoff = _trucking[joiner].job.dropoffLocations[math.random(#_trucking[joiner].job.dropoffLocations)]
    
            -- Sends the event to the client to start the job
            Labor.Offers:Task(joiner, _JOB, "Get Truck and Trailer from Trucking Foreman")
            Labor.Workgroups:SendEvent(
                joiner,
                string.format("Trucking:Client:%s:Startup", joiner),
                randomDropoff,
                _trucking[joiner].job.dropString,
                _trucking[joiner].job.dropProg,
                _trucking[joiner].job.dropPed
            )
    
            _trucking[joiner].state = 1
            cb(true)
        else
            cb(false)
        end
    end)
    
    -- Callback to spawn the truck and trailer for the job
    Callbacks:RegisterServerCallback("Trucking:TruckTrailerSpawn", function(source, data, cb)
        local truckingData = _trucking[_joiners[source]]
        if not truckingData or not truckingData.type or not truckingData.level then
            Execute:Client(source, "Notification", "Error", "Job configuration not found.")
            cb(false)
            return
        end
    
        local truckModel, trailerModel = GetVehicleModelsForJob(truckingData)
        if not truckModel or not trailerModel then
            Execute:Client(source, "Notification", "Error", "Vehicle configuration not found.")
            cb(false)
            return
        end
    
        if truckingData.truck == nil and truckingData.state == 1 then
            local truckCoords = vector3(1244.750, -3155.875, 5.528) -- Truck spawn coords
            local trailerCoords = vector4(1273.899, -3185.859, 5.904, 92.829) -- Trailer spawn coords
    
            -- Spawn truck
            Vehicles:SpawnTemp(source, truckModel, 'automobile', truckCoords, 271.579, function(truck, VIN)
                Vehicles.Keys:Add(source, VIN)
                truckingData.truck = truck
    
                -- Spawn trailer
                Vehicles:SpawnTemp(source, trailerModel, 'trailer', vector3(trailerCoords.x, trailerCoords.y, trailerCoords.z), trailerCoords.w, function(trailer, VIN)
                    truckingData.trailer = trailer
                    truckingData.state = 2
                    Labor.Offers:Task(_joiners[source], _JOB, "Hook up the Trailer")
                    Labor.Workgroups:SendEvent(_joiners[source], string.format("Trucking:Client:%s:TruckTrailerSpawn", _joiners[source]))
                    Labor.Workgroups:SendEvent(_joiners[source], string.format("Trucking:Client:%s:UpdateWaypoint", _joiners[source]), "trailer", { x = trailerCoords.x, y = trailerCoords.y, z = trailerCoords.z })
    
                    cb(true)
                end)
            end)
        else
            Execute:Client(source, "Notification", "Error", "Truck already spawned or state is incorrect.")
            cb(false)
        end
    end)

    -- Callback to dropoff the trailer
    Callbacks:RegisterServerCallback("Trucking:DropoffTrailer", function(source, data, cb)
        local truckingData = _trucking[_joiners[source]]
    
        if truckingData ~= nil and truckingData.state == 3 then
            local trailerCoords = GetEntityCoords(truckingData.trailer)
            local truckCoords = GetEntityCoords(truckingData.truck)
            local pedCoords = vector3(data.pedCoords.x, data.pedCoords.y, data.pedCoords.z)
            local distance = #(pedCoords - trailerCoords)
            local truckDistance = #(pedCoords - truckCoords)
    
            -- Distance check to ensure the truck is close to the dropoff ped
            if distance <= 25 and truckDistance <= 25 then
                Vehicles:Delete(truckingData.trailer, function()
                    local char = Fetch:CharacterSource(source)
    
                    if char:GetData("TempJob") ~= _JOB then
                        Execute:Client(source, "Notification", "Error", "You are not on the Trucking job.")
                        cb(false)
                        return
                    end
                    
                    -- This establishes the type/level for job reward
                    local job = trucking.jobs[truckingData.type][truckingData.level]
                    if not job then
                        Execute:Client(source, "Notification", "Error", "Job configuration not found.")
                        cb(false)
                        return
                    end
    
                    if truckingData.type == "illegal" then
                        -- The truckingData.level corresponds with the menu selection on client side (level 17 & 19 for illegal and level 10 for legal only have cash rewards right now)
                        if truckingData.level == 17 then
                            Wallet:Modify(source, math.random(5000,6000))
                        elseif truckingData.level == 19 then
                            Wallet:Modify(source, math.random(8000,10000))
                        else
                            distributeLoot(source, job)
                        end
                    else
                        if truckingData.level == 10 then
                            Wallet:Modify(source, math.random(4000,6000))
                        else
                            distributeLoot(source, job)
                        end
                    end
    
                    truckingData.trailer = nil
                    truckingData.state = 4
                    Labor.Offers:Task(_joiners[source], _JOB, "Return the Truck to the Docks")
                    Labor.Workgroups:SendEvent(_joiners[source], string.format("Trucking:Client:%s:UpdateWaypoint", _joiners[source]), "docks")
    
                    cb(true)
                end)
            else
                Execute:Client(source, "Notification", "Error", "Trailer and truck need to be nearby.")
                cb(false)
            end
        else
            Execute:Client(source, "Notification", "Error", "Invalid state for dropoff.")
            cb(false)
        end
    end)

    -- Callback to spawn the mf peds
    Callbacks:RegisterServerCallback("Trucking:SpawnMfPeds", function(source, data, cb)
        local truckPeds = {}
        local pedCoords = data.coords
        for i = 1, 8 do
            local p = CreatePed(5, `mp_m_fibsec_01`, pedCoords.x + math.random(-1.0, 1.0), pedCoords.y + math.random(-1.0, 1.0), pedCoords.z, math.random(360) * 1.0, true, true)
            local w = `WEAPON_PISTOL`
            Entity(p).state.crimePed = true
            GiveWeaponToPed(p, w, 99999, false, true)
            SetCurrentPedWeapon(p, w, true)
            SetPedArmour(p, 500)

            while not DoesEntityExist(p) do
                Citizen.Wait(1)
            end

            table.insert(truckPeds, NetworkGetNetworkIdFromEntity(p))
            Citizen.Wait(300)

            Callbacks:ClientCallback(source,"Trucking:Client:SpawnMfPeds", { peds = truckPeds }, function() end)
        end
    end)

    -- Callback to complete the job
    Callbacks:RegisterServerCallback("Trucking:CompleteJob", function(source, data, cb)
        local truckingData = _trucking[_joiners[source]]
    
        if truckingData ~= nil and truckingData.state == 4 then
            local truckCoords = GetEntityCoords(truckingData.truck)
            local pedCoords = GetEntityCoords(GetPlayerPed(source))
            local distance = #(pedCoords - truckCoords)
    
            -- Distance check to ensure the truck is close to the player when turning in job (truck won't despawn if truck is too far away)
            if distance <= 25 then
                Vehicles:Delete(truckingData.truck, function()
                    truckingData.truck = nil
                    Labor.Workgroups:SendEvent(_joiners[source], string.format("Trucking:Client:%s:CompleteJob", _joiners[source]))
                    Labor.Offers:ManualFinish(_joiners[source], _JOB)
                end)
                cb(true)
            else
                Execute:Client(source, "Notification", "Error", "Truck needs to be nearby")
                cb(false)
            end
        else
            Execute:Client(source, "Notification", "Error", "Invalid state for completion")
            cb(false)
        end
    end)    
end)

------------------
-- Events/Handlers
------------------

AddEventHandler("Trucking:Server:OnDuty", function(joiner, members, isWorkgroup)
    _joiners[joiner] = joiner
    _trucking[joiner] = {
        joiner = joiner,
        isWorkgroup = isWorkgroup,
        started = os.time(),
        state = 0,
        isIllegal = false,
    }

    local char = Fetch:CharacterSource(joiner)
    char:SetData("TempJob", _JOB)
    Phone.Notification:Add(joiner, "Job Activity", "You started a job", os.time(), 6000, "labor", {})
    TriggerClientEvent("Trucking:Client:OnDuty", joiner, joiner, os.time())

    Labor.Offers:Task(joiner, _JOB, "Speak with the Trucker Foreman")
    if #members > 0 then
        for k, v in ipairs(members) do
            _joiners[v.ID] = joiner
            local member = Fetch:CharacterSource(v.ID)
            member:SetData("TempJob", _JOB)
            Phone.Notification:Add(v.ID, "Job Activity", "You started a job", os.time(), 6000, "labor", {})
            TriggerClientEvent("Trucking:Client:OnDuty", v.ID, joiner, os.time())
        end
    end
end)

AddEventHandler("Trucking:Server:OffDuty", function(source, joiner)
    local truckingData = _trucking[_joiners[source]]

    if truckingData then
        if truckingData.trailer then
            Vehicles:Delete(truckingData.trailer, function()
                truckingData.trailer = nil
            end)
        end

        if truckingData.truck then
            Vehicles:Delete(truckingData.truck, function()
                truckingData.truck = nil
            end)
        end

        truckingData = nil
    end

    TriggerClientEvent("Trucking:Client:OffDuty", source)
end)

RegisterNetEvent("Trucking:Server:TrailerHitched", function()
    local truckingData = _trucking[_joiners[source]]

    if (truckingData and truckingData.state == 2) then
        local trailerCoords = GetEntityCoords(truckingData.trailer)
        truckingData.state = 3
        Labor.Offers:Task(_joiners[source], _JOB, trucking.jobs[truckingData.type][truckingData.level].taskOne)
        Labor.Workgroups:SendEvent(_joiners[source], string.format("Trucking:Client:%s:UpdateWaypoint", _joiners[source]), "dropoff")
    end
end)