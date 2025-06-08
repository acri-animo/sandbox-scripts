local _taxis = {}
local _earnings = {}

AddEventHandler("Taxi:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
    Fetch = exports["lumen-base"]:FetchComponent("Fetch")
    Logger = exports["lumen-base"]:FetchComponent("Logger")
    Callbacks = exports["lumen-base"]:FetchComponent("Callbacks")
    Inventory = exports["lumen-base"]:FetchComponent("Inventory")
    Wallet = exports["lumen-base"]:FetchComponent("Wallet")
    Execute = exports["lumen-base"]:FetchComponent("Execute")
    Reputation = exports["lumen-base"]:FetchComponent("Reputation")
    Vehicles = exports["lumen-base"]:FetchComponent("Vehicles")
    Middleware = exports["lumen-base"]:FetchComponent("Middleware")
end

AddEventHandler("Core:Shared:Ready", function()
    exports["lumen-base"]:RequestDependencies("Taxi", {
        "Fetch",
        "Logger",
        "Callbacks",
        "Inventory",
        "Wallet",
        "Execute",
        "Reputation",
        "Vehicles",
    }, function(error)
        if #error > 0 then
            return
        end

        RetrieveComponents()
        TriggerEvent("Taxi:Server:Setup")
    end)
end)

AddEventHandler("Taxi:Server:Setup", function()
    Reputation:Create("Taxi", "Taxi", {
        { label = "Rank 1", value = 1000 },
        { label = "Rank 2", value = 2000 },
        { label = "Rank 3", value = 4000 },
        { label = "Rank 4", value = 7000 },
        { label = "Rank 5", value = 10000 },
        { label = "Rank 6", value = 15000 },
        { label = "Rank 7", value = 20000 },
        { label = "Rank 8", value = 30000 },
        { label = "Rank 9", value = 40000 },
        { label = "Rank 10", value = 50000 },
        { label = "Rank 11", value = 65000 },
        { label = "Rank 12", value = 80000 },
        { label = "Rank 13", value = 95000 },
        { label = "Rank 14", value = 110000 },
        { label = "Rank 15", value = 130000 },
        { label = "Rank 16", value = 150000 },
        { label = "Rank 17", value = 200000 },
        { label = "Rank 18", value = 250000 },
        { label = "Rank 19", value = 300000 },
        { label = "Rank 20", value = 400000 },
    }, false)

    Middleware:Add("Characters:Spawning", function(source)
        local char = Fetch:CharacterSource(source)

        MySQL.query('SELECT * FROM taxi_earnings WHERE sid = ?', { char:GetData("SID") }, function(response)
            if response then
                _earnings[source] = response[1] and response[1].earnings or 0
            else
                _earnings[source] = 0
            end
        end)
    end)

    Callbacks:RegisterServerCallback("Taxi:Server:OpenMenu", function(source, data, cb)
        local jobData = {}
        jobData.earnings = _earnings[source]

        cb(true, jobData)
    end)

    Callbacks:RegisterServerCallback("Taxi:Server:StartShift", function(source, data, cb)
        if not data or not data.tier or not data.model then
            cb(false)
            return
        end

        if not _taxis[source] then
            _taxis[source] = {}
        end

        local tier = data.tier
        local vehicle = data.model

        _taxis[source].tier = tier

        Vehicles:SpawnTemp(source, GetHashKey(vehicle), 'automobile', Config.VehicleCoords, Config.VehicleHeading, function(veh, VIN)
            Vehicles.Keys:Add(source, VIN)
            _taxis[source].vehicle = veh

            local netId = NetworkGetNetworkIdFromEntity(veh)

            cb(true, netId)
        end)
    end)

    Callbacks:RegisterServerCallback("Taxi:Server:CompleteFare", function(source, data, cb)
        local job = _taxis[source]
        local char = Fetch:CharacterSource(source)
        
        if not job or not job.tier then
            cb(false)
            return
        end

        local tier = tostring(job.tier)
        local tierKey = "tier" .. tier
        local payConfig = Config.Pay[tierKey]

        if not payConfig then
            cb(false)
            return
        end

        local fare = math.random(payConfig.min, payConfig.max)

        if not _earnings[source] then
            _earnings[source] = 0
        end

        local repData = Reputation:GetLevel(source, "Taxi")
        local maxRolls = math.max(1, math.floor((repData + 4) / 5))

        local bonusCashMin = 50
        local bonusCashMax = 70
        local cashMultiplier = 1 + (repData - 1) * 0.1
        local scaledBonusMin = math.floor(bonusCashMin * cashMultiplier)
        local scaledBonusMax = math.floor(bonusCashMax * cashMultiplier)

        local randomChance = math.random(1, 100)
        if randomChance <= 15 then
            local dirtyMoney = Inventory.Items:GetCount(char:GetData("SID"), 1, "moneyroll")

            if dirtyMoney >= maxRolls then
                Inventory.Items:Remove(char:GetData("SID"), 1, "moneyroll", maxRolls)
                fare = fare + math.random(scaledBonusMin, scaledBonusMax)
            end
        end

        _earnings[source] = _earnings[source] + fare
        Wallet:Modify(source, fare)
        Reputation.Modify:Add(source, "Taxi", math.random(20, 30))

        cb(true)
    end)

    Callbacks:RegisterServerCallback("Taxi:Server:EndShift", function(source, data, cb)
        local job = _taxis[source]

        if not job or not job.vehicle then
            cb(false)
            return
        end
        
        local char = Fetch:CharacterSource(source)
        local earnings = _earnings[source] or 0

        local affRows = MySQL.update.await('UPDATE taxi_earnings SET earnings = earnings + ?, last_job_completed = CURRENT_TIMESTAMP WHERE sid = ?', {
            earnings,
            char:GetData("SID")
        })

        if affRows == 0 then
            MySQL.insert.await('INSERT INTO taxi_earnings (sid, earnings, last_job_completed) VALUES (?, ?, CURRENT_TIMESTAMP)', {
                char:GetData("SID"),
                earnings
            })
        end

        local taxiCoords = GetEntityCoords(job.vehicle)
        local pedCoords = GetEntityCoords(GetPlayerPed(source))
        local distance = #(pedCoords - taxiCoords)

        if distance <= 30 then
            Vehicles:Delete(job.vehicle, function()
                job.vehicle = nil
                job.tier = nil
                job = nil
            end)

            cb(true)
        else
            cb(false)
        end
    end)
end)