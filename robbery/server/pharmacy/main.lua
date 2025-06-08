_bigPharmInUse = {
	bigpharm_1 = false,
	bigpharm_2 = false,
	bigpharm_3 = false,
	bigpharm_lootboi = false,
	powerBoxes = {},
	pharmPcs = {},
}

_bigPharmGlobalReset = nil
_bigPharmAlerted = false
_bigPharmPowerAlerted = false

local _heistCoin = false
local _heistCard = false
local _whiteDongie = false

local _bigPharmLoot = {
	{ 100, { name = "firstaid", min = 40, max = 50 }, looted = false },
	{ 100, { name = "epinephrine", min = 5, max = 7 }, looted = false },
	{ 100, { name = "oxy", min = 30, max = 40 }, looted = false },
	{ 100, { name = "morphine", min = 20, max = 30 }, looted = false },
	{ 100, { name = "hydrocodone", min = 15, max = 20 }, looted = false },
	{ 100, { name = "vicodin", min = 25, max = 30 }, looted = false },
	{ 100, { name = "trauma_kit", min = 5, max = 10 }, looted = false },
}

local _bigPharmShelfLoot = {
	{ 100, { name = "bandage", min = 10, max = 15 }, looted = false },
	{ 100, { name = "ifak", min = 3, max = 5 }, looted = false },
	{ 70, { name = "blueberry_gummy", min = 3, max = 5 }, looted = false },
	{ 70, { name = "apple_gummy", min = 3, max = 5 }, looted = false },
	{ 70, { name = "orange_gummy", min = 3, max = 5 }, looted = false },
	{ 70, { name = "grape_gummy", min = 3, max = 5 }, looted = false },
	{ 20, { name = "schlump_gummy", min = 3, max = 5 }, looted = false },
}

function BigPharmClearSourceInUse(source)
	for k, v in pairs(_bigPharmInUse) do
		if v == source then
			_bigPharmInUse[k] = nil
		elseif type(v) == "table" then
			for k2, v2 in pairs(v) do
				if v2 == source then
					_bigPharmInUse[k][k2] = nil
				end
			end
		end
	end
end

function IsBigPharmPowerDisabled()
	for k, v in ipairs(_bigPharmElectric) do
		if
			not GlobalState[string.format("BigPharm:Power:%s", v.data.boxId)]
			or os.time() > GlobalState[string.format("BigPharm:Power:%s", v.data.boxId)]
		then
			return false
		end
	end
	return true
end

function BigPharmDisablePower(source)
	if not _bigPharmGlobalReset or os.time() > _bigPharmGlobalReset then
		_bigPharmGlobalReset = os.time() + BIGPHARM_RESET_TIME
	end
	for k, v in ipairs(_bigPharmElectric) do
		GlobalState[string.format("BigPharm:Power:%s", v.data.boxId)] = _bigPharmGlobalReset
	end

	Robbery:TriggerPDAlert(source, vector3(-3165.7583007812, 1092.34729, 20.926725), "10-33", "Minor Power Grid Disruption", {
		icon = 354,
		size = 0.9,
		color = 31,
		duration = (60 * 5),
	}, {
		icon = "bolt-slash",
		details = "Chumash Pharmacy",
	}, false, 50.0)

end

function ResetBigPharm()
	_bigPharmGlobalReset = nil
	_bigPharmInUse.pharmPcs.looted = false

	for k, v in pairs(_bigPharmElectric) do
		GlobalState[string.format("BigPharm:Power:%s", v.data.boxId)] = nil
	end

	for _, loot in ipairs(_bigPharmLoot) do
		loot[2].looted = false
	end

	for _, loot in ipairs(_bigPharmShelfLoot) do
		loot[2].looted = false
	end

	local desk = _bigPharmDesks[1]
    if desk then
		GlobalState[string.format("BigPharm:Offices:PC:%s", desk.data.deskId)] = nil
	end

	local lootDoor = _bigPharmLootDoor[1]
	if lootDoor then
		Doors:SetLock(lootDoor.door, true)
	end

	local entryDoor = _bigPharmEntryDoor[1]
	if entryDoor then
		Doors:SetLock(entryDoor.door, true)
	end

	for k, v in pairs(_bigPharmDoors) do
		Doors:SetLock(v.door, true)
	end

	_heistCoin = false
	_heistCard = false
	_bigPharmAlerted = false
	_bigPharmPowerAlerted = false
	_whiteDongie = false

	GlobalState["BigPharmInProgress"] = false
	GlobalState["BigPharm:Secured"] = false
end


function SecureBigPharm()
	_bigPharmGlobalReset = os.time() + BIGPHARM_RESET_TIME
	_bigPharmInUse.pharmPcs.looted = false

	for k, v in pairs(_bigPharmElectric) do
		GlobalState[string.format("BigPharm:Power:%s", v.data.boxId)] = nil
	end

	for _, loot in ipairs(_bigPharmLoot) do
		loot[2].looted = false
	end

	for _, loot in ipairs(_bigPharmShelfLoot) do
		loot[2].looted = false
	end

	local desk = _bigPharmDesks[1]
    if desk then
		GlobalState[string.format("BigPharm:Offices:PC:%s", desk.data.deskId)] = nil
	end

	local lootDoor = _bigPharmLootDoor[1]
	if lootDoor then
		Doors:SetLock(lootDoor.door, true)
	end

	local entryDoor = _bigPharmEntryDoor[1]
	if entryDoor then
		Doors:SetLock(entryDoor.door, true)
	end

	for k, v in ipairs(_bigPharmDoors) do
		Doors:SetLock(v.door, true)
	end

	_heistCoin = false
	_heistCard = false

	GlobalState["BigPharmInProgress"] = false
	GlobalState["BigPharm:Secured"] = _bigPharmGlobalReset
end


AddEventHandler("Characters:Server:PlayerLoggedOut", bigPharmClearSourceInUse)
AddEventHandler("Characters:Server:PlayerDropped", bigPharmClearSourceInUse)

