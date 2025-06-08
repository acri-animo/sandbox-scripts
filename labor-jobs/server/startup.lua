--[[
    Rep Ideas?

    Farming: Sell food mats in bulk?
    Salvage: Gain access to chop-lists (Will be a separate thing from boosting, chopping will be NPC-driven stuff that will give raw materials and rarely car parts opposed to boosting)
    Garbage: Gain access to pawn shop stuff allowing people to sell off chains/watches/etc
    Mining: Gain access to selling gems? And/Or crafting bench to smelt?
    Hunting: Gain access to selling hides?
    Fishing: ????
]]

local _ran = false
AddEventHandler("Labor:Server:Startup", function()
    if _ran then
        return
    end
    _ran = true

    Labor.Jobs:Register(
        "HouseRobbery",
        "House Robbery",
        4,
        0,
        85,
        {
            state = "SCRIPT_HOUSE_ROBBERY",
        },
        {
            { label = "Rank 1", value = 1000 },
            { label = "Rank 2", value = 3000 },
            { label = "Rank 3", value = 6000 },
            { label = "Rank 4", value = 16000 },
            { label = "Rank 5", value = 30000 },
        },
        false,
        {
            Duration = 60 * 10,
            Message = "If you won't do the job, I'll give it to someone else",
        }
    )

    Labor.Jobs:Register(
        "OxyRun",
        "Oxy",
        4,
        0,
        85,
        {
            state = "SCRIPT_OXY_RUN",
        },
        {
            { label = "Rank 1", value = 1000 },
            { label = "Rank 2", value = 2000 },
            { label = "Rank 3", value = 4000 },
            { label = "Rank 4", value = 8000 },
            { label = "Rank 5", value = 12000 },
        },
        false,
        {
            Duration = 60 * 20,
            Message = "You took too damn long, maybe next time",
        }
    )

    Labor.Jobs:Register(
        "WeedRun",
        "Weed Distribution",
        0,
        0,
        50,
        {
            state = "SCRIPT_WEED_RUN",
        },
        {
            { label = "Rank 1", value = 1000 },
            { label = "Rank 2", value = 2500 },
            { label = "Rank 3", value = 5000 },
            { label = "Rank 4", value = 10000 },
            { label = "Rank 5", value = 25000 },
            { label = "Rank 6", value = 50000 },
            { label = "Rank 7", value = 100000 },
            { label = "Rank 8", value = 250000 },
            { label = "Rank 9", value = 500000 },
            { label = "Rank 10", value = 1000000 },
        },
        false,
        {
            KeepRep = true,
            Duration = 60 * 20,
            Message = "Let Me Know If You Want To Do More Runs",
        }
    )

    Labor.Jobs:Register(
        "CornerDealing",
        "Corner Dealing",
        4,
        0,
        50,
        {
            state = "SCRIPT_CORNER_DEALING",
        },
        {
            { label = "Rank 1", value = 1000 },
            { label = "Rank 2", value = 2500 },
            { label = "Rank 3", value = 5000 },
            { label = "Rank 4", value = 10000 },
            { label = "Rank 5", value = 25000 },
            { label = "Rank 6", value = 50000 },
            { label = "Rank 7", value = 100000 },
            { label = "Rank 8", value = 250000 },
            { label = "Rank 9", value = 500000 },
            { label = "Rank 10", value = 1000000 },
        },
        false,
        {
            KeepRep = true,
            Duration = 60 * 20,
            Message = "Let me know if you have any more product you want to sell",
        }
    )

    Labor.Jobs:Register("Prison", "U SHOULDNT SEE THIS LOL", 0, 0, 0, {
        state = "SCRIPT_PRISON_JOB",
    }, {}, true)

    Labor.Jobs:Register("Hunting", "Hunting", 0, 1200, 50, false, {
        { label = "Rank 1", value = 1500 },
        { label = "Rank 2", value = 3000 },
        { label = "Rank 3", value = 6000 },
        { label = "Rank 4", value = 9000 },
        { label = "Rank 5", value = 12000 },
        { label = "Rank 6", value = 22000 },
        { label = "Rank 7", value = 35000 },
        { label = "Rank 8", value = 40000 },
    })

    Labor.Jobs:Register("Mining", "Mining", 0, 1000, 50, false, {
        { label = "Rank 1", value = 1500 },
        { label = "Rank 2", value = 3000 },
        { label = "Rank 3", value = 7000 },
        { label = "Rank 4", value = 10000 },
        { label = "Rank 5", value = 12000 },
        { label = "Rank 6", value = 15000 },
        { label = "Rank 7", value = 18000 },
        { label = "Rank 8", value = 21000 },
        { label = "Rank 9", value = 24000 },
        { label = "Rank 10", value = 30000 },
        { label = "Rank 11", value = 35000 },
        { label = "Rank 12", value = 40000 },
        { label = "Rank 13", value = 45000 },
        { label = "Rank 14", value = 50000 },
        { label = "Rank 15", value = 55000 },
        { label = "Rank 16", value = 60000 },
        { label = "Rank 17", value = 65000 },
        { label = "Rank 18", value = 70000 },
        { label = "Rank 19", value = 75000 },
        { label = "Max Rank", value = 80000 },
    })

    Labor.Jobs:Register("Farming", "Farming", 0, 1200, 50)

    Labor.Jobs:Register("Tobacco", "Tobacco", 0, 1500, 50)

    Labor.Jobs:Register("Diving", "Diving", 0, 2000, 50)

    Labor.Jobs:Register("Halloween", "Grave Digging", 0, 2500, 50, {
        state = "SCRIPT_GRAVE_DIGGER",
    }, {
        { label = "Rank 1", value = 1000 },
        { label = "Rank 2", value = 2500 },
        { label = "Rank 3", value = 5000 },
        { label = "Rank 4", value = 7500 },
        { label = "Rank 5", value = 10000 },
        { label = "Rank 6", value = 15000 },
        { label = "Rank 7", value = 20000 },
        { label = "Rank 8", value = 25000 },
        { label = "Rank 9", value = 50000 },
        { label = "Rank 10", value = 100000 },
    },
    false,
        {
            KeepRep = true,
            Duration = 60 * 20,
            Message = "Let me know if you want to do dig more graves",
        }
    )

    Labor.Jobs:Register("Salvaging", "Salvaging", 0, 1000, 50, false, {
        { label = "Rank 1", value = 1500 },
        { label = "Rank 2", value = 3000 },
        { label = "Rank 3", value = 7000 },
        { label = "Rank 4", value = 10000 },
        { label = "Rank 5", value = 12000 },
        { label = "Rank 6", value = 15000 },
        { label = "Rank 7", value = 18000 },
        { label = "Rank 8", value = 21000 },
        { label = "Rank 9", value = 24000 },
        { label = "Rank 10", value = 30000 },
        { label = "Rank 11", value = 35000 },
        { label = "Rank 12", value = 40000 },
        { label = "Rank 13", value = 45000 },
        { label = "Rank 14", value = 50000 },
        { label = "Rank 15", value = 55000 },
        { label = "Rank 16", value = 60000 },
        { label = "Rank 17", value = 65000 },
        { label = "Rank 18", value = 70000 },
        { label = "Rank 19", value = 75000 },
        { label = "Max Rank", value = 80000 },
    })

    Labor.Jobs:Register("Garbage", "Garbage", 0, 1500, 50, false, {
        { label = "Rank 1", value = 1500 },
        { label = "Rank 2", value = 3000 },
        { label = "Rank 3", value = 7000 },
        { label = "Rank 4", value = 10000 },
        { label = "Rank 5", value = 12000 },
        { label = "Rank 6", value = 15000 },
        { label = "Rank 7", value = 18000 },
        { label = "Rank 8", value = 21000 },
        { label = "Rank 9", value = 24000 },
        { label = "Rank 10", value = 30000 },
        { label = "Rank 11", value = 35000 },
        { label = "Rank 12", value = 40000 },
        { label = "Rank 13", value = 45000 },
        { label = "Rank 14", value = 50000 },
        { label = "Rank 15", value = 55000 },
        { label = "Rank 16", value = 60000 },
        { label = "Rank 17", value = 65000 },
        { label = "Rank 18", value = 70000 },
        { label = "Rank 19", value = 75000 },
        { label = "Max Rank", value = 80000 },
    })

    Labor.Jobs:Register("Fishing", "Fishing", 0, 1000, 50)

    Labor.Jobs:Register("Coke", "THIS SHOULD NOT BE SEEN", 1, 0, 50, {
        state = "SCRIPT_COKE_RUN",
    }, {
        { label = "Rank 1", value = 1500 },
        { label = "Rank 2", value = 3000 },
        { label = "Rank 3", value = 7000 },
        { label = "Rank 4", value = 10000 },
        { label = "Rank 5", value = 12000 },
    }, true)

    Labor.Jobs:Register("Postal", "Postal", 0, 1500, 85, false, {
        { label = "Rank 1", value = 1500 },
        { label = "Rank 2", value = 3000 },
        { label = "Rank 3", value = 7000 },
        { label = "Rank 4", value = 10000 },
        { label = "Rank 5", value = 12000 },
    })

    Labor.Jobs:Register("Newspaper", "Newspaper", 0, 1500, 85, false, {
        { label = "Rank 1", value = 1500 },
        { label = "Rank 2", value = 3000 },
        { label = "Rank 3", value = 7000 },
        { label = "Rank 4", value = 10000 },
        { label = "Rank 5", value = 12000 },
    })

    Labor.Jobs:Register("Trucking", "Trucking", 0, 1500, 50, false, {
        { label = "Rank 1", value = 1500 },
        { label = "Rank 2", value = 3000 },
        { label = "Rank 3", value = 7000 },
        { label = "Rank 4", value = 10000 },
        { label = "Rank 5", value = 12000 },
        { label = "Rank 6", value = 15000 },
        { label = "Rank 7", value = 18000 },
        { label = "Rank 8", value = 21000 },
        { label = "Rank 9", value = 24000 },
        { label = "Rank 10", value = 30000 },
        { label = "Rank 11", value = 35000 },
        { label = "Rank 12", value = 40000 },
        { label = "Rank 13", value = 45000 },
        { label = "Rank 14", value = 50000 },
        { label = "Rank 15", value = 55000 },
        { label = "Rank 16", value = 60000 },
        { label = "Rank 17", value = 65000 },
        { label = "Rank 18", value = 70000 },
        { label = "Rank 19", value = 75000 },
        { label = "Max Rank", value = 80000 },
    })
end)