local _JOB = "Lumber"

local _joiners = {}
local _Lumber = {}

AddEventHandler("Labor:Server:Startup", function()
    Callbacks:RegisterServerCallback("Lumber:StartJob", function(source, data, cb)
        if _Lumber[data] == nil then
            _Lumber[data] = { state = 0 }
        end

        if _Lumber[data].state == 0 then
            _Lumber[data].state = 1

            _Lumber[data].job = deepcopy(lumber.pine)

            if not _Lumber[data].job or not _Lumber[data].job.locations then
                print("No job config fucking idiot")
                cb(false)
                return
            end

            Labor.Offers:Start(
                _joiners[source], 
                _JOB, 
                "Saw down trees",
                3
            )

            Labor.Workgroups:SendEvent(
                data, 
                string.format("Lumber:Client:%s:Startup", data),
                _Lumber[data].job.locations
            )

            cb(true)
        else
            cb(false)
        end
    end)

    Callbacks:RegisterServerCallback("Lumber:CutTree", function(source, data, cb)
        local job = _Lumber[_joiners[source]]

        local char = Fetch:CharacterSource(source)

        if _joiners[source] == nil or job.state ~= 1 or char:GetData("TempJob") ~= _JOB then
            cb(false)
            return
        end

        for i = #job.job.locations, 1, -1 do
            local location = job.job.locations[i]
            local locationCoords = vector3(location.x, location.y, location.z)
            local dataCoords = vector3(data.location.x, data.location.y, data.location.z)
            
            if location then
                if locationCoords == dataCoords then
                    Labor.Workgroups:SendEvent(
                        _joiners[source],
                        string.format("Lumber:Client:%s:RemoveTree", _joiners[source]),
                        location
                    )
                    table.remove(job.job.locations, i)
                    break
                end
            end
        end

        if Labor.Offers:Update(_joiners[source], _JOB, 1, true) then
            job.tasks = job.tasks + 1

            if job.tasks == 1 then
                Labor.Offers:Start(_joiners[source], _JOB, "Load logs onto the truck", 3)
                job.state = 2
            elseif job.tasks == 2 then
                Labor.Offers:Task(_joiners[source], _JOB, "Take the logs to the sawmill")
                job.state = 3
            elseif job.tasks == 3 then
                Labor.Offers:Task(_joiners[source], _JOB, "Return to the Lumber Foreman")
                job.state = 4
            end
        end

        cb(true)
    end)
end)

AddEventHandler("Lumber:Server:OnDuty", function(joiner, members, isWorkgroup)
    _joiners[joiner] = joiner
    _Lumber[joiner] = {
        joiner = joiner,
        isWorkgroup = isWorkgroup,
        started = os.time(),
        state = 0,
        tasks = 0,
    }

    local char = Fetch:CharacterSource(joiner)
    char:SetData("TempJob", _JOB)
    Phone.Notification:Add(joiner, "Job Activity", "You started a job", os.time(), 6000, "labor", {})
    TriggerClientEvent("Lumber:Client:OnDuty", joiner, joiner, os.time())

    Labor.Offers:Task(joiner, _JOB, "Speak with the Lumber Foreman")
    if #members > 0 then
        for k, v in ipairs(members) do
            _joiners[v.ID] = joiner
            local member = Fetch:CharacterSource(v.ID)
            member:SetData("TempJob", _JOB)
            Phone.Notification:Add(v.ID, "Job Activity", "You started a job", os.time(), 6000, "labor", {})
            TriggerClientEvent("Lumber:Client:OnDuty", v.ID, joiner, os.time())
        end
    end
end)

AddEventHandler("Lumber:Server:OffDuty", function(source, joiner)
    _joiners[source] = nil
    TriggerClientEvent("Lumber:Client:OffDuty", source)
end)