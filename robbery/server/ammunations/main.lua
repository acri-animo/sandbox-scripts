_ammuInUse = {
    ammunation1_front_left = false,
    ammunation1_backentrance = false,
    ammunation1_lockerroom = false,
	ammunation1_office1 = false,
	ammunation1_office2 = false,
    ammunation1_mainloot = false,
    ammuPc = false,
    ammuPowerBox = false,
    drillPoints = {},
    ammuLootShelves = {},
}

_ammuGlobalReset = nil
_ammuAlerted = false
_ammuPowerAlerted = false

local _ammuLootMain = {
    { 60, { name = "WEAPON_38SPECIAL", min = 1, max = 2 } },
    { 33, { name = "WEAPON_FNX", min = 1, max = 2 } },
    { 5, { name = "ATTCH_PISTOL_SILENCER", min = 1, max = 1 } },
    { 2, { name = "ATTCH_PISTOL_EXT_MAG", min = 1, max = 1 } },
}

local _ammuLockerLoot = {
    { 60, { name = "armor", min = 3, max = 6 } },
    { 33, { name = "heavyarmor", min = 1, max = 2 } },
    { 5, { name = "ATTCH_PISTOL_SILENCER", min = 1, max = 1 } },
    { 2, { name = "ATTCH_PISTOL_EXT_MAG", min = 1, max = 1 } },
}

function AmmuClearSourceInUse(source)
    for k, v in pairs(_ammuInUse) do
        if v == source then
            _ammuInUse[k] = nil
        elseif type(v) == "table" then
            for k2, v2 in pairs(v) do
                if v2 == source then
                    _ammuInUse[k][k2] = nil
                end
            end
        end
    end
end

function ResetAmmunation()
    _ammuGlobalReset = nil
    _ammuInUse.ammuPc = false

    for k, v in ipairs(_ammuDrillPoints) do
        GlobalState[string.format("Ammunation:Drill:%s", v.data.wallId)] = nil
    end

    for k, v in ipairs(_ammuDoors) do
        Doors:SetLock(v.door, true)
    end

    Doors:SetLock("ammu_loot_door", true)

    _ammuAlerted = false
    _ammuPowerAlerted = false

    GlobalState["AmmunationInProgress"] = false
    GlobalState["Ammunation:Secured"] = false
end

function SecureAmmunation()
    _ammuGlobalReset = os.time() + AMMUNATION_RESET_TIME

    for k, v in ipairs(_ammuDrillPoints) do
        GlobalState[string.format("Ammunation:Drill:%s", v.data.wallId)] = nil
    end

    for k, v in ipairs(_ammuDoors) do
        Doors:SetLock(v.door, true)
    end

    Doors:SetLock("ammu_loot_door", true)

    GlobalState["AmmunationInProgress"] = false
    GlobalState["Ammunation:Secured"] = _ammuGlobalReset
end

AddEventHandler("Characters:Server:PlayerLoggedOut", AmmuClearSourceInUse)
AddEventHandler("Characters:Server:PlayerDropped", AmmuClearSourceInUse)

