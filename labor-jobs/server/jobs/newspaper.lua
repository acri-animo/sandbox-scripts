local _JOB = "Newspaper"

local _joiners = {}
local _Newspaper = {}

AddEventHandler("Labor:Server:Startup", function()
    Callbacks:RegisterServerCallback("Newspaper:StartJob", function(source, data, cb)
        local joiner = data.joiner

        if _Newspaper[joiner] ~= nil and _Newspaper[joiner].state == 0 then
            _Newspaper[joiner].job = deepcopy(newspaper[data.area].routes[data.route])

            if not _Newspaper[joiner].job then
                print("No config found")
                cb(false)
                return
            end

            local locations = _Newspaper[joiner].job.deliveryLocations
            Labor.Offers:Task(joiner, _JOB, "Get newspapers and a bicycle from the manager")
            Labor.Workgroups:SendEvent(joiner, string.format("Newspaper:Client:%s:Startup", joiner), locations)
            _Newspaper[joiner].state = 1
            cb(true)
        else
            cb(false)
        end
    end)

    Callbacks:RegisterServerCallback("Newspaper:StartTimeTrial", function(source, data, cb)
        local joiner = data.joiner
        
        if _Newspaper[joiner] ~= nil and _Newspaper[joiner].state == 0 then
            print("Starting time trial for joiner " .. joiner .. " with area " .. tostring(data.area) .. ", route " .. tostring(data.route) .. ", tier " .. tostring(data.tier))
            local routeData = newspaper[data.area] and newspaper[data.area].routes[data.route]
            if not routeData then
                print("No route found for area " .. tostring(data.area) .. " route " .. tostring(data.route))
                cb(false)
                return
            end
    
            local timeTier = routeData.timeTiers[data.tier] -- Now expects "easy", "medium", or "hard"
            if not timeTier or not timeTier.time then
                print("No valid time tier found for tier " .. tostring(data.tier))
                cb(false)
                return
            end
    
            _Newspaper[joiner].job = deepcopy(routeData)
            _Newspaper[joiner].isTimeTrial = true
            _Newspaper[joiner].startTime = os.time()
            _Newspaper[joiner].timeLimit = timeTier.time
            _Newspaper[joiner].multiplier = timeTier.multiplier
            _Newspaper[joiner].state = 1

            print("Time trial started for joiner " .. joiner .. " with time limit " .. timeTier.time)
    
            local locations = _Newspaper[joiner].job.deliveryLocations
            Labor.Offers:Task(joiner, _JOB, "Get newspapers and a bicycle from the manager")
            Labor.Workgroups:SendEvent(joiner, string.format("Newspaper:Client:%s:StartupTrial", joiner), {
                locations = locations,
                timeLimit = timeTier.time,
            })
            print("Sent StartupTrial to " .. joiner .. " with timeLimit " .. timeTier.time)
    
            cb(true)
        else
            print("Failed to start time trial for joiner " .. joiner .. ": " .. (_Newspaper[joiner] and "state " .. _Newspaper[joiner].state or "no job data"))
            cb(false)
        end
    end)

    local _isSpawningBicycle = false
    Callbacks:RegisterServerCallback("Newspaper:SpawnBicycle", function(source, data, cb)
        if _isSpawningBicycle then
            cb(false)
            return
        end
        if _joiners[source] ~= nil and _Newspaper[_joiners[source]].bicycle == nil and _Newspaper[_joiners[source]].state == 1 then
            _isSpawningBicycle = true
            Vehicles:SpawnTemp(source, `bmx`, 'bike', vector3(-421.379, 6130.112, 31.369), 234.045, function(veh, VIN)
                Vehicles.Keys:Add(source, VIN)
                _Newspaper[_joiners[source]].bicycle = veh
                _Newspaper[_joiners[source]].state = 2
                _Newspaper[_joiners[source]].tasks = 0 -- Track completed deliveries
    
                if _Newspaper[_joiners[source]].isTimeTrial then
                    local timeLeft = _Newspaper[_joiners[source]].timeLimit - (os.time() - _Newspaper[_joiners[source]].startTime)
                    if timeLeft <= 0 then
                        Execute:Client(source, "Notification", "Error", "Time's up!")
                        cb(false)
                        return
                    end
                    local deliveriesLeft = 20 - (_Newspaper[_joiners[source]].tasks or 0)
                    local minutes = math.floor(timeLeft / 60)
                    local seconds = timeLeft % 60
                    local taskLabel = string.format("%d Deliveries Left - %02d:%02d", deliveriesLeft, minutes, seconds)
                    
                    Labor.Offers:Task(_joiners[source], _JOB, "Deliver Newspapers", {
                        title = "Newspaper Delivery",
                        label = taskLabel,
                        icon = "newspaper",
                        color = "blue",
                    }, 20)
                else
                    Labor.Offers:Start(_joiners[source], _JOB, "Deliver Newspapers", 20)
                end
                _isSpawningBicycle = false
                cb(true)
            end, false)
        else
            cb(false)
        end
    end)
    
    Callbacks:RegisterServerCallback("Newspaper:CompleteDelivery", function(source, data, cb)
        if _joiners[source] ~= nil and _Newspaper[_joiners[source]].state == 2 then
            _Newspaper[_joiners[source]].tasks = (_Newspaper[_joiners[source]].tasks or 0) + 1
    
            if _Newspaper[_joiners[source]].tasks == 20 then
                Labor.Offers:Task(_joiners[source], _JOB, "Return to the manager to finish the job")
                _Newspaper[_joiners[source]].state = 3
            else
                if _Newspaper[_joiners[source]].isTimeTrial then
                    local timeLeft = _Newspaper[_joiners[source]].timeLimit - (os.time() - _Newspaper[_joiners[source]].startTime)
                    local deliveriesLeft = 20 - _Newspaper[_joiners[source]].tasks
                    local minutes = math.floor(timeLeft / 60)
                    local seconds = timeLeft % 60
                    local taskLabel = string.format("%d Deliveries Left - %02d:%02d", deliveriesLeft, minutes, seconds)
                    
                    Labor.Offers:Task(_joiners[source], _JOB, "Deliver Newspapers", {
                        title = "Newspaper Delivery",
                        label = taskLabel,
                        icon = "newspaper",
                        color = "blue",
                    }, 20)
                else
                    Labor.Offers:Update(_joiners[source], _JOB, 1, true)
                end
            end
            cb(true)
        else
            cb(false)
        end
    end)

    -- Callback to turn in job
    Callbacks:RegisterServerCallback("Newspaper:TurnIn", function(source, data, cb)
        if _joiners[source] ~= nil and (_Newspaper[_joiners[source]].tasks or 0) >= 20 then
            local char = Fetch:CharacterSource(source)
            if char:GetData("TempJob") == _JOB and _Newspaper[_joiners[source]].state == 3 then
                -- Check if bicycle is nearby before completing
                local bicycleCoords = GetEntityCoords(_Newspaper[_joiners[source]].bicycle)
                local pedCoords = GetEntityCoords(GetPlayerPed(source))
                local distance = #(pedCoords - bicycleCoords)
                if distance <= 25 then
                    Vehicles:Delete(_Newspaper[_joiners[source]].bicycle, function()
                        _Newspaper[_joiners[source]].bicycle = nil
                        _Newspaper[_joiners[source]].state = 3
                        if _Newspaper[_joiners[source]].isTimeTrial then
                            local elapsed = _Newspaper[_joiners[source]].elapsed
                            print("Elapsed time: " .. elapsed)

                            if elapsed > _Newspaper[_joiners[source]].timeLimit then
                                Execute:Client(source, "Notification", "Error", "You took too long! No bonus...")
                            else
                                local multiplier = _Newspaper[_joiners[source]].multiplier
                                local reward = math.floor(100 * multiplier)
                                Wallet:Modify(source, reward)
                            end
                        end
                        Labor.Offers:ManualFinish(_joiners[source], _JOB)
                        cb(true)
                    end)
                else
                    Execute:Client(source, "Notification", "Error", "Bicycle needs to be nearby to finish!")
                    cb(false)
                end
            else
                Execute:Client(source, "Notification", "Error", "Unable to finish job")
                cb(false)
            end
        else
            Execute:Client(source, "Notification", "Error", "You haven't completed all deliveries!")
            cb(false)
        end
    end)

    Callbacks:RegisterServerCallback("Newspaper:PurchaseNewspapers", function(source, data, cb)
        local char = Fetch:CharacterSource(source)
        if char:GetData("TempJob") == _JOB and _Newspaper[_joiners[source]].state == 1 then
            local playerSID = char:GetData("SID")
            local bankAcc = Banking.Accounts:GetPersonal(playerSID)
            local price = 300

            if bankAcc.Balance >= price then
                Inventory:AddItem(playerSID, "WEAPON_NEWSPAPER", 20, { ammo = 1, clip = 0 }, 1)
                Banking.Balance:Withdraw(bankAcc.Account, price, {
                    type = "withdraw",
                    title = "Newspaper Purchase",
                    description = "Purchased newspapers for the job",
                })

                cb(true)
            else
                cb(false)
            end
        else
            Execute:Client(source, "Notification", "Error", "You need to be on duty to purchase newspapers!")
            cb(false)
        end
    end)
end)

------------------
-- Events/Handlers
------------------

AddEventHandler("Newspaper:Server:OnDuty", function(joiner, members, isWorkgroup)
    if #members > 1 then
        Execute:Client(joiner, "Notification", "Error", "You cannot start a newspaper job with more than 1 person")
        return
    end

    _joiners[joiner] = joiner
    _Newspaper[joiner] = {
        joiner = joiner,
        isWorkgroup = isWorkgroup,
        started = os.time(),
        state = 0,
        tasks = 0,
    }

    local char = Fetch:CharacterSource(joiner)
    char:SetData("TempJob", _JOB)
    Phone.Notification:Add(joiner, "Job Activity", "You started a newspaper delivery job", os.time(), 6000, "labor", {})
    TriggerClientEvent("Newspaper:Client:OnDuty", joiner, joiner, os.time())

    Labor.Offers:Task(joiner, _JOB, "Speak with the Newspaper Manager")
    if #members > 0 then
        for k, v in ipairs(members) do
            _joiners[v.ID] = joiner
            local member = Fetch:CharacterSource(v.ID)
            member:SetData("TempJob", _JOB)
            Phone.Notification:Add(v.ID, "Job Activity", "You started a newspaper delivery job", os.time(), 6000, "labor", {})
            TriggerClientEvent("Newspaper:Client:OnDuty", v.ID, joiner, os.time())
        end
    end
end)

AddEventHandler("Newspaper:Server:OffDuty", function(source, joiner)
    local newsData = _Newspaper[_joiners[source]]
    if newsData then
        if newsData.bicycle then
            Vehicles:Delete(newsData.bicycle, function()
                newsData.bicycle = nil
            end)
        end

        newsData = nil
    end
    TriggerClientEvent("Newspaper:Client:OffDuty", source)
end)

RegisterNetEvent("Newspaper:Server:UpdateTimeTrial")
AddEventHandler("Newspaper:Server:UpdateTimeTrial", function(joiner, timeRemaining, deliveriesLeft, elapsed)
    if _joiners[source] == joiner and _Newspaper[joiner] and _Newspaper[joiner].isTimeTrial and _Newspaper[joiner].state == 2 then
        _Newspaper[joiner].elapsed = elapsed

        if timeRemaining > 0 then
            local minutes = math.floor(timeRemaining / 60)
            local seconds = math.floor(timeRemaining % 60)
            local taskLabel = string.format("%d Deliveries Left - %02d:%02d", deliveriesLeft, minutes, seconds)

            Labor.Offers:Task(joiner, _JOB, "Deliver Newspapers", {
                title = "Newspaper Delivery",
                label = taskLabel,
                icon = "newspaper",
                color = "blue",
            }, 20)
        else
            _Newspaper[joiner].timeExpired = true
            local taskLabel = string.format("%d Deliveries Left - Time Expired", deliveriesLeft)

            Labor.Offers:Task(joiner, _JOB, "Deliver Remaining Newspapers", {
                title = "Newspaper Delivery",
                label = taskLabel,
                icon = "newspaper",
                color = "red",
            }, 20)
        end
    end
end)

AddEventHandler("Newspaper:Server:FinishJob", function(joiner)
    _Newspaper[joiner] = nil
end)

-- Optional: Server-side tracking of deliveries (if you want to sync with client)
RegisterNetEvent("Newspaper:Server:DeliveryCompleted", function()
    local source = source
    if _joiners[source] and _Newspaper[_joiners[source]] and _Newspaper[_joiners[source]].state == 2 then
        _Newspaper[_joiners[source]].tasks = (_Newspaper[_joiners[source]].tasks or 0) + 1
        Labor.Offers:Update(_joiners[source], _JOB, 1, true)
    end
end)