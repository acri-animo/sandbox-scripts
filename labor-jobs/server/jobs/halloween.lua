local _JOB = "Halloween"

local _joiners = {}
local _halloween = {}
local _dugGraves = {}


local organLoot = {
    { chance = 100, item = "kidney", amount = 1 },
    { chance = 50, item = "liver", amount = 1 },
    { chance = 35, item = "lung", amount = 1 },
    { chance = 25, item = "heart", amount = 1 },
    { chance = 10, item = "brain", amount = 1 },
}

local totalWeight = 0
for i, loot in ipairs(organLoot) do
    totalWeight = totalWeight + loot.chance
    loot.cumulativeChance = totalWeight
end

AddEventHandler("Labor:Server:Startup", function()
    Callbacks:RegisterServerCallback("Halloween:Enable", function(source, data, cb)
        local char = Fetch:CharacterSource(source)
        local states = char:GetData("States") or {}
        if not hasValue(states, "SCRIPT_GRAVE_DIGGER") then
            table.insert(states, "SCRIPT_GRAVE_DIGGER")
            char:SetData("States", states)
            Phone.Notification:Add(source, "New Job Available", "A new job is available, check it out.", os.time(), 6000, "labor", {})
        end
    end)

    Callbacks:RegisterServerCallback("Halloween:StartJob", function(source, data, cb)
        if _halloween[data] ~= nil and _halloween[data].state == 0 then
            _halloween[data].state = 1
            _halloween[data].tasks = 0
            _halloween[data].job = deepcopy(halloweenJobs[1])

            local totalSites = #halloweenJobs[1].locations
            local randomSite

            for i = 1, totalSites do
                local locIndex = math.random(1, totalSites)
                if not _dugGraves[locIndex] then
                    randomSite = locIndex
                    _dugGraves[locIndex] = true
                    break
                end
            end

            if not randomSite then
                Execute:Client(source, "Notification", "Error", "No Sites Available")
                cb(false)
                return
            end

            _halloween[data].locations = randomSite
            _halloween[data].graves = deepcopy(halloweenJobs[1].locations[randomSite])

            Labor.Offers:Start(_joiners[source], _JOB, _halloween[data].job.objective, #_halloween[data].graves)
            Labor.Workgroups:SendEvent(
                _joiners[source],
                string.format("Halloween:Client:%s:Startup", _joiners[source]),
                _halloween[data].graves
            )

            cb(true)
        else
            Execute:Client(source, "Notification", "Error", "Unable to start the job")
            cb(false)
        end
    end)


    Callbacks:RegisterServerCallback("Halloween:GraveDigger", function(source, data, cb)
        local char = Fetch:CharacterSource(source)
        local playerSID = char:GetData("SID")
        local hSesh = _halloween[_joiners[source]]

        if hSesh and char:GetData("TempJob") == _JOB then
            local graveFound = false
            for k, v in ipairs(hSesh.graves) do
                if v.id == data then
                    graveFound = true

                    Labor.Workgroups:SendEvent(
                        _joiners[source],
                        string.format("Halloween:Client:%s:Action", _joiners[source]),
                        data
                    )

                    table.remove(hSesh.graves, k)

                    if Labor.Offers:Update(_joiners[source], _JOB, 1, true) then
                        hSesh.tasks = hSesh.tasks + 1
                        Labor.Offers:Task(_joiners[source], _JOB, "Return to the Groundskeeper")
                        Labor.Workgroups:SendEvent(_joiners[source], string.format("Halloween:Client:%s:EndHalloween", _joiners[source]))
                    end

                    break
                end
            end

            if not graveFound then
                Execute:Client(source, "Notification", "Error", "Something failed with grave ID")
                cb(false)
            else
                cb(true)
            end
        else
            cb(false)
        end
    end)

    Callbacks:RegisterServerCallback("Halloween:TurnIn", function(source, data, cb)
        if _joiners[source] ~= nil and _halloween[_joiners[source]].tasks == 1 then
            local hSesh = _halloween[_joiners[source]]
            hSesh.state = 2

            local locSet = hSesh.locations
            if locSet then
                _dugGraves[locSet] = nil
            end

            Labor.Offers:ManualFinish(_joiners[source], _JOB)
            cb(true)
        else
            Execute:Client(source, "Notification", "Error", "Unable to complete job")
            cb(false)
        end
    end)

    Callbacks:RegisterServerCallback("Halloween:GetLoot", function(source, data, cb)
        local char = Fetch:CharacterSource(source)
        local playerSID = char:GetData("SID")

        if not char then
            return
        end

        if data.loot == "bones" then
            Inventory:AddItem(playerSID, "bones", math.random(1, 3), {}, 1)
            cb(true)
        elseif data.loot == "organs" then
            local randomWeight = math.random(totalWeight)
    
            for _, loot in ipairs(organLoot) do
                if randomWeight <= loot.cumulativeChance then
                    Inventory:AddItem(playerSID, loot.item, loot.amount, {}, 1)
                    cb(true)
                    break
                end
            end
        else
            cb(false)
        end    
    end)

    Callbacks:RegisterServerCallback("Halloween:Server:SellOrgans", function(source, data, cb)
        local source = source
        local char = Fetch:CharacterSource(source)
        if not char then return end

        local playerSID = char:GetData("SID")
        local graveRep = Reputation:GetLevel(source, "Halloween") or 0
        local cryptoWallet = char:GetData("CryptoWallet")
        local repMultiplier = 1 + (graveRep * 0.1)

        local organRewards = {
            kidney = 2,
            liver = 3,
            lung = 4,
            heart = 5,
            brain = 6
        }

        local baseAmount = organRewards[data.organ]
        if baseAmount then
            sellOrgans(playerSID, data.organ, baseAmount, repMultiplier, cryptoWallet)

            cb(true)
        else
            Execute:Client(source, "Notification", "Error", "Invalid organ type.", 6000)

            cb(false)
        end
    end)

    Callbacks:RegisterServerCallback("Halloween:Server:SellBones", function(source, data, cb)
        local source = source
        local char = Fetch:CharacterSource(source)
        if not char then return end

        local playerSID = char:GetData("SID")
        local bones = Inventory.Items:GetCount(playerSID, 1, "bones") or 0

        if bones > 0 then
            Inventory.Items:Remove(playerSID, 1, "bones", bones)
            local finalAmount = math.floor(bones * 0.1)

            Inventory:AddItem(playerSID, "moneyroll", finalAmount, {}, 1)

            cb(true)
        else
            Execute:Client(source, "Notification", "Error", "You don't have any bones lumen...", 6000)

            cb(false)
        end
    end)
end)

AddEventHandler("Halloween:Server:OnDuty", function(joiner, members, isWorkgroup)
    _joiners[joiner] = joiner
    _halloween[joiner] = {
        joiner = joiner,
        isWorkgroup = isWorkgroup,
        started = os.time(),
        state = 0,
    }

    local char = Fetch:CharacterSource(joiner)
    char:SetData("TempJob", _JOB)
    Phone.Notification:Add(joiner, "Job Activity", "You started a job", os.time(), 6000, "labor", {})
    TriggerClientEvent("Halloween:Client:OnDuty", joiner, joiner, os.time())

    Labor.Offers:Task(joiner, _JOB, "Speak with the Groundskeeper")
    if #members > 0 then
        for k, v in ipairs(members) do
            _joiners[v.ID] = joiner

            local member = Fetch:CharacterSource(v.ID)
            member:SetData("TempJob", _JOB)
            Phone.Notification:Add(v.ID, "Job Activity", "You started a job", os.time(), 6000, "labor", {})
            TriggerClientEvent("Halloween:Client:OnDuty", v.ID, joiner, os.time())
        end
    end
end)

AddEventHandler("Halloween:Server:OffDuty", function(source, joiner)
    if _halloween[source] then
        local locSet = _halloween[source].locations
        if locSet then
            _dugGraves[locSet] = nil
        end
        _halloween[source] = nil
    end
    TriggerClientEvent("Halloween:Client:OffDuty", source)
end)

AddEventHandler("Halloween:Server:FinishJob", function(joiner)
    if _halloween[joiner] then
        local locSet = _halloween[joiner].locations
        if locSet then
            _dugGraves[locSet] = nil
        end
        _halloween[joiner] = nil
    end
end)

function sellOrgans(playerSID, organName, baseAmount, repMultiplier, cryptoWallet)
    local count = Inventory.Items:GetCount(playerSID, 1, organName) or 0
    if count > 0 then
        Inventory.Items:Remove(playerSID, 1, organName, count)
        local cryptoReward = count * baseAmount * repMultiplier * 0.1
        Crypto.Exchange:Add("MALD", cryptoWallet, cryptoReward)
    else
        Execute:Client(source, "Notification", "Error", "You don't have the required item: " .. organName, 6000)
    end
end

RegisterNetEvent("Halloween:Server:NotifyPigs", function(coords)
    local src = source
    Robbery:TriggerPDAlert(src, coords, "10-90", "Grave Robbery", {
        icon = 362,
        size = 0.9,
        color = 1,
        duration = (60 * 5),
    })
end)