AddEventHandler("Robbery:Server:Setup", function()
    StartAmmunationThreads()
    RegisterAmmuItemUses()

    Chat:RegisterAdminCommand("resetammu", function(source, args, rawCommand)
        ResetAmmunation()
    end, {
        help = "Force Reset Ammunation Robbery"
    }, 0)

    Callbacks:RegisterServerCallback("Robbery:Ammunation:SecureAmmu", function(source, data, cb)
        local char = Fetch:CharacterSource(source)

        if char ~= nil then
            if Player(source).state.onDuty == "police" then
                SecureAmmunation()
            end
        end
    end)

    Callbacks:RegisterServerCallback("Robbery:Ammunation:ElectricBox:Hack", function(source, data, cb)
        local char = Fetch:CharacterSource(source)
		if char ~= nil then
			if
				(
					not GlobalState["AntiShitlord"]
					or os.time() > GlobalState["AntiShitlord"]
					or GlobalState["AmmunationInProgress"]
				) and not GlobalState["Ammunation:Secured"]
			then
				if
					GetGameTimer() < AMMUNATION_SERVER_START_WAIT
					or (GlobalState["RestartLockdown"] and not GlobalState["AmmunationInProgress"])
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
					(GlobalState["Duty:police"] or 0) < AMMUNATION_REQUIRED_POLICE
					and not GlobalState["AmmunationInProgress"]
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
					GlobalState[string.format("Ammunation:Power:%s", data.boxId)] ~= nil
					and GlobalState[string.format("Ammunation:Power:%s", data.boxId)] > os.time()
				then
					Execute:Client(source, "Notification", "Error", "Electric Box Already Disabled", 6000)
					return
				end
				if not _ammuInUse.ammuPowerBox then
                    _ammuInUse.ammuPowerBox = source
					GlobalState["AmmunationInProgress"] = true

					if Inventory.Items:Has(char:GetData("SID"), 1, "adv_electronics_kit", 1) then
						local slot = Inventory.Items:GetFirst(char:GetData("SID"), "adv_electronics_kit", 1)
						local itemData = Inventory.Items:GetData("adv_electronics_kit")

						if itemData ~= nil then
							Logger:Info(
								"Robbery",
								string.format(
									"%s %s (%s) Started Hacking Ammunation Power Box %s",
									char:GetData("First"),
									char:GetData("Last"),
									char:GetData("SID"),
									data.boxId
								)
							)
							Callbacks:ClientCallback(source, "Robbery:Games:Hack", {}, function(success)
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
											"%s %s (%s) Successfully Hacked Ammunation Power Box %s",
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

									_ammuGlobalReset = os.time() + AMMUNATION_RESET_TIME

									GlobalState[string.format("Ammunation:Power:%s", data.boxId)] = _ammuGlobalReset
									TriggerEvent("Particles:Server:DoFx", data.ptFxPoint, "spark")
                                    StartPedSpawnThread()
									if IsAmmuPowerDisabled() then
										Doors:SetLock("ammunation1_front_left", true)
										Sounds.Play:Location(
											source,
											data.ptFxPoint,
											15.0,
											"power_small_complete_off.ogg",
											0.1
										)
										Robbery:TriggerPDAlert(
											source,
											vector3(-1332.651, -846.451, 17.080),
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
												details = "Industrial Area",
											},
											false,
											50.0
										)
									else
										Doors:SetLock("ammunation1_front_left", true)
										Sounds.Play:Location(
											source,
											data.ptFxPoint,
											15.0,
											"power_small_off.ogg",
											0.25
										)
										if not _ammuPowerAlerted or os.time() > _ammuPowerAlerted then
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
													details = "Industrial Area",
												},
												false,
												false
											)
											_ammuPowerAlerted = os.time() + (60 * 10)
										end
									end
								end

								_ammuInUse.ammuPowerBox = false
							end, string.format("ammunation_power_%s", data.boxId))
						else
							_ammuInUse.ammuPowerBox = false
						end
					else
						_ammuInUse.ammuPowerBox = false
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
				_ammuInUse.ammuPowerBox = false
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

    Callbacks:RegisterServerCallback("Robbery:Ammunation:Drill", function(source, data, cb)
        local char = Fetch:CharacterSource(source)

       if char ~= nil then
			if
				(
					not GlobalState["AntiShitlord"]
					or os.time() > GlobalState["AntiShitlord"]
					or GlobalState["AmmunationInProgress"]
				) and not GlobalState["Ammunation:Secured"]
			then
				if
					GetGameTimer() < AMMUNATION_SERVER_START_WAIT
					or (GlobalState["RestartLockdown"] and not GlobalState["AmmunationInProgress"])
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
					(GlobalState["Duty:police"] or 0) < AMMUNATION_REQUIRED_POLICE
					and not GlobalState["AmmunationInProgress"]
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
					GlobalState[string.format("Ammunation:Vault:Wall:%s", data)] ~= nil
					and GlobalState[string.format("Ammunation:Vault:Wall:%s", data)] > os.time()
				then
					Execute:Client(source, "Notification", "Error", "Electric Box Already Disabled", 6000)
					return
				end
				if not _ammuInUse.drillPoints[data] then
					_ammuInUse.drillPoints[data] = source
					GlobalState["AmmunationInProgress"] = true

					if Inventory.Items:Has(char:GetData("SID"), 1, "drill", 1) then
						local slot = Inventory.Items:GetFirst(char:GetData("SID"), "drill", 1)
						local itemData = Inventory.Items:GetData("drill")

						if slot ~= nil then
							Logger:Info(
								"Robbery",
								string.format(
									"%s %s (%s) Started Drilling Ammunation Vault Box: %s",
									char:GetData("First"),
									char:GetData("Last"),
									char:GetData("SID"),
									data
								)
							)
							Callbacks:ClientCallback(source, "Robbery:Games:Drill", {
								passes = 1,
								duration = 25000,
								config = {},
								data = {},
							}, function(success)
								local newValue = slot.CreateDate - itemData.durability
								if success then
									newValue = slot.CreateDate - (itemData.durability / 2)
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
											"%s %s (%s) Successfully Drilled Ammunation Vault Box: %s",
											char:GetData("First"),
											char:GetData("Last"),
											char:GetData("SID"),
											data
										)
									)
									if
										not GlobalState["AntiShitlord"]
										or os.time() >= GlobalState["AntiShitlord"]
									then
										GlobalState["AntiShitlord"] = os.time() + (60 * math.random(10, 15))
									end

									_ammuGlobalReset = os.time() + AMMUNATION_RESET_TIME

									Loot:CustomWeightedSetWithCount(_ammuLockerLoot, char:GetData("SID"), 1)

									GlobalState[string.format("Ammunation:Vault:Wall:%s", data)] = _ammuGlobalReset
								end

								_ammuInUse.drillPoints[data] = false
							end, string.format("ammunation_drill_%s", data))
						else
							_ammuInUse.drillPoints[data] = false
						end
					else
						_ammuInUse.drillPoints[data] = false
						Execute:Client(source, "Notification", "Error", "You Need A Drill", 6000)
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

    Callbacks:RegisterServerCallback("Robbery:Ammunation:LootMain", function(source, data, cb)
        local char = Fetch:CharacterSource(source)

        if char ~= nil then
            if
                (
                    not GlobalState["AntiShitlord"]
                    or os.time() > GlobalState["AntiShitlord"]
                    or GlobalState["AmmunationInProgress"]
                ) and not GlobalState["Ammunation:Secured"]
            then
                if
                    GetGameTimer() < AMMUNATION_SERVER_START_WAIT
                    or (GlobalState["RestartLockdown"] and not GlobalState["AmmunationInProgress"])
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
                    (GlobalState["Duty:police"] or 0) < AMMUNATION_REQUIRED_POLICE
                    and not GlobalState["AmmunationInProgress"]
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

                if not _ammuInUse.ammuLootShelves[data] then
                    _ammuInUse.ammuLootShelves[data] = source

                    Callbacks:ClientCallback(source, "Robbery:Client:Ammunation:LootProg", {}, function(success)
                        if success then
                            Logger:Info(
                                "Robbery",
                                string.format(
                                    "%s %s (%s) Looted Ammunation Main Loot Box: %s",
                                    char:GetData("First"),
                                    char:GetData("Last"),
                                    char:GetData("SID"),
                                    data
                                )
                            )

                            if
                                not GlobalState["AntiShitlord"]
                                or os.time() >= GlobalState["AntiShitlord"]
                            then
                                GlobalState["AntiShitlord"] = os.time() + (60 * math.random(10, 15))
                            end

                            _ammuGlobalReset = os.time() + AMMUNATION_RESET_TIME

                            Loot:CustomWeightedSetWithCount(_ammuLootMain, char:GetData("SID"), 1)

                            GlobalState[string.format("Ammunation:Loot:%s", data)] = _ammuGlobalReset
                        end

                        _ammuInUse.ammuLootShelves[data] = false
                    end, string.format("ammunation_loot_%s", data)) 
                else
                    Execute:Client(
                        source,
                        "Notification",
                        "Error",
                        "Someone Is Already Interacting With This",
                        6000
                    )
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

	Callbacks:RegisterServerCallback("Robbery:Ammunation:PcHack", function(source, data, cb)
		local char = Fetch:CharacterSource(source)
		if char ~= nil then
			if
				(
					not GlobalState["AntiShitlord"]
					or os.time() > GlobalState["AntiShitlord"]
					or GlobalState["AmmunationInProgress"]
				) and not GlobalState["Ammunation:Secured"]
			then
				if
					GetGameTimer() < AMMUNATION_SERVER_START_WAIT
					or (GlobalState["RestartLockdown"] and not GlobalState["AmmunationInProgress"])
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
					(GlobalState["Duty:police"] or 0) < AMMUNATION_REQUIRED_POLICE
					and not GlobalState["AmmunationInProgress"]
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

				if not _ammuInUse.ammuPc then
					_ammuInUse.ammuPc = source
					GlobalState["AmmunationInProgress"] = true

					if Inventory.Items:Has(char:GetData("SID"), 1, "adv_electronics_kit", 1) then
						local slot = Inventory.Items:GetFirst(char:GetData("SID"), "adv_electronics_kit", 1)
						local itemData = Inventory.Items:GetData("adv_electronics_kit")

						if itemData ~= nil then
							Logger:Info(
								"Robbery",
								string.format(
									"%s %s (%s) Started Hacking Ammunation PC",
									char:GetData("First"),
									char:GetData("Last"),
									char:GetData("SID")
								)
							)

							Callbacks:ClientCallback(source, "Robbery:Games:CircleSum", {}, function(success)
								if success then
									local newValue = slot.CreateDate - (60 * 60 * 12)
									if os.time() - itemData.durability >= newValue then
										Inventory.Items:RemoveId(slot.Owner, slot.invType, slot)
									else
										Inventory:SetItemCreateDate(slot.id, newValue)
									end

									Logger:Info(
										"Robbery",
										string.format(
											"%s %s (%s) Successfully Hacked Ammunation PC",
											char:GetData("First"),
											char:GetData("Last"),
											char:GetData("SID")
										)
									)

									if
										not GlobalState["AntiShitlord"]
										or os.time() >= GlobalState["AntiShitlord"]
									then
										GlobalState["AntiShitlord"] = os.time() + (60 * math.random(10, 15))
									end

									_ammuGlobalReset = os.time() + AMMUNATION_RESET_TIME
									GlobalState[string.format("Ammunation:PC:%s", data)] = _ammuGlobalReset

									Inventory:AddItem(char:GetData("SID"), "crypto_voucher", 1, {
										CryptoCoin = "HEIST",
										Quantity = math.random(1, 3),
									}, 1)

									_ammuInUse.ammuPc = false
								else
									_ammuInUse.ammuPc = false
								end
							end, string.format("ammunation_pc_%s", data))
						else
							_ammuInUse.ammuPc = false
						end
					else
						_ammuInUse.ammuPc = false
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
end)

function AreRequirementsUnlocked(reqs)
	for k, v in ipairs(reqs or {}) do
		if Doors:IsLocked(v) then
			return false
		end
	end
	return true
end

function IsAmmuPowerDisabled()
    local box = 1
    if
        not GlobalState[string.format("Ammunation:Power:%s", box)]
        or os.time() > GlobalState[string.format("Ammunation:Power:%s", box)]
    then
        return false
    end
    return true
end

function StartPedSpawnThread()
    Citizen.CreateThread(function()
        while true do
            if not Doors:IsLocked("ammunation1_front_left") then
                TriggerClientEvent("Robbery:Client:Ammunation:SpawnPeds", -1)
                return
            end
            Citizen.Wait(1000)
        end
    end)
end