local _threading = false

function StartBigPharmThreads()
    if _threading then return end
    _threading = true


	Citizen.CreateThread(function()
		while _threading do
			if _bigPharmGlobalReset ~= nil then
				if os.time() > _bigPharmGlobalReset then
					Logger:Info("Robbery", "Big Pharm Heist Has Been Reset")
					ResetBigPharm()
				end
			end
			Citizen.Wait(30000)
		end
	end)
end
