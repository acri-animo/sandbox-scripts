function BigPharmThreads()
	Citizen.CreateThread(function()
		while LocalPlayer.state.loggedIn do
			local myCoords = GetEntityCoords(LocalPlayer.state.ped)
			for k, v in ipairs(_bigPharmHacks) do
				if
					#(myCoords - v.coords) <= 200
					and GlobalState[string.format("BigPharm:ManualDoor:%s", v.doorId)] ~= nil
					and GlobalState[string.format("BigPharm:ManualDoor:%s", v.doorId)].state == 3
				then
					OpenDoor(v.coords, v.doorConfig)
				end
			end
			Citizen.Wait(1000)
		end
	end)
end

