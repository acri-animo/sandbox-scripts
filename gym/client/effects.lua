RegisterNetEvent("Gym:Client:PlayerInit", function(gymRep)
    if not gymRep then
        return
    end

    local workoutEffects = {
        situps = { stat = "MP0_STAMINA", boostPerRep = 0.01, maxBoost = 15.0 },
        pushups = { stat = "MP0_STRENGTH", boostPerRep = 0.01, maxBoost = 15.0 },
        curls = { stat = "MP0_STRENGTH", boostPerRep = 0.01, maxBoost = 10.0 },
        pullups = { stat = "MP0_STRENGTH", boostPerRep = 0.01, maxBoost = 15.0 },
        jogging = { stat = "MP0_STAMINA", boostPerRep = 0.01, maxBoost = 15.0 },
        yoga = { stat = "MP0_LUNG_CAPACITY", boostPerRep = 0.05, maxBoost = 10.0 },
    }

    for workout, reps in pairs(gymRep) do
        if workout ~= "last_updated" then
            local effect = workoutEffects[workout]
            if effect and type(reps) == "number" and reps > 0 then
                local boost = math.min(reps * effect.boostPerRep, effect.maxBoost)
                
                if effect.stat then
                    local currentStat = StatGetInt(GetHashKey(effect.stat))
                    local newStat = math.floor(currentStat + boost)
                    StatSetInt(GetHashKey(effect.stat), newStat, true)
                    print(string.format("[Gym:Client] Applied %s boost: +%.2f (Total: %d)", workout, boost, newStat))
                end
            elseif not effect then
                print("[Gym:Client] Warning: No effect defined for workout: " .. workout)
            end
        end
    end
end)