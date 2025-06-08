local _threading = false

function StartAmmunationThreads()
    if _threading then return end
    _threading = true

    Citizen.CreateThread(function()
        while _threading do
            if _ammuGlobalReset ~= nil then
                if os.time() > _ammuGlobalReset then
                    Logger:Info("Robbery", "Ammunation Heist Has Been Reset")
                    ResetAmmunation()
                end
            end
            Citizen.Wait(30000)
        end
    end)
end