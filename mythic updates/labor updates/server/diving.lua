local _JOB = "Diving"
local _joiners = {}
local _diving = {}
local _usedLocationSets = {}
local boxType = nil

AddEventHandler("Labor:Server:Startup", function()
    Reputation:Create("Diving", "Diving", {
        { label = "Rank 1", value = 1000 },
        { label = "Rank 2", value = 2000 },
        { label = "Rank 3", value = 4000 },
        { label = "Rank 4", value = 10000 },
        { label = "Rank 5", value = 16000 },
        { label = "Rank 6", value = 25000 },
        { label = "Rank 7", value = 35000 },
        { label = "Rank 8", value = 50000 },
        { label = "Rank 9", value = 75000 },
        { label = "Rank 10", value = 100000 },
    }, false)

    -- Start Job --
    Callbacks:RegisterServerCallback("Diving:StartJob", function(source, data, cb)
        if _diving[data] ~= nil and _diving[data].state == 0 then
            _diving[data].state = 1
            _diving[data].tasks = 0
            _diving[data].job = deepcopy(availableDiveJobs[1])
    
            local divingRep = Reputation:GetLevel(source, "Diving") or 0
            local boxType
    
            if divingRep >= 8 then -- Rank 8-10
                local rand = math.random(1, 100)
                if rand <= 50 then
                    boxType = "regular"      -- 50% chance
                elseif rand <= 80 then
                    boxType = "antique"      -- 30% chance
                elseif rand <= 100 then
                    boxType = "jewellery"    -- 20% chance
                end
            elseif divingRep >= 6 and divingRep < 8 then -- Rank 6-7
                local rand = math.random(1, 100)
                if rand <= 50 then
                    boxType = "regular"      -- 50% chance
                elseif rand <= 80 then
                    boxType = "antique"      -- 30% chance
                elseif rand <= 100 then
                    boxType = "jewellery"    -- 20% chance
                end
            elseif divingRep >= 3 and divingRep < 6 then -- Rank 3-5
                local rand = math.random(1, 100)
                if rand <= 50 then
                    boxType = "regular"      -- 50% chance
                elseif rand <= 80 then
                    boxType = "antique"      -- 30% chance
                end
            elseif divingRep < 3 then -- Rank 1-2
                boxType = "regular"          -- 100% chance for regular
            end
    
            _diving[_joiners[source]].boxType = boxType
            local totalLocationSets = #availableDiveJobs[1].locationSets
            local randomLocationSet
    
            for i = 1, totalLocationSets do
                local locSetIndex = math.random(1, totalLocationSets)
                if not _usedLocationSets[locSetIndex] then
                    randomLocationSet = locSetIndex
                    _usedLocationSets[locSetIndex] = true
                    break
                end
            end
    
            if not randomLocationSet then
                Execute:Client(source, "Notification", "Error", "No available locations, wait a little bit.")
                cb(false)
                return
            end
    
            _diving[data].locationSet = randomLocationSet
            _diving[data].nodes = deepcopy(availableDiveJobs[1].locationSets[randomLocationSet])
            
            Labor.Offers:Task(_joiners[source], _JOB, "Borrow A Boat From The Dive Master.")

            Labor.Workgroups:SendEvent(
                _joiners[source],
                string.format("Diving:Client:%s:Startup", _joiners[source]),
                _diving[data].nodes,
                _diving[data].job.action,
                _diving[data].job.durationBase,
                _diving[data].job.animation,
                boxType
            )
    
            cb(true)
        else
            Execute:Client(source, "Notification", "Error", "Unable to start the job")
            cb(false)
        end
    end)    

    -- When a node is completed --
    Callbacks:RegisterServerCallback("Diving:CompleteNode", function(source, data, cb)
        local char = Fetch:CharacterSource(source)
        local playerSID = char:GetData("SID")
        local divingData = _diving[_joiners[source]]
    
        if divingData and char:GetData("TempJob") == _JOB then
            local nodeFound = false
            for k, v in ipairs(divingData.nodes) do
                if v.id == data then
                    nodeFound = true
                    local divingRep = Reputation:GetLevel(source, "Diving")
                    local multiplier = 1 + (divingRep * 0.2)
                    local boxType = divingData.boxType
                    local rewards = boxRewards[boxType]
    
                    if rewards then
                        local selectedReward = rewards[math.random(#rewards)]
                        local itemCount = math.random(selectedReward.min, selectedReward.max)
                        local finalCount = math.floor(itemCount * multiplier)
                        Inventory:AddItem(playerSID, selectedReward.item, finalCount, {}, 1)
                    else
                        print("No rewards found for boxType:", boxType)
                    end
    
                    Labor.Workgroups:SendEvent(
                        _joiners[source],
                        string.format("Diving:Client:%s:Action", _joiners[source]),
                        data
                    )
    
                    table.remove(divingData.nodes, k)
    
                    if Labor.Offers:Update(_joiners[source], _JOB, 1, true) then
                        divingData.tasks = divingData.tasks + 1
                        divingData.state = 2
                        Labor.Offers:Task(_joiners[source], _JOB, "Return to the Diving Supervisor")
                        Labor.Workgroups:SendEvent(_joiners[source], string.format("Diving:Client:%s:EndDiving", _joiners[source]))
                    end
    
                    break
                end
            end
    
            if not nodeFound then
                Execute:Client(source, "Notification", "Error", "Unable to complete node because of ID")
                cb(false)
            else
                cb(true)
            end
        else
            cb(false)
        end
    end)

    -- Turn In Job
    Callbacks:RegisterServerCallback("Diving:TurnIn", function(source, data, cb)
        if _joiners[source] ~= nil and _diving[_joiners[source]].tasks == 1 then
            local divingData = _diving[_joiners[source]]

            if divingData ~= nil and divingData.state == 2 then
                local boatCoords = GetEntityCoords(divingData.boat)
                local playerCoords = GetEntityCoords(GetPlayerPed(source))
                local distance = #(boatCoords - playerCoords)

                if distance <= 25 then
                    Vehicles:Delete(divingData.boat, function()
                        local locationSet = divingData.locationSet
                        if locationSet then
                            _usedLocationSets[locationSet] = nil
                        end
                
                        Labor.Offers:ManualFinish(_joiners[source], _JOB)
                
                        divingData = nil

                        cb(true)
                    end)
                else
                    Execute:Client(source, "Notification", "Error", "Boat must be nearby.")
                    cb(false)
                end
            end
        else
            Execute:Client(source, "Notification", "Error", "Unable To Complete Job")
            cb(false)
        end
    end)

    Callbacks:RegisterServerCallback("Diving:BuyScubaGear", function(source, data, cb)
        local char = Fetch:CharacterSource(source)
        local playerSID = char:GetData("SID")
        local bankAcc = Banking.Accounts:GetPersonal(playerSID)
        local price = 500

        if bankAcc.Balance >= price then
            Inventory:AddItem(playerSID, "scuba_gear", 1, {}, 1)
            Banking.Balance:Withdraw(bankAcc.Account, price, {
                type = "withdraw",
                title = "Scuba Gear Purchase",
                description = "Purchased scuba gear for Diving Job",
            })

            cb(true)
        else 
            cb(false)
        end
    end)

    Callbacks:RegisterServerCallback("Diving:SpawnBoat", function(source, data, cb)
        local divingData = _diving[_joiners[source]]
        if not divingData then
            Execute:Client(source, "Notification", "Error", "You are not on a diving job.")
            cb(false)
            return
        end

        local boatSpawnCoords = vector3(-1799.903, -1233.530, -0.475)
        local boatHeading = 319.438

        Vehicles:SpawnTemp(source, `dinghy`, 'automobile', boatSpawnCoords, boatHeading, function(boat, VIN)
            Vehicles.Keys:Add(source, VIN)
            divingData.boat = boat
            Labor.Offers:Start(_joiners[source], _JOB, divingData.job.objective, #divingData.nodes)
            
            cb(true)
        end)
    end)
end)

AddEventHandler("Diving:Server:OnDuty", function(joiner, members, isWorkgroup)
    _joiners[joiner] = joiner
    _diving[joiner] = {
        joiner = joiner,
        isWorkgroup = isWorkgroup,
        started = os.time(),
        state = 0,
    }

    local char = Fetch:CharacterSource(joiner)
	char:SetData("TempJob", _JOB)
	Phone.Notification:Add(joiner, "Job Activity", "You started a job", os.time(), 6000, "labor", {})
	TriggerClientEvent("Diving:Client:OnDuty", joiner, joiner, os.time())

    Labor.Offers:Task(joiner, _JOB, "Speak With The Dive Master")
	if #members > 0 then
		for k, v in ipairs(members) do
			_joiners[v.ID] = joiner
			
			local member = Fetch:CharacterSource(v.ID)
			member:SetData("TempJob", _JOB)
			Phone.Notification:Add(v.ID, "Job Activity", "You started a job", os.time(), 6000, "labor", {})
			TriggerClientEvent("Diving:Client:OnDuty", v.ID, joiner, os.time())
		end
	end
end)

AddEventHandler("Diving:Server:OffDuty", function(source, joiner)
    local divingData = _diving[_joiners[source]]

    if divingData then
        local locationSet = divingData.locationSet
        if locationSet then
            _usedLocationSets[locationSet] = nil
        end

        if divingData.boat then
            Vehicles:Delete(divingData.boat, function()
                divingData.boat = nil
            end)
        end

        divingData = nil
    end

    TriggerClientEvent("Diving:Client:OffDuty", source)
end)

AddEventHandler("Diving:Server:FinishJob", function(joiner)
    if _diving[joiner] then
        local locationSet = _diving[joiner].locationSet
        if locationSet then
            _usedLocationSets[locationSet] = nil
        end
        _diving[joiner] = nil
    end
end)