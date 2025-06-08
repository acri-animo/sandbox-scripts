local _heistContractCount = {}
local _heistQueue = {}
local _heistIds = 0
local _heisting = {}

local _pickitemloction = {
    ["Fleeca"] = {
        vector3(-813.508, -586.120, 30.671)
    },
    ["Paleto"] = {
        vector3(36.881, -401.837, 39.916)
    },
}

local _bankLocations = {
    ["Fleeca"] = {
        vector3(147.0, -1045.0, 29.3),   -- Fleeca Bank Legion Square
        vector3(-2957.6, 481.1, 15.7),   -- Fleeca Bank Great Ocean Highway
        vector3(-1211.9, -335.7, 37.8),  -- Fleeca Bank Rockford Hills
        vector3(309.9, -283.6, 54.2),    -- Fleeca Bank Alta
        vector3(1175.1, 2706.8, 38.1),   -- Fleeca Bank Grand Senora Desert
    },
    ["Paleto"] = {
        vector3(-103.7, 6469.6, 31.6),   -- Blaine County Savings Bank
    },
    ["Pacific"] = {
        vector3(254.1, 225.0, 101.9),    -- Pacific Standard Bank
    }
}

local _heistLaptops = {
    ["Store"] = "green_laptop",
    ["Fleeca"] = "green_laptop",
    ["Paleto"] = "green_laptop",
    ["Pacific"] = "green_laptop"
}

AddEventHandler("Laptop:Server:RegisterMiddleware", function()
    Middleware:Add("Characters:Spawning", function(source)
        local plyr = Fetch:CharacterSource(source)
        local char = plyr:GetData("Character")
        if plyr and plyr:GetData("HeistContracts") then
            local contracts = plyr:GetData("HeistContracts")

            for k, v in ipairs(contracts) do
                if v.expires < os.time() then
                    table.remove(contracts, k)
                end
            end

            plyr:SetData("HeistContracts", contracts)
        end
    end, 5)

    Middleware:Add("playerDropped", function(source, message)
        HandleCharacterLogout(source)
    end, 5)
    
    Middleware:Add("Characters:Logout", function(source)
        HandleCharacterLogout(source)
    end, 5)
end)

function HandleCharacterLogout(source)
    for k, v in ipairs(_heistQueue) do
        if v.source == source then
            table.remove(_heistQueue, k)
            return
        end
    end
end

AddEventHandler("Laptop:Server:RegisterCallbacks", function()

    Reputation:Create("Heists", "Heists", {
        { label = "D", value = 0 },
        { label = "C", value = 6000 },
        { label = "B", value = 15000 },
        { label = "A", value = 50000 },
        { label = "A+", value = 120000 },
        { label = "S+", value = 150000 },
    }, true)

	Chat:RegisterAdminCommand("clearmyhistory", function(source, args, rawCommand)
        local plyr = Fetch:CharacterSource(source)
        local char = plyr:GetData("Character")
        if plyr then
            char:SetData("HeistHistory", {})
        end
    end, {
		help = "Clear my Heists History",
	})

    Callbacks:RegisterServerCallback("LaptopHeists:GetData", function(source, data, cb)
        local plyr = Fetch:CharacterSource(source)
        local char = plyr:GetData("Character")
        if not plyr then return cb(false) end
    
        local heistRep = Reputation:ViewList(source, { Heists = true }) or {}
        local history = plyr:GetData("HeistHistory") or {}
    
        exports['oxmysql']:execute(
            "SELECT sid, alias, xp, completed_heists, total_earnings "..
            "FROM heist_leaderboard "..
            "ORDER BY xp DESC LIMIT 10",
            {},
            function(results)
                cb({
                    reputations = heistRep,
                    history = history,
                    topPlayers = results or {},
                })
            end
        )
    end)

    Callbacks:RegisterServerCallback("LaptopHeists:GetLeaderboard", function(source, data, cb)
        local sortBy = data.sortBy or "xp"
        local limit = data.limit or 10
        
        local validSortColumns = {
            ["xp"] = true,
            ["completed_heists"] = true,
            ["total_earnings"] = true,
            ["fastest_heist"] = true
        }
        
        if not validSortColumns[sortBy] then
            sortBy = "xp"
        end
        
        exports['oxmysql']:execute("SELECT * FROM `heist_leaderboard` ORDER BY `" .. sortBy .. "` DESC LIMIT ?", {limit}, function(results)
            if results then
                cb(results)
            else
                cb({})
            end
        end)
    end)

    Callbacks:RegisterServerCallback("LaptopHeists:EnterQueue", function(source, data, cb)    
        local char = Fetch:CharacterSource(source)
        if not char then
            print("char not valid")
            cb(false)
            return
        end
    
        local team, leader = Laptop.Teams:GetByMemberSource(source)
        if not team then
            print("team not valid")
            cb(false)
            return
        end
        
        if char:GetData("LSUNDGBan") then
            cb(false)
            return
        end
    
        local perm = char:GetData("LaptopPermissions") or {}
        local aliasData = char:GetData("Profiles") 
        local alias = aliasData and aliasData.heists.name
    
        local myGroupLeader = nil
        for _, m in ipairs(team.Members or {}) do
            if m.Leader then
                myGroupLeader = m
                break
            end
        end
    
        local isLeader = myGroupLeader and myGroupLeader.SID == char:GetData("SID")
    
        if not isLeader then
            cb({ message = "Only the team leader can join the queue" })
            return
        end

        if (alias and #team.Members >= 2) or (perm["lsunderground"] and perm["lsunderground"]["admin"]) then
            local newEntry = {
                joined = os.time(),
                source = source,
                SID = char:GetData("SID"),
                team = team.ID,
                admin = perm["lsunderground"] and perm["lsunderground"]["admin"],
            }
    
            table.insert(_heistQueue, newEntry)
            TriggerClientEvent("Laptop:Client:SetData", source, "heistQueue", newEntry)
            cb({ success = true })
            return
        end
    
        cb(false)
    end)
    
    Callbacks:RegisterServerCallback("LaptopHeists:ExitQueue", function(source, data, cb)
        local plyr = Fetch:CharacterSource(source)
        local char = plyr:GetData("Character")
        if plyr then
            for k, v in ipairs(_heistQueue) do
                if v.source == source then
                    table.remove(_heistQueue, k)
                    TriggerClientEvent("Laptop:Client:SetData", source, "heistQueue", nil)
                    cb(true)
                    return
                end
            end
        end
        cb(false)
    end)

    Callbacks:RegisterServerCallback("LaptopHeists:Start", function(source, data, cb)
        local plyr = Fetch:CharacterSource(source)
        local char = plyr:GetData("Character")
        if plyr then
            local team, isLeader = Laptop.Teams:GetByMemberSource(source)
            local myGroupLeader = nil
            if team and team.Members then
                for _, m in ipairs(team.Members) do
                    if m.Leader then
                        myGroupLeader = m
                        break
                    end
                end
            end

            local isLeader = myGroupLeader and myGroupLeader.SID == char:GetData("SID")


            if not isLeader then
                return cb({ message = "Only the team leader can start the heist" })
            end

            if team?.ID and team.State == 0 and data?.contractId then
                local heistContracts = char:GetData("HeistContracts") or {}
                local contract = nil
                local contractIndex = nil

                for k, v in ipairs(heistContracts) do
                    if v.id == data.contractId then
                        contract = v
                        contractIndex = k
                        break
                    end
                end

                if contract then
                    LAPTOP.Heists:Start(team.ID, contract)
                    
                    table.remove(heistContracts, contractIndex)
                    char:SetData("HeistContracts", heistContracts)
                    
                    cb({ success = true })
                    return
                end
            end
        end
        cb({ success = false })
    end)

    Callbacks:RegisterServerCallback("LaptopHeists:Admin:CreateContract", function(source, data, cb)
        local plyr = Fetch:CharacterSource(source)
        local char = plyr:GetData("Character")
        if plyr and data?.heistType and data?.difficulty and data?.price then
            local perm = plyr:GetData("LaptopPermissions")

            if perm["lsunderground"] and perm["lsunderground"]["admin"] then
                local cost = tonumber(data.price) or 0

                if cost > 0 then
                    local length = 1 * 60 * 60 -- 1 hour by default
                    
                    cb(LAPTOP.Heists:GiveContract(source, {
                        heistType = data.heistType,
                        difficulty = data.difficulty,
                        rewarded = true,
                    }, {
                        price = cost,
                        coin = "HEIST",
                    }, length, {
                        skipRep = data.skipRep,
                        payoutOverride = tonumber(data.payoutOverride),
                    }))
                else
                    cb(false)
                end
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)

    Callbacks:RegisterServerCallback("LaptopHeists:Admin:GetBans", function(source, data, cb)
        local plyr = Fetch:CharacterSource(source)
        local char = plyr:GetData("Character")
        if plyr then
            local perm = char:GetData("LaptopPermissions")

            if perm["lsunderground"] and perm["lsunderground"]["admin"] then
                Database.Game:find({
                    collection = "characters",
                    query = {
                        LSUNDGBan = {
                            ["$exists"] = true,
                        }
                    },
                    options = {
                        projection = {
                            SID = 1,
                            First = 1,
                            Last = 1,
                            Alias = 1,
                            LSUNDGBan = 1,
                        }
                    }

                }, function(success, results)
                    if success and results then
                        local bannedPlayers = {}
                        for k, v in ipairs(results) do
                            v.RacingAlias = v.Alias?.redline

                            table.insert(bannedPlayers, v)
                        end

                        cb(bannedPlayers)
                    else
                        cb(false)
                    end
                end)
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)

    Callbacks:RegisterServerCallback("LaptopHeists:Admin:Ban", function(source, data, cb)
        local plyr = Fetch:CharacterSource(source)
        local char = plyr:GetData("Character")
        if plyr and data?.SID then
            local perm = char:GetData("LaptopPermissions")

            if perm["lsunderground"] and perm["lsunderground"]["admin"] then
                Database.Game:updateOne({
                    collection = "characters",
                    query = {
                        SID = data.SID,
                    },
                    update = {
                        ["$push"] = {
                            LSUNDGBan = "Heists",
                        }
                    }
                }, function(success, result)
                    if success and result > 0 then
                        local tar = Fetch:CharacterSource(data.SID)
                        local targetChar = plyr:GetData("Character")
                        if targetChar then
                            targetChar:SetData("LSUNDGBan", {
                                "Heists",
                            })
                        end
                        cb(true)
                    else
                        cb(false)
                    end
                end)
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)

    Callbacks:RegisterServerCallback("LaptopHeists:Admin:Unban", function(source, data, cb)
        local plyr = Fetch:CharacterSource(source)
        local char = plyr:GetData("Character") 
        if plyr and data?.SID then
            local perm = char:GetData("LaptopPermissions")

            if perm["lsunderground"] and perm["lsunderground"]["admin"] then
                Database.Game:updateOne({
                    collection = "characters",
                    query = {
                        SID = data.SID,
                    },
                    update = {
                        ["$unset"] = {
                            LSUNDGBan = true,
                        }
                    }
                }, function(success, result)
                    if success and result > 0 then
                        local tar = Fetch:CharacterSource(data.SID)
                        local targetChar = plyr:GetData("Character")
                    
                        if targetChar then
                            targetChar:SetData("LSUNDGBan", nil)
                        end
                    

                        cb(true)
                    else
                        cb(false)
                    end
                end)
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)

    SetupHeistQueue()
end)

RegisterNetEvent("Laptop:ServerHeists:LeaderPickup", function(teamId)
    if _heisting[teamId] then
        local team = Laptop.Teams:Get(teamId)
        if team then
            local leader = nil
            for _, member in ipairs(team.Members) do
                if member.Leader then
                    leader = member
                    break
                end
            end
            
            if leader then
                local laptopItem = _heistLaptops[_heisting[teamId].heistType]
                if laptopItem then
                    local plyr = Fetch:CharacterSource(leader.SID)
                    local char = plyr:GetData("Character")
                    if plyr then
                        Inventory:AddItem(char:GetData("SID"), laptopItem, 1, {}, 1)
                        
                        Laptop.Teams.Members:Notification(
                            teamId,
                            "Heist Preparation",
                            "The team leader has received the necessary equipment to start the heist. Go to the Heist location!",
                            os.time() * 1000,
                            15000,
                            "lsunderground",
                            {},
                            {}
                        )
                        
                        Laptop.Teams.Members:SendEvent(teamId, "Laptop:ClientHeists:ContinueToBank", {
                            bankLocation = _heisting[teamId].bankLocation,
                            teamId = teamId
                        })
                    end
                end
            end
        end
    end
end)

RegisterNetEvent("Laptop:ServerHeists:CompleteHeist", function(teamId, moneyAmount)
    local source = source
    local plyr = Fetch:CharacterSource(source)
    local char = plyr:GetData("Character")
    
    if not plyr then return end
    
    local team = Laptop.Teams:Get(teamId)
    if not team then return end
    
    local isTeamMember = false
    local isLeader = false
    
    for _, member in ipairs(team.Members) do
        if member.Source == source then
            isTeamMember = true
            if member.Leader then
                isLeader = true
            end
            break
        end
    end
    
    if not isTeamMember or not isLeader then
        -- Only team leader can complete the heist
        return
    end
    
    LAPTOP.Heists:Complete(teamId, moneyAmount)
end)

RegisterNetEvent("Laptop:ServerHeists:AtPickupPoint", function(teamId)
    if _heisting[teamId] then
        local team = Laptop.Teams:Get(teamId)
        if team then
            _heisting[teamId].state = 1

            Laptop.Teams.Members:Notification(
                teamId,
                "Heist Preparation",
                "Equipment acquired! Now head to the target location.",
                os.time() * 1000,
                15000,
                "lsunderground",
                {},
                {}
            )

            Laptop.Teams.Members:SendEvent(teamId, "Laptop:ClientHeists:ContinueToBank", {
                bankLocation = _heisting[teamId].bankLocation
            })

            Laptop.Teams.Members:SendEvent(teamId, "Laptop:ClientHeists:RemoveBlip", "heist-pickup")
        end
    end
end)

AddEventHandler("Laptop:ServerHeists:ActionRequest", function(source, data, action)
    if action == "accept" and data?.requester and data?.contract then
        local plyr = Fetch:CharacterSource(source)
        local owner = plyr:GetData("Character")
        local team, isLeader = Laptop.Teams:GetByMemberSource(data.requester)

        if not team then return; end

        local contracts = owner:GetData("HeistContracts") or {}
        local perm = owner:GetData("LaptopPermissions")
        local updated = false

        for k, v in ipairs(contracts) do
            if v.id == data.contract then
                if team?.ID and team.State == 0 and (#team.Members >= 2 or (perm["lsunderground"] and perm["lsunderground"]["admin"])) then
                    local fail = false
                    for k, v in ipairs(team.Members) do
                        local plyr = Fetch:CharacterSource(v.Source)
                        local char = plyr:GetData("Character")
                        if plyr then
                            local alias = char:GetData("Profiles")
                            local hasVpn = hasValue(plyr:GetData("States") or {}, "PHONE_VPN")
                            local isLSU = hasValue(plyr:GetData("States") or {}, "ACCESS_LSUNDERGROUND")

                            local isPolice = Player(plyr:GetData("Source")).state.onDuty == "police"

                            if not alias?.heists.name or not hasVpn or not isLSU or isPolice then
                                fail = true
                                break 
                            end
                        else
                            fail = true
                            break
                        end
                        --else
                            --fail = true
                            --break
                        --end
                    end

                    if not fail then
                        if Crypto.Exchange:Remove(v.price.coin, owner:GetData("CryptoWallet"), v.price.price) then
                            table.remove(contracts, k)
                            updated = true
    
                            LAPTOP.Heists:Start(team.ID, v)
                        else
                            for _, m in ipairs(team.Members) do
                                Laptop.Notification:Add(m.Source, "Failed to Start Heist Contract", string.format("%s %s doesn't have enough crypto to start the contract.", owner:GetData("First"), owner:GetData("Last")), os.time() * 1000, 10000, "lsunderground", {}, {})
                            end
                        end
                    else
                        Laptop.Teams.Members:Notification(
                            team.ID,
                            "Unable to Start Contract",
                            "Some of your team members don't meet the entry requirements",
                            os.time() * 1000,
                            15000,
                            "lsunderground",
                            {},
                            {}
                        )
                    end
                end

                break
            end
        end

        if updated then
            owner:SetData("HeistContracts", contracts)
        end
    end
end)

LAPTOP.Heists = {
    GiveContract = function(self, source, heistData, price, timeLength, settings)
        local char = Fetch:CharacterSource(source)

        if not timeLength then
            timeLength = 60 * 60 * 1 -- 1 hour by default
        end

        if plyr then
            local alias = char:GetData("Profiles").heists.name
            local contracts = char:GetData("HeistContracts") or {}

            _heistIds = _heistIds + 1

            local heistContract = {
                id = _heistIds,
                owner = {
                    SID = char:GetData("SID"),
                    Alias = alias,
                },
                heistName = heistData.heistType .. " Heist",
                heistType = heistData.heistType,
                difficulty = heistData.difficulty,
                price = price,
                expires = os.time() + timeLength,
                settings = settings or {},
                reward = heistData.reward,
                xpReward = heistData.xpReward,
                minTeamSize = heistData.minTeamSize,
                rewarded = heistData.rewarded or false
            }

            table.insert(contracts, heistContract)
            char:SetData("HeistContracts", contracts)

            if not _heistContractCount[char:GetData("SID")] then
                _heistContractCount[char:GetData("SID")] = 1
            else
                _heistContractCount[char:GetData("SID")] = _heistContractCount[char:GetData("SID")] + 1
            end

            Logger:Info("Heists", string.format("%s [%s %s (%s)] Rewarded %s Contract (%s)%s", 
                alias, 
                char:GetData("First"), 
                char:GetData("Last"), 
                char:GetData("SID"), 
                heistData.heistType,
                heistData.difficulty,
                heistData.rewarded and " (Manually Created)" or ""
            ))

            Laptop.Notification:Add(
                source,
                "New Heist Contract Available",
                string.format("A New %s Heist Contract Now Available For %s $%s", heistData.heistType, price.price, price.coin),
                os.time() * 1000,
                10000,
                "lsunderground",
                {
                    view = "",
                }
            )

            return true
        end
        return false
    end,
    Start = function(self, teamId, contract)
        local team = Laptop.Teams:Get(teamId)
        if team and contract and contract?.heistType then
            local pickupLocations = _pickitemloction[contract.heistType] or _pickitemloction["Fleeca"]
            local pickupLocation = pickupLocations[math.random(#pickupLocations)]
    
            local bankLocations = _bankLocations[contract.heistType] or _bankLocations["Store"]
            local bankLocation = bankLocations[math.random(#bankLocations)]
    
            local baseXP = 250
            local difficultyMultiplier = 1.0
            if contract.difficulty == "Medium" then difficultyMultiplier = 1.5
            elseif contract.difficulty == "Hard" then difficultyMultiplier = 2.0 end
    
            local xpReward = math.floor(baseXP * difficultyMultiplier)
    
            local leader = nil
            for _, member in ipairs(team.Members) do
                if member.Leader then
                    leader = member
                    break
                end
            end
    
            _heisting[team.ID] = {
                team = team.ID,
                state = 0,
                contractOwner = contract.owner,
                heistName = contract.heistName,
                heistType = contract.heistType,
                difficulty = contract.difficulty,
                members = team.Members,
                pickupLocation = pickupLocation,
                bankLocation = bankLocation,
                settings = contract.settings,
                xpReward = xpReward,
                coin = contract.price.coin,
                price = contract.price.price,
                startTime = os.time(),
                leaderSID = leader and leader.SID or nil
            }
    
            Laptop.Teams:SetState(team.ID, "heisting", string.format("On %s Heist", contract.heistType))
    
            Laptop.Teams.Members:SendEvent(team.ID, "Laptop:ClientHeists:StartPickupPhase", {
                teamId = team.ID,
                heistType = contract.heistType,
                difficulty = contract.difficulty,
                pickupLocation = pickupLocation
            })
    
            return true
        end
        return false
    end,    
    Cancel = function(self, teamId, teamDeleted)
        if _heisting[teamId] then
            if not teamDeleted then
                Laptop.Teams:ResetState(teamId)
                Laptop.Teams.Members:NotificationRemoveById(teamId, "HEIST_CONTRACT")
                Laptop.Teams.Members:Notification(
                    teamId,
                    "Heist Cancelled",
                    "Your team failed to complete the heist.",
                    os.time() * 1000,
                    15000,
                    "lsunderground",
                    {},
                    {}
                )
                Laptop.Teams.Members:SendEvent(teamId, "Laptop:ClientHeists:End", true)
            end

            _heisting[teamId] = nil
        end
    end,
    Complete = function(self, teamId, moneyAmount)
        if _heisting[teamId] then
            local heistData = _heisting[teamId]
            local endTime = os.time()
            local durationSeconds = endTime - heistData.startTime
            local durationString = ""
            
            if durationSeconds < 60 then
                durationString = string.format("%d seconds", durationSeconds)
            elseif durationSeconds < 3600 then
                local minutes = math.floor(durationSeconds / 60)
                local seconds = durationSeconds % 60
                durationString = string.format("%d minutes %d seconds", minutes, seconds)
            else
                local hours = math.floor(durationSeconds / 3600)
                local minutes = math.floor((durationSeconds % 3600) / 60)
                durationString = string.format("%d hours %d minutes", hours, minutes)
            end
    
            local teammateAliases = {}
            for _, teammate in ipairs(heistData.members) do
                local plyr = Fetch:CharacterSource(teammate.Source)
                local teammateChar = plyr:GetData("Character")
                if teammateChar then
                    local aliasData = plyr:GetData("Profiles")
                    local heistAlias = (aliasData and aliasData.heists.name) or "Unknown Alias"
                    teammateAliases[teammate.Source] = heistAlias
                end
            end
    
            for _, member in ipairs(heistData.members) do
                Reputation.Modify:Add(member.Source, "Heists", heistData.xpReward)

                local currentRep = Reputation:ViewList(member.Source, { Heists = true }) or {}
                local repHeists = tonumber(currentRep.Heists) or 0

                local plyr = Fetch:CharacterSource(member.Source)
                local memberChar = plyr:GetData("Character")
    
                --if memberChar then
                    local aliasData = memberChar:GetData("Profiles")
                    local heistAlias = (aliasData and aliasData.heists.name) or "Unknown"
                    local playerSID = memberChar:GetData("SID")
    
                    exports['oxmysql']:execute(
                        "INSERT INTO heist_leaderboard (sid, alias, xp, completed_heists, total_earnings) "..
                        "VALUES (?, ?, ?, 1, ?) "..
                        "ON DUPLICATE KEY UPDATE "..
                        "xp = GREATEST(xp, VALUES(xp)), "..
                        "alias = VALUES(alias), "..
                        "completed_heists = completed_heists + 1, "..
                        "total_earnings = total_earnings + ?",
                        {playerSID, heistAlias, repHeists, moneyAmount, moneyAmount},
                        function(err)
                            if err then
                                print("Leaderboard update error for", playerSID, ":", err)
                            end
                        end
                    )
    
                    local history = memberChar:GetData("HeistHistory") or {}
                    local teammatesList = {}
                    for source, alias in pairs(teammateAliases) do
                        if source == member.Source then
                            table.insert(teammatesList, { alias = alias .. " (YOU)" })
                        else
                            table.insert(teammatesList, { alias = alias })
                        end
                    end
    
                    local teammateCount = 0
                    for _ in pairs(teammateAliases) do teammateCount = teammateCount + 1 end
    
                    table.insert(history, {
                        id = #history + 1,
                        heistName = heistData.heistName,
                        completedAt = endTime,
                        duration = durationString,
                        teammates = teammatesList,
                        xpGained = heistData.xpReward,
                        cashGained = moneyAmount,
                        details = (teammateCount > 1 and 
                        string.format("You and %d others successfully robbed %s", teammateCount - 1, heistData.heistName)) or 
                        string.format("You successfully robbed %s", heistData.heistName)
                    })
    
                    if #history > 50 then
                        table.remove(history, 1)
                    end
                    memberChar:SetData("HeistHistory", history)
    
                    if member.SID == heistData.leaderSID then
                        Logger:Info("Heists", string.format("%s [%s] Completed %s Heist (%s). Duration: %s, Money Earned: %s %s",
                            heistAlias,
                            memberChar:GetData("SID"),
                            heistData.heistType,
                            heistData.difficulty,
                            durationString,
                            moneyAmount,
                            heistData.coin
                        ))
                    end
                --end
            end
    
            Laptop.Teams:ResetState(teamId)
            Laptop.Teams.Members:NotificationRemoveById(teamId, "HEIST_CONTRACT")
            Laptop.Teams.Members:SendEvent(teamId, "Laptop:ClientHeists:End")
    
            Laptop.Teams.Members:Notification(
                teamId,
                "Heist Completed",
                string.format("Your team has successfully completed the %s heist!", heistData.heistType),
                os.time() * 1000,
                15000,
                "lsunderground",
                {},
                {}
            )
            _heisting[teamId] = nil
        end
    end,
}

function SetupHeistQueue()
    CreateThread(function()
        Wait(60000)
        Logger:Info("Heists", "Heist Contracts Can Now Be Rewarded")

        while true do
            if #_heistQueue > 0 then
                local index = math.random(#_heistQueue)

                if _heistQueue[index] then
                    local plyr = Fetch:CharacterSource(_heistQueue[index].source)
                    if plyr then
                        local char = plyr:GetData("Character")
                        if plyr then
                            local holdingContracts = plyr:GetData("HeistContracts") or {}
                            local contractCount = 0

                            for k, v in ipairs(holdingContracts) do
                                if v.expires >= os.time() then
                                    contractCount += 1
                                end
                            end

                            if not _heisting[_heistQueue[index].team] and contractCount < 4 then
                                local heistTypes = {"Fleeca", "Paleto"}
                                local heistType = heistTypes[math.random(#heistTypes)]
                                
                                local difficulties = {"Easy", "Medium", "Hard"}
                                local difficulty = difficulties[math.random(#difficulties)]
                                
                                local basePrice = 20
                                if heistType == "Fleeca" then 
                                    basePrice = 30
                                    minTeamSize = 4
                                elseif heistType == "Paleto" then 
                                    basePrice = 50
                                    minTeamSize = 8
                                end
                                
                                if difficulty == "Medium" then basePrice = basePrice * 1.5
                                elseif difficulty == "Hard" then basePrice = basePrice * 2
                                end
                                
                                LAPTOP.Heists:GiveContract(plyr:GetData("Source"), {
                                    heistType = heistType,
                                    difficulty = difficulty
                                    
                                }, {
                                    price = math.floor(basePrice),
                                    coin = "HEIST"
                                })
                            end
                        end
                    end
                end
            end
            -- math.random(10, 30)
            Wait((1000 * 60))
        end
    end)
end

AddEventHandler("Laptop:Server:Teams:MemberRemoved", function(teamId, member)
    local team = Laptop.Teams:Get(teamId)
    if team and team.Members and #team.Members < 2 then -- No longer enough people
        for k, v in ipairs(_heistQueue) do
            if v.team == teamId and (not v.admin or v.source == member.Source) then
                TriggerClientEvent("Laptop:Client:SetData", v.source, "heistQueue", nil)
                
                Laptop.Notification:Add(
                    v.source,
                    "No Longer in Queue",
                    "You were removed from the heist queue since you are no longer eligible.",
                    os.time() * 1000,
                    10000,
                    "lsunderground",
                    {
                        view = "",
                    }
                )

                table.remove(_heistQueue, k)
            end
        end

        if _heisting[teamId] then
            LAPTOP.Heists:Cancel(teamId)
        end
    end
end)

AddEventHandler("Laptop:Server:Teams:Deleted", function(teamId)
    for k, v in ipairs(_heistQueue) do
        if v.team == teamId then
            TriggerClientEvent("Laptop:Client:SetData", v.source, "heistQueue", nil)
            
            Laptop.Notification:Add(
                v.source,
                "No Longer in Queue",
                "You were removed from the heist queue since your team was deleted.",
                os.time() * 1000,
                10000,
                "lsunderground",
                {
                    view = "",
                }
            )

            table.remove(_heistQueue, k)
        end
    end

    if _heisting[teamId] then
        LAPTOP.Heists:Cancel(teamId, true)
    end
end)
