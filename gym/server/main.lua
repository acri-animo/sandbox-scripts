AddEventHandler("Gym:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
    Fetch = exports["lumen-base"]:FetchComponent("Fetch")
    Logger = exports["lumen-base"]:FetchComponent("Logger")
    Callbacks = exports["lumen-base"]:FetchComponent("Callbacks")
    Inventory = exports["lumen-base"]:FetchComponent("Inventory")
    Banking = exports["lumen-base"]:FetchComponent("Banking")
    Wallet = exports["lumen-base"]:FetchComponent("Wallet")
    Execute = exports["lumen-base"]:FetchComponent("Execute")
    Reputation = exports["lumen-base"]:FetchComponent("Reputation")
    Middleware = exports["lumen-base"]:FetchComponent("Middleware")
end

AddEventHandler("Core:Shared:Ready", function()
    exports["lumen-base"]:RequestDependencies("Gym", {
        "Fetch",
        "Logger",
        "Callbacks",
        "Inventory",
        "Wallet",
        "Execute",
        "Reputation",
        "Middleware",
    }, function(error)
        if #error > 0 then
            return
        end
        RetrieveComponents()
        TriggerEvent("Gym:Server:Setup")
    end)
end)

AddEventHandler("Gym:Server:Setup", function()
    Reputation:Create("Gym", "Gym", {
        { label = "Rank 1", value = 1000 },
        { label = "Rank 2", value = 2000 },
        { label = "Rank 3", value = 4000 },
        { label = "Rank 4", value = 8000 },
        { label = "Rank 5", value = 16000 },
        { label = "Rank 6", value = 32000 },
        { label = "Rank 7", value = 64000 },
        { label = "Rank 8", value = 128000 },
        { label = "Rank 9", value = 256000 },
        { label = "Rank 10", value = 1000000 },
    }, false)

    Middleware:Add("Characters:Spawning", function(source)
        local char = Fetch:CharacterSource(source)
    
        local gymRep = char:GetData("GymRep") or {
            situps = 0,
            pushups = 0,
            curls = 0,
            pullups = 0,
            jogging = 0,
            yoga = 0,
            last_updated = os.time(),
        }

        if not char:GetData("GymRep") then
            char:SetData("GymRep", gymRep)
        end
    
        TriggerClientEvent("Gym:Client:PlayerInit", source, gymRep)
    end, 1)

    Callbacks:RegisterServerCallback("Gym:GetRep", function(source, data, cb)
        local char = Fetch:CharacterSource(source)
        local gymRep = char:GetData("GymRep")

        if gymRep then
            local clientGymRep = {
                gym = {
                    skills = {
                        { id = "situps", label = "Situps", value = gymRep.situps, level = 0, nextRep = 1000 },
                        { id = "pushups", label = "Pushups", value = gymRep.pushups, level = 0, nextRep = 1000 },
                        { id = "curls", label = "Curls", value = gymRep.curls, level = 0, nextRep = 1000 },
                        { id = "pullups", label = "Pullups", value = gymRep.pullups, level = 0, nextRep = 1000 },
                        { id = "yoga", label = "Yoga", value = gymRep.yoga, level = 0, nextRep = 1000 },
                        { id = "jogging", label = "Jogging", value = gymRep.jogging, level = 0, nextRep = 1000 },
                    },
                    last_updated = gymRep.last_updated,
                }
            }

            local ranks = {
                100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600, 100000
            }

            for _, skill in ipairs(clientGymRep.gym.skills) do
                for level, rankValue in ipairs(ranks) do
                    if skill.value < rankValue then
                        skill.level = level - 1
                        skill.nextRep = rankValue
                        break
                    elseif skill.value >= ranks[#ranks] then
                        skill.level = #ranks
                        skill.nextRep = ranks[#ranks]
                        break
                    end
                end
            end

            cb(clientGymRep)
        else
            cb(false)
        end
    end)

    Callbacks:RegisterServerCallback("Gym:UpdateRep", function(source, data, cb)
        local char = Fetch:CharacterSource(source)
        local gymRep = char:GetData("GymRep")
        local playerState = Player(source).state

        if playerState.exerciseCooldown[data.type] then
            Execute:Client(source, "Notification", "Error", "You are on cooldown for this exercise", 5000)
            cb(false)
            return
        end

        if gymRep then
            gymRep[data.type] = gymRep[data.type] + data.amount
            char:SetData("GymRep", gymRep)
            Reputation.Modify:Add(source, "Gym", data.amount * 10)
            cb(true)
        else
            cb(false)
        end
    end)

    Callbacks:RegisterServerCallback("Gym:PurchasePass", function(source, data, cb)
        local char = Fetch:CharacterSource(source)
        local sid = char:GetData("SID")
        local bankAcc = Banking.Accounts:GetPersonal(sid)
        local price = 500

        if bankAcc.Balance >= price then
            Inventory:AddItem(sid, "gym_pass", 1, {}, 1)
            Banking.Balance:Withdraw(bankAcc.Account, price, {
                type = "withdraw",
                title = "Gym Pass Purchase",
                description = "Purchased a gym pass",
            })

            cb(true)
        else
            cb(false)
        end
    end)
end)