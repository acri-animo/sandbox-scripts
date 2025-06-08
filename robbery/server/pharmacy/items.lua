function RegisterBigPharmItemUses()
	Inventory.Items:RegisterUse("thermite", "BigPharmRobbery", function(source, itemData)
		local char = Fetch:CharacterSource(source)
		local pState = Player(source).state

		if pState.inBigPharm then
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
				end

				local myPos = GetEntityCoords(GetPlayerPed(source))

				for k, v in pairs(_bigPharmDoors) do
					if Doors:IsLocked(v.door) and #(v.coords - myPos) <= 1.5 then
						if AreRequirementsUnlocked(v.requiredDoors) then
							if not _bigPharmInUse[k] then
								_bigPharmInUse[k] = source
								GlobalState["BigPharmInProgress"] = true

								if
									Inventory.Items:RemoveSlot(
										itemData.Owner,
										itemData.Name,
										1,
										itemData.Slot,
										itemData.invType
									)
								then
									Logger:Info(
										"Robbery",
										string.format(
											"%s %s (%s) Started Thermiting Big Pharm Door: %s",
											char:GetData("First"),
											char:GetData("Last"),
											char:GetData("SID"),
											v.door
										)
									)
									Callbacks:ClientCallback(source, "Robbery:Games:Thermite", {
										passes = 1,
										location = v,
										duration = 11000,
										config = {
											countdown = 3,
											preview = 1500,
											timer = 15000,
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
													"%s %s (%s) Successfully Thermited Big Pharm Door: %s",
													char:GetData("First"),
													char:GetData("Last"),
													char:GetData("SID"),
													v.door
												)
											)
											if
												not GlobalState["AntiShitlord"]
												or os.time() >= GlobalState["AntiShitlord"]
											then
												GlobalState["AntiShitlord"] = os.time() + (60 * math.random(10, 15))
											end

											_bigPharmGlobalReset = os.time() + BIGPHARM_RESET_TIME
											Doors:SetLock(v.door, false)
											if not _bigPharmAlerted or os.time() > _bigPharmAlerted then
												Robbery:TriggerPDAlert(
													source,
													vector3(-1332.651, -846.451, 17.080),
													"10-90",
													"Armed Robbery",
													{
														icon = 586,
														size = 0.9,
														color = 31,
														duration = (60 * 5),
													},
													{
														icon = "pill",
														details = "Chumash Pharmacy",
													},
													"BigPharm"
												)
												_bigPharmAlerted = os.time() + (60 * 10)
												Status.Modify:Add(source, "PLAYER_STRESS", 3)
											end
										else
											_bigPharmGlobalReset = os.time() + BIGPHARM_RESET_TIME
											Status.Modify:Add(source, "PLAYER_STRESS", 6)
										end

										_bigPharmInUse[k] = false
									end, v.door)
									break
								else
									_bigPharmInUse[k] = false
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
						end
					end
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

	Inventory.Items:RegisterUse("white_laptop", "BigPharmRobbery", function(source, slot, itemData)
		local char = Fetch:CharacterSource(source)
		local pState = Player(source).state
	
		if pState.inBigPharm then
			local ped = GetPlayerPed(source)
			local myCoords = GetEntityCoords(ped)
	
			if
				(not GlobalState["AntiShitlord"] or os.time() > GlobalState["AntiShitlord"] or GlobalState["BigPharmInProgress"])
				and not GlobalState["BigPharm:Secured"]
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
				end
	
				local hack = _bigPharmHacks[1]
				local hackCoords = hack.coords
				local hackHeading = hack.heading
				local doorId = hack.doorId
				local hackConfig = hack.config
				local requiredLaptopDoors = hack.requiredDoors
	
				if #(hackCoords - myCoords) <= 1.5 then
					if
						GlobalState[string.format("BigPharm:ManualDoor:%s", doorId)] == nil
						or GlobalState[string.format("BigPharm:ManualDoor:%s", doorId)].state == 4
							and os.time() > GlobalState[string.format("BigPharm:ManualDoor:%s", doorId)].expires
					then
						if AreRequirementsUnlocked(requiredLaptopDoors) then
							if not _bigPharmInUse[doorId] then
								_bigPharmInUse[doorId] = source
								Logger:Info(
									"Robbery",
									string.format(
										"%s %s (%s) Started Hacking Big Pharm Door: %s",
										char:GetData("First"),
										char:GetData("Last"),
										char:GetData("SID"),
										doorId
									)
								)
								Callbacks:ClientCallback(source, "Robbery:Games:Laptop", {
									location = {
										coords = hackCoords,
										heading = hackHeading,
									},
									config = hackConfig,
									data = {},
								}, function(success, data)
									if success then
										Logger:Info(
											"Robbery",
											string.format(
												"%s %s (%s) Successfully Hacked Big Pharm Door: %s",
												char:GetData("First"),
												char:GetData("Last"),
												char:GetData("SID"),
												doorId
											)
										)
	
										local timer = math.random(2, 4)
	
										Execute:Client(source, "Notification", "Success", "You successfully hacked through security protocls.", 6000)
	
										Inventory.Items:RemoveSlot(slot.Owner, slot.Name, 1, slot.Slot, 1)
										_bigPharmGlobalReset = os.time() + BIGPHARM_RESET_TIME
										Doors:SetLock("bigpharm_lootboi", false)
										Status.Modify:Add(source, "PLAYER_STRESS", 3)
									else
										Logger:Info(
											"Robbery",
											string.format(
												"%s %s (%s) Failed Hacking Big Pharm Door: %s",
												char:GetData("First"),
												char:GetData("Last"),
												char:GetData("SID"),
												doorId
											)
										)
	
										local newValue = slot.CreateDate - (60 * 60 * 24)
										if os.time() - itemData.durability >= newValue then
											Inventory.Items:RemoveId(slot.Owner, slot.invType, slot)
										else
											Inventory:SetItemCreateDate(slot.id, newValue)
										end
	
										_bigPharmGlobalReset = os.time() + BIGPHARM_RESET_TIME
										Status.Modify:Add(source, "PLAYER_STRESS", 6)
									end
									_bigPharmInUse[doorId] = false
								end)
							else
								Execute:Client(source, "Notification", "Error", "Someone Else Is Already Doing A Thing", 6000)
							end
						end
					end
				end
			else
				Execute:Client(source, "Notification", "Error", "Temporary Emergency Systems Enabled, Check Beck In A Bit", 6000)
			end
		end
	end)	
end
