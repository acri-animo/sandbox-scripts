RegisterNUICallback("PDMGetDealerData", function(data, cb)
	Callbacks:ServerCallback("Dealerships:GetDealershipData", { dealerId = LocalPlayer.state.onDuty }, cb)
end)

RegisterNUICallback("PDMSaveDealerData", function(data, cb)
	Callbacks:ServerCallback("Dealerships:UpdateDealershipData", {
		dealerId = LocalPlayer.state.onDuty,
		updating = data.data,
	}, cb)
end)

RegisterNUICallback("PDMGetStock", function(data, cb)
	Callbacks:ServerCallback(
		"Dealerships:Sales:FetchData",
		LocalPlayer.state.onDuty,
		function(authed, stocks, defaultInterestRate, dealerData)
			if authed then
				cb({
					stock = stocks,
					dealerData = dealerData,
					interest = defaultInterestRate,
				})
			else
				cb(false)
			end
		end
	)
end)

RegisterNUICallback("DealershipStartTestDrive", function(data, cb)
	Callbacks:ServerCallback("Dealerships:Sales:TestDrive", {
		dealership = LocalPlayer.state.onDuty,
		data = {
			vehicle = data.vehicle,
			modelType = data.modelType,
		},
	}, function(success, message)
		cb({
			success = success,
			message = message,
		})
	end)
end)

RegisterNUICallback("DealershipSetStock", function(data, cb)
	Callbacks:ServerCallback("Dealerships:Sales:SetStock", {
		dealership = LocalPlayer.state.onDuty,
		data = {
			vehicle = data.vehicle,
			modelType = data.modelType,
			class = data.class,
			quantity = data.quantity,
			price = data.price,
			make = data.make,
			model = data.model,
			category = data.category,
		},
	}, function(success, message)
		cb({success = success, message = message,})
		print(success, message)
		if success then
			CarryOn(data)
		end
	end)
end)

function CarryOn(vehData)
	Callbacks:ServerCallback("Dealerships:Sales:StartStockLoad", {
		dealership = LocalPlayer.state.onDuty,
		data = {
			vehData
		},
	}, function()
		print("done")
	end)
end

RegisterNUICallback("PDMRunCredit", function(data, cb)
	Callbacks:ServerCallback(
		"Dealerships:CheckPersonsCredit",
		{ dealerId = LocalPlayer.state.onDuty, SID = data.term },
		cb
	)
end)

RegisterNUICallback("PDMStartSale", function(data, cb)
	Callbacks:ServerCallback("Dealerships:Sales:StartSale", {
		dealership = LocalPlayer.state.onDuty,
		type = data.type,
		data = {
			vehicle = data.vehicle,
			customer = data.SID,
			downPayment = data.downpayment,
			loanWeeks = data.weeks,
		},
	}, function(success, message)
		cb({
			success = success,
			message = message,
		})
	end)
end)

RegisterNUICallback("PDMGetHistory", function(data, cb)
	Callbacks:ServerCallback("Dealerships:FetchHistory", {
		dealership = LocalPlayer.state.onDuty,
		term = data.value,
		category = data.category,
		page = data.page,
	}, function(penis)
		if penis then
			cb(penis)
		else
			cb(false)
		end
	end)
end)

RegisterNUICallback("PDMGetOwner", function(data, cb)
	Callbacks:ServerCallback(
		"Dealerships:FetchCurrentOwner",
		{ dealerId = LocalPlayer.state.onDuty, VIN = data.VIN },
		function(penis)
			if penis then
				cb(penis)
			else
				cb(false)
			end
		end
	)
end)

RegisterNetEvent("Dealerships:Client:SpawnStockTrailer", function(data)
    print(json.encode(data))
    -- local blip = AddBlipForEntity(1138.197, -3273.497, 5.899)
    -- SetBlipSprite(blip, 479) 
    -- SetBlipScale(blip, 0.85)
    -- SetBlipColour(blip, 3)
    -- BeginTextCommandSetBlipName("STRING")
    -- AddTextComponentString("Stock Trailer")
    -- EndTextCommandSetBlipName(blip)

   
end)