AddEventHandler("Robbery:Server:Setup", function()
	StartBigPharmThreads()
	RegisterBigPharmItemUses()

	Reputation:Create("BigPharm", "Big Pharma", {
        { label = "Rank 1", value = 500 },
        { label = "Rank 2", value = 1000 },
        { label = "Rank 3", value = 2000 },
        { label = "Rank 4", value = 3000 },
        { label = "Rank 5", value = 4000 },
        { label = "Rank 6", value = 5000 },
    }, false)

	Chat:RegisterAdminCommand("resetbigpharm", function(source, args, rawCommand)
		ResetBigPharm()
	end, {
		help = "Force Reset Big Pharm Heist",
	}, 0)

	Callbacks:RegisterServerCallback("Robbery:BigPharm:SecureBank", function(source, data, cb)
		local char = Fetch:CharacterSource(source)
		if char ~= nil then
			if Player(source).state.onDuty == "police" then
				SecureBigPharm()
			end
		end
	end)

	Callbacks:RegisterServerCallback("Robbery:BigPharm:ElectricBox:Hack", function(source, data, cb)
		local char = Fetch:CharacterSource(source)
		if char ~= nil then
			if
				(
					not GlobalState["AntiShitlord"]
					or os.time() > GlobalState["AntiShitlord"]
					or GlobalState["BigPharmInProgress"]
				) and not GlobalState["BigPharm:Secured"]
			then
				if
					GetGameTimer() < BIGPHARM_SERVER_START_WAIT
					or (GlobalState["RestartLockdown"] and not GlobalState["BigPharmInProgress"])
				then
					Execute:Client(
						source,
						"Notification",
						"Error",
						"Network Offline For A Storm, Check Back Later",
						6000
					)
					return
				elseif
					(GlobalState["Duty:police"] or 0) < BIGPHARM_REQUIRED_POLICE
					and not GlobalState["BigPharmInProgress"]
				then
					Execute:Client(
						source,
						"Notification",
						"Error",
						"Enhanced Security Measures Enabled, Maybe Check Back Later When Things Feel Safer",
						6000
					)
					return
				elseif GlobalState["RobberiesDisabled"] then
					Execute:Client(
						source,
						"Notification",
						"Error",
						"Temporarily Disabled, Please See City Announcements",
						6000
					)
					return
				elseif
					GlobalState[string.format("BigPharm:Power:%s", data.boxId)] ~= nil
					and GlobalState[string.format("BigPharm:Power:%s", data.boxId)] > os.time()
				then
					Execute:Client(source, "Notification", "Error", "Electric Box Already Disabled", 6000)
					return
				end
				if not _bigPharmInUse.powerBoxes[data.boxId] then
					_bigPharmInUse.powerBoxes[data.boxId] = source
					GlobalState["BigPharmInProgress"] = true

					if Inventory.Items:Has(char:GetData("SID"), 1, "adv_electronics_kit", 1) then
						local slot = Inventory.Items:GetFirst(char:GetData("SID"), "adv_electronics_kit", 1)
						local itemData = Inventory.Items:GetData("adv_electronics_kit")

						if itemData ~= nil then
							Logger:Info(
								"Robbery",
								string.format(
									"%s %s (%s) Started Hacking Big Pharm Power Box %s",
									char:GetData("First"),
									char:GetData("Last"),
									char:GetData("SID"),
									data.boxId
								)
							)
							Callbacks:ClientCallback(source, "Robbery:Games:Hack", {
								config = {
									countdown = 3,
									timer = 5,
									limit = 18000,
									delay = 2000,
									difficulty = 8,
									chances = 6,
									anim = false,
								},
								data = {},
							}, function(success)
								local newValue = slot.CreateDate - (60 * 60 * 24)
								if success then
									newValue = slot.CreateDate - (60 * 60 * 12)
								end
								if os.time() - itemData.durability >= newValue then
									Inventory.Items:RemoveId(slot.Owner, slot.invType, slot)
								else
									Inventory:SetItemCreateDate(slot.id, newValue)
								end

								if success then
									Logger:Info(
										"Robbery",
										string.format(
											"%s %s (%s) Successfully Hacked Big Pharm Power Box %s",
											char:GetData("First"),
											char:GetData("Last"),
											char:GetData("SID"),
											data.boxId
										)
									)
									if
										not GlobalState["AntiShitlord"]
										or os.time() >= GlobalState["AntiShitlord"]
									then
										GlobalState["AntiShitlord"] = os.time() + (60 * math.random(10, 15))
									end

									_bigPharmGlobalReset = os.time() + BIGPHARM_RESET_TIME

									GlobalState[string.format("BigPharm:Power:%s", data.boxId)] = _bigPharmGlobalReset
									TriggerEvent("Particles:Server:DoFx", data.ptFxPoint, "spark")
									if IsBigPharmPowerDisabled() then
										Sounds.Play:Location(
											source,
											data.ptFxPoint,
											15.0,
											"power_small_complete_off.ogg",
											0.1
										)
										Robbery:TriggerPDAlert(
											source,
											vector3(-3162.2058105469, 1093.15234, 20.928604),
											"10-33",
											"Minor Power Grid Disruption",
											{
												icon = 354,
												size = 0.9,
												color = 31,
												duration = (60 * 5),
											},
											{
												icon = "bolt-slash",
												details = "Chumash Pharmacy",
											},
											false,
											50.0
										)
									else
										Sounds.Play:Location(
											source,
											data.ptFxPoint,
											15.0,
											"power_small_off.ogg",
											0.25
										)
										if not _bigPharmPowerAlerted or os.time() > _bigPharmPowerAlerted then
											Robbery:TriggerPDAlert(
												source,
												GetEntityCoords(GetPlayerPed(source)),
												"10-33",
												"Attack on Power Grid",
												{
													icon = 354,
													size = 0.9,
													color = 31,
													duration = (60 * 5),
												},
												{
													icon = "bolt-slash",
													details = "Chumash Pharmacy",
												},
												false,
												false
											)
											_bigPharmPowerAlerted = os.time() + (60 * 10)
										end
									end
								end

								_bigPharmInUse.powerBoxes[data.boxId] = false
							end, string.format("BigPharm_power_%s", data.boxId))
						else
							_bigPharmInUse.powerBoxes[data.boxId] = false
						end
					else
						_bigPharmInUse.powerBoxes[data.boxId] = false
					end
				else
					Execute:Client(
						source,
						"Notification",
						"Error",
						"Someone Is Already Interacting With This",
						6000
					)
				end

				return
			else
				_bigPharmInUse.powerBoxes[data.boxId] = false
				Execute:Client(
					source,
					"Notification",
					"Error",
					"Temporary Emergency Systems Enabled, Check Beck In A Bit",
					6000
				)
			end
		end
	end)

	Callbacks:RegisterServerCallback("Robbery:BigPharm:ElectricBox:Thermite", function(source, data, cb)
		local char = Fetch:CharacterSource(source)
		if char ~= nil then
			if
				(
					not GlobalState["AntiShitlord"]
					or os.time() > GlobalState["AntiShitlord"]
					or GlobalState["BigPharmInProgress"]
				) and not GlobalState["BigPharm:Secured"]
			then
				if
					GetGameTimer() < BIGPHARM_SERVER_START_WAIT
					or (GlobalState["RestartLockdown"] and not GlobalState["BigPharmInProgress"])
				then
					Execute:Client(
						source,
						"Notification",
						"Error",
						"You Notice The Door Is Barricaded For A Storm, Maybe Check Back Later",
						6000
					)
					return
				elseif
					(GlobalState["Duty:police"] or 0) < BIGPHARM_REQUIRED_POLICE
					and not GlobalState["BigPharmInProgress"]
				then
					Execute:Client(
						source,
						"Notification",
						"Error",
						"Enhanced Security Measures Enabled, Maybe Check Back Later When Things Feel Safer",
						6000
					)
					return
				elseif GlobalState["RobberiesDisabled"] then
					Execute:Client(
						source,
						"Notification",
						"Error",
						"Temporarily Disabled, Please See City Announcements",
						6000
					)
					return
				elseif
					GlobalState[string.format("BigPharm:Power:%s", data.boxId)] ~= nil
					and GlobalState[string.format("BigPharm:Power:%s", data.boxId)] > os.time()
				then
					Execute:Client(source, "Notification", "Error", "Electric Box Already Disabled", 6000)
					return
				end

				local myPos = GetEntityCoords(GetPlayerPed(source))

				if
					#(
						vector3(
							data.thermitePoint.coords.x,
							data.thermitePoint.coords.y,
							data.thermitePoint.coords.z
						) - myPos
					) <= 3.5
				then
					if not _bigPharmInUse.powerBoxes[data.boxId] then
						_bigPharmInUse.powerBoxes[data.boxId] = source
						GlobalState["BigPharmInProgress"] = true

						if Inventory.Items:Has(char:GetData("SID"), 1, "thermite", 1) then
							if Inventory.Items:Remove(char:GetData("SID"), 1, "thermite", 1) then
								Logger:Info(
									"Robbery",
									string.format(
										"%s %s (%s) Started Thermiting Big Pharm Power Box %s",
										char:GetData("First"),
										char:GetData("Last"),
										char:GetData("SID"),
										data.boxId
									)
								)
								Callbacks:ClientCallback(source, "Robbery:Games:Thermite", {
									passes = 1,
									location = data.thermitePoint,
									duration = 25000,
									config = {
										countdown = 3,
										preview = 1500,
										timer = 7500,
										passReduce = 500,
										base = 16,
										cols = 5,
										rows = 5,
										anim = false,
									},
									data = {},
								}, function(success)
									if success then
										Logger:Info(
											"Robbery",
											string.format(
												"%s %s (%s) Successfully Thermited Big Pharm Power Box %s",
												char:GetData("First"),
												char:GetData("Last"),
												char:GetData("SID"),
												data.boxId
											)
										)
										if
											not GlobalState["AntiShitlord"]
											or os.time() >= GlobalState["AntiShitlord"]
										then
											GlobalState["AntiShitlord"] = os.time() + (60 * math.random(10, 15))
										end

										_bigPharmGlobalReset = os.time() + BIGPHARM_RESET_TIME

										GlobalState[string.format("BigPharm:Power:%s", data.boxId)] = _bigPharmGlobalReset
										TriggerEvent("Particles:Server:DoFx", data.ptFxPoint, "spark")
										if IsBigPharmPowerDisabled() then
											Doors:SetLock("bigpharm_entryright", false)
											Sounds.Play:Location(
												source,
												data.ptFxPoint,
												15.0,
												"power_small_complete_off.ogg",
												0.1
											)

											Robbery:TriggerPDAlert(
												source,
												vector3(-3162.2058105469, 1093.15234, 20.928604),
												"10-33",
												"Minor Power Grid Disruption",
												{
													icon = 354,
													size = 0.9,
													color = 31,
													duration = (60 * 5),
												},
												{
													icon = "bolt-slash",
													details = "Chumash Pharmacy",
												},
												false,
												50.0
											)
										else
											Sounds.Play:Location(
												source,
												data.ptFxPoint,
												15.0,
												"power_small_off.ogg",
												0.25
											)
											if not _bigPharmPowerAlerted or os.time() > _bigPharmPowerAlerted then
												Robbery:TriggerPDAlert(
													source,
													GetEntityCoords(GetPlayerPed(source)),
													"10-33",
													"Attack on Power Grid",
													{
														icon = 354,
														size = 0.9,
														color = 31,
														duration = (60 * 5),
													},
													{
														icon = "bolt-slash",
														details = "Chumash Pharmacy",
													},
													false,
													false
												)
												_bigPharmPowerAlerted = os.time() + (60 * 10)
											end
										end
									end

									_bigPharmInUse.powerBoxes[data.boxId] = false
								end, string.format("BigPharm_power_%s", data.boxId))
							else
								_bigPharmInUse.powerBoxes[data.boxId] = false
							end
						else
							_bigPharmInUse.powerBoxes[data.boxId] = false
							Execute:Client(source, "Notification", "Error", "You Need Thermite", 6000)
						end
					else
						Execute:Client(
							source,
							"Notification",
							"Error",
							"Someone Is Already Interacting With This",
							6000
						)
					end

					return
				end
			else
				Execute:Client(
					source,
					"Notification",
					"Error",
					"Temporary Emergency Systems Enabled, Check Beck In A Bit",
					6000
				)
			end
		end
	end)

	Callbacks:RegisterServerCallback("Robbery:BigPharm:PC:Hack", function(source, data, cb)
		local char = Fetch:CharacterSource(source)
		if char ~= nil then
			if
				(
					not GlobalState["AntiShitlord"]
					or os.time() > GlobalState["AntiShitlord"]
					or GlobalState["BigPharmInProgress"]
				) and not GlobalState["BigPharm:Secured"]
			then
				if
					GetGameTimer() < BIGPHARM_SERVER_START_WAIT
					or (GlobalState["RestartLockdown"] and not GlobalState["BigPharmInProgress"])
				then
					Execute:Client(
						source,
						"Notification",
						"Error",
						"Network Offline For A Storm, Check Back Later",
						6000
					)
					return
				elseif
					(GlobalState["Duty:police"] or 0) < BIGPHARM_REQUIRED_POLICE
					and not GlobalState["BigPharmInProgress"]
				then
					Execute:Client(
						source,
						"Notification",
						"Error",
						"Enhanced Security Measures Enabled, Maybe Check Back Later When Things Feel Safer",
						6000
					)
					return
				elseif GlobalState["RobberiesDisabled"] then
					Execute:Client(
						source,
						"Notification",
						"Error",
						"Temporarily Disabled, Please See City Announcements",
						6000
					)
					return
				end

				if _bigPharmInUse.pharmPcs.looted then
					Execute:Client(source, "Notification", "Error", "Someone Already Looted This", 6000)
					return
				else
					_bigPharmInUse.pharmPcs.looted = true
				end

				if not _bigPharmInUse.pharmPcs[data.id] then
					_bigPharmInUse.pharmPcs[data.id] = source
					GlobalState["BigPharmInProgress"] = true

					if Inventory.Items:Has(char:GetData("SID"), 1, "adv_electronics_kit", 1) then
						local slot = Inventory.Items:GetFirst(char:GetData("SID"), "adv_electronics_kit", 1)
						local itemData = Inventory.Items:GetData("adv_electronics_kit")

						if itemData ~= nil then
							Logger:Info(
								"Robbery",
								string.format(
									"%s %s (%s) Started Hacking Big Pharm PC %s",
									char:GetData("First"),
									char:GetData("Last"),
									char:GetData("SID"),
									data.id
								)
							)
							Callbacks:ClientCallback(source, "Robbery:Games:Progress", {
								config = {
									label = "Doing Hackermans Stuff",
									anim = {
										anim = "type",
									},
								},
								data = {},
							}, function(success)
								if success then
									newValue = slot.CreateDate - (60 * 60 * 12)
									if os.time() - itemData.durability >= newValue then
										Inventory.Items:RemoveId(slot.Owner, slot.invType, slot)
									else
										Inventory:SetItemCreateDate(slot.id, newValue)
									end

									Logger:Info(
										"Robbery",
										string.format(
											"%s %s (%s) Successfully Hacked Big Pharm PC %s",
											char:GetData("First"),
											char:GetData("Last"),
											char:GetData("SID"),
											data.id
										)
									)
									if
										not GlobalState["AntiShitlord"]
										or os.time() >= GlobalState["AntiShitlord"]
									then
										GlobalState["AntiShitlord"] = os.time() + (60 * math.random(10, 15))
									end

									_bigPharmGlobalReset = os.time() + BIGPHARM_RESET_TIME

									GlobalState[string.format("BigPharm:Offices:PC:%s", data.id)] = _bigPharmGlobalReset
									Inventory:AddItem(char:GetData("SID"), "crypto_voucher", 1, {
										CryptoCoin = "MALD",
										Quantity = math.random(120, 200),
									}, 1)

									cb(true)
								end

								_bigPharmInUse.pharmPcs[data.id] = false
							end, string.format("BigPharm_pc_%s", data.id))
						else
							_bigPharmInUse.pharmPcs[data.id] = false

							cb(false)
						end
					else
						_bigPharmInUse.pharmPcs[data.id] = false

						cb(false)
					end
				else
					Execute:Client(
						source,
						"Notification",
						"Error",
						"Someone Is Already Interacting With This",
						6000
					)

					cb(false)
				end

				return
			else
				Execute:Client(
					source,
					"Notification",
					"Error",
					"Temporary Emergency Systems Enabled, Check Beck In A Bit",
					6000
				)

				cb(false)
			end
		end
	end)

	Callbacks:RegisterServerCallback("Robbery:BigPharm:FuckWithLoot", function(source, data, cb)
		local source = source
		local char = Fetch:CharacterSource(source)
		local playerSID = char:GetData("SID")
		local bigPharmaRep = Reputation:GetLevel(source, "BigPharma") or 0
		
		if char ~= nil then
			if (not GlobalState["AntiShitlord"] or os.time() > GlobalState["AntiShitlord"] or GlobalState["BigPharmInProgress"]) 
				and not GlobalState["BigPharm:Secured"] then
	
				if GetGameTimer() < BIGPHARM_SERVER_START_WAIT or (GlobalState["RestartLockdown"] and not GlobalState["BigPharmInProgress"]) then
					Execute:Client(source, "Notification", "Error", "Network Offline For A Storm, Check Back Later", 6000)
					return
				elseif (GlobalState["Duty:police"] or 0) < BIGPHARM_REQUIRED_POLICE and not GlobalState["BigPharmInProgress"] then
					Execute:Client(source, "Notification", "Error", "Enhanced Security Measures Enabled, Maybe Check Back Later When Things Feel Safer", 6000)
					return
				elseif GlobalState["RobberiesDisabled"] then
					Execute:Client(source, "Notification", "Error", "Temporarily Disabled, Please See City Announcements", 6000)
					return
				end
	
				if IsBigPharmPowerDisabled() then
					local lootIndex = data.id
					if _bigPharmLoot[lootIndex][2].looted then
						Execute:Client(source, "Notification", "Error", "Someone Already Looted This", 6000)
						return
					end
					
					if not _bigPharmInUse.bigpharm_lootboi then
						_bigPharmInUse.bigpharm_lootboi = source
						GlobalState["BigPharmInProgress"] = true
						_bigPharmLoot[lootIndex][2].looted = true
						local multiplier = 1 + (bigPharmaRep * 0.1)
	
						if data.id == 1 then
							for _, loot in ipairs(_bigPharmLoot) do
								local lootData = loot[2]
								local lootName = lootData.name
								local lootAmt = math.floor(math.random(lootData.min, lootData.max) * multiplier)
								Inventory:AddItem(playerSID, lootName, lootAmt, {}, 1)
								Reputation.Modify:Add(source, "BigPharma", 250)
							end
							Logger:Info("Robbery", string.format("%s %s (%s) Looted Big Pharm", char:GetData("First"), char:GetData("Last"), char:GetData("SID")))
						elseif data.id == 2 then
							local firstaidItem = _bigPharmLoot[1][2]
							local lootAmt = math.floor(math.random(firstaidItem.min, firstaidItem.max) * multiplier)
							Inventory:AddItem(char:GetData("SID"), firstaidItem.name, lootAmt, {}, 1)
							Reputation.Modify:Add(source, "BigPharma", 250)
						end
	
						_bigPharmInUse.bigpharm_lootboi = false
					else
						Execute:Client(source, "Notification", "Error", "Someone Is Already Interacting With This", 6000)
					end
				else
					Execute:Client(source, "Notification", "Error", "Damn your brain cells are fried", 6000)
				end
			else
				Execute:Client(source, "Notification", "Error", "Temporary Emergency Systems Enabled, Check Back In A Bit", 6000)
			end
		end
	end)	

	Callbacks:RegisterServerCallback("Robbery:BigPharm:LootShelf", function(source, data, cb)
		local source = source
		local char = Fetch:CharacterSource(source)
		local playerSID = char:GetData("SID")
		if char ~= nil then
			if (not GlobalState["AntiShitlord"] or os.time() > GlobalState["AntiShitlord"] or GlobalState["BigPharmInProgress"]) 
				and not GlobalState["BigPharm:Secured"] then

				if GetGameTimer() < BIGPHARM_SERVER_START_WAIT or (GlobalState["RestartLockdown"] and not GlobalState["BigPharmInProgress"]) then
					Execute:Client(source, "Notification", "Error", "Network Offline For A Storm, Check Back Later", 6000)
					return
				elseif (GlobalState["Duty:police"] or 0) < BIGPHARM_REQUIRED_POLICE and not GlobalState["BigPharmInProgress"] then
					Execute:Client(source, "Notification", "Error", "Enhanced Security Measures Enabled, Maybe Check Back Later When Things Feel Safer", 6000)
					return
				elseif GlobalState["RobberiesDisabled"] then
					Execute:Client(source, "Notification", "Error", "Temporarily Disabled, Please See City Announcements", 6000)
					return
				end

				if IsBigPharmPowerDisabled() then
					local lootIndex = data.id
					if _bigPharmShelfLoot[lootIndex][2].looted then
						Execute:Client(source, "Notification", "Error", "Someone Already Looted This", 6000)
						return
					end
					
					GlobalState["BigPharmInProgress"] = true
					_bigPharmShelfLoot[lootIndex][2].looted = true
					local lootData = _bigPharmShelfLoot[lootIndex][2]
					local lootName = lootData.name
					local lootAmt = math.random(lootData.min, lootData.max)
					Inventory:AddItem(playerSID, lootName, lootAmt, {}, 1)
				else
					Execute:Client(source, "Notification", "Error", "Damn your brain cells are fried", 6000)
				end
			else
				Execute:Client(source, "Notification", "Error", "Temporary Emergency Systems Enabled, Check Back In A Bit", 6000)
			end
		end
	end)
end)
