local config = {
    seasonEndTime = 1742072974 + 1209600,
    currentLevel = 5,
    currentExp = 750,
    expToNextLevel = 1000,
}

local function GenerateRewards()
    local rewards = {
        premium = {},
        free = {}
    }
    
    local types = {"Vehicle", "Weapon", "Cosmetic", "Clothing", "Emote", "Currency", "Boost"}
    
    for i = 1, 20 do
        local typeIndex = (i % #types) + 1
        
        rewards.premium[i] = {
            id = i,
            name = "Premium " .. types[typeIndex] .. " " .. i,
            type = types[typeIndex],
            level = i,
            claimed = i < 4,
            available = i <= 10,
        }
        
        if i % 3 ~= 0 then
            rewards.free[i] = {
                id = i + 1000,
                name = "Free " .. types[typeIndex] .. " " .. i,
                type = types[typeIndex],
                level = i,
                claimed = i < 3,
                available = i <= 10,
            }
        end
    end
    
    return rewards
end

local function GenerateMissions()
    local missions = {
        {
            id = "DRIVE_20KM",
            title = "Drive 20km",
            description = "Drive 20km on Land with a vehicle",
            progress = 15000,
            total = 20000,
            reward = 1200,
            completed = false,
            isCollection = true,
        },
        {
            id = "COMPLETE_RACES",
            title = "Complete Races",
            description = "Complete 3 street races",
            progress = 2,
            total = 3,
            reward = 800,
            completed = false,
            isCollection = true,
        },
        {
            id = "WIN_RACE",
            title = "Win a Race",
            description = "Win a street race",
            progress = 0,
            total = 1,
            reward = 1500,
            completed = false,
            isCollection = false,
        },
        {
            id = "VISIT_LOCATIONS",
            title = "Visit Locations",
            description = "Visit 5 marked locations",
            progress = 5,
            total = 5,
            reward = 500,
            completed = true,
            isCollection = true,
            claimed = true,
        },
        {
            id = "COLLECT_ITEMS",
            title = "Collect Items",
            description = "Collect 10 special items",
            progress = 7,
            total = 10,
            reward = 600,
            completed = false,
            isCollection = true,
        },
        {
            id = "PERFORM_STUNTS",
            title = "Perform Stunts",
            description = "Perform 5 successful stunts",
            progress = 5,
            total = 5,
            reward = 700,
            completed = true,
            isCollection = true,
            claimed = false,
        },
    }
    
    return missions
end

local function GenerateLeaderboard()
    local leaderboard = {
        { id = 1, name = "SpeedDemon", level = 85, xp = 850000 },
        { id = 2, name = "RacingKing", level = 82, xp = 820000 },
        { id = 3, name = "DriftMaster", level = 80, xp = 800000 },
        { id = 4, name = "NightRider", level = 75, xp = 750000 },
        { id = 5, name = "RoadRunner", level = 72, xp = 720000 },
        { id = 6, name = "FastLane", level = 70, xp = 700000 },
        { id = 7, name = "TurboCharged", level = 68, xp = 680000 },
        { id = 8, name = "StreetRacer", level = 65, xp = 650000 },
        { id = 9, name = "BurnoutKing", level = 62, xp = 620000 },
        { id = 10, name = "AsphaltLegend", level = 60, xp = 600000 },
    }
    
    return leaderboard
end

local function GetBattlepassData()
    local rewards = GenerateRewards()
    local missions = GenerateMissions()
    local leaderboard = GenerateLeaderboard()
    
    local timeLeft = config.seasonEndTime - 1742072974
    local days = math.floor(timeLeft / 86400)
    local hours = math.floor((timeLeft % 86400) / 3600)
    local minutes = math.floor((timeLeft % 3600) / 60)
    local seconds = timeLeft % 60
    
    return {
        timeLeft = {
            days = days,
            hours = hours,
            minutes = minutes,
            seconds = seconds
        },
        currentLevel = config.currentLevel,
        currentExp = config.currentExp,
        expToNextLevel = config.expToNextLevel,
        rewards = rewards,
        missions = missions,
        leaderboard = leaderboard
    }
end

RegisterNUICallback("GetBattlepassData", function(data, cb)
    print("UI requested battlepass data")
    local battlepassData = GetBattlepassData()
    cb(battlepassData)
    print("Sent battlepass data to UI")
end)

RegisterNUICallback("ClaimReward", function(data, cb)
    print("Claiming reward: Level " .. data.level .. ", Type: " .. data.type)
    local battlepassData = GetBattlepassData()
    if data.type == "premium" and not battlepassData.amIpremium then
        cb({
            success = false,
            message = "You need to become premium first!"
        })
        return
    end
    
    local success = true
    local message = "Reward claimed successfully!"
    
    cb({
        success = success,
        message = message
    })
    
    if success then
        SendNUIMessage({
            type = "UPDATE_BATTLEPASS_DATA",
            data = battlepassData
        })
    end
end)

RegisterNUICallback("ClaimMissionReward", function(data, cb)

    print("Claiming mission reward: " .. data.missionId)
    
    local success = true
    local message = "Mission reward claimed successfully!"
    
    cb({
        success = success,
        message = message
    })
    
    if success then
        local battlepassData = GetBattlepassData()
        SendNUIMessage({
            type = "UPDATE_BATTLEPASS_DATA",
            data = battlepassData
        })
    end
end)

function UpdateMissionProgress(missionId, isCollection, value)
    SendNUIMessage({
        type = "UPDATE_MISSION",
        data = {
            missionId = missionId,
            isCollection = isCollection,
            add = value
        }
    })
end

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    print("Battlepass initialized")
end)

RegisterCommand("testmission", function(source, args)
    local missionId = args[1] or "DRIVE_20KM"
    local isCollection = args[2] ~= "false"
    local value = isCollection and tonumber(args[3] or "1") or (args[3] ~= "false")
    
    UpdateMissionProgress(missionId, isCollection, value)
end, false)

