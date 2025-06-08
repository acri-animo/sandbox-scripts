function RegisterAmmuItemUses()
    Inventory.Items:RegisterUse("thermite", "AmmunationRobbery1", function(source, itemData)
        local char = Fetch:CharacterSource(source)
        local pState = Player(source).state
    
        if pState.inAmmunation then
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
				end

                local myPos = GetEntityCoords(GetPlayerPed(source))

                for k, v in pairs(_ammuDoors) do
                    if Doors:IsLocked(v.door) and #(v.coords - myPos) <= 1.5 then
                        if AreRequirementsUnlocked(v.requiredDoors) then
                            if not _ammuInUse[k] then
                                _ammuInUse[k] = source
                                GlobalState["AmmunationInProgress"] = true

                                if Inventory.Items:RemoveSlot(itemData.Owner, itemData.Name, 1, itemData.Slot, itemData.invType) then
                                    Logger:Info(
                                        string.format(
                                            "%s %s (%s) Started Thermiting Ammunation Door: %s",
                                            char:GetData("First"),
                                            char:GetData("Last"),
                                            char:GetData("SID"),
                                            v.door
                                        )
                                    )

                                    Callbacks:ClientCallback(source, "Robbery:Games:Thermite", { location = v, duration = 7000 }, function(success)
                                        if success then
                                            Logger:Info(
                                                string.format(
                                                    "%s %s (%s) Thermited Ammunation Door: %s",
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

                                            _ammuGlobalReset = os.time() + AMMUNATION_RESET_TIME

                                            Doors:SetLock(v.door, false)

                                            if not _ammuAlerted or os.time() > _ammuAlerted then
                                                Robbery:TriggerPDAlert(
                                                    source,
                                                    vector3(811.586, -2147.598, 29.508),
                                                    "10-90",
                                                    "Ammunation Robbery",
                                                    {
                                                        icon = 586,
                                                        size = 0.9,
                                                        color = 31,
                                                        duration = (60 * 5),
                                                    },
                                                    {
                                                        icon = "gun",
                                                        details = "Ammunation Robbery",
                                                    },
                                                    "ammunation"
                                                )

                                                _ammuAlerted = os.time() + (60 * 10)
                                                Status.Modify:Add(source, "PLAYER_STRESS", 3)
                                            end
                                        else
                                            _ammuGlobalReset = os.time() + AMMUNATION_RESET_TIME
                                            Status.Modify:Add(source, "PLAYER_STRESS", 6)
                                        end

                                        _ammuInUse[k] = false
                                    end, v.door)
                                    break
                                else
                                    _ammuInUse[k] = false
                                end
                            else
                                Execute:Client(
                                    source,
                                    "Notification",
                                    "Error",
                                    "Someone Else Is Already Using This Door",
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

    Inventory.Items:RegisterUse("ammu_card", "AmmunationRobbery1", function(source, slot, itemData)
        local char = Fetch:CharacterSource(source)
        local pState = Player(source).state

        if pState.inAmmunation then
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
				end

                local myPos = GetEntityCoords(GetPlayerPed(source))

                if Doors:IsLocked(_ammuCardDoor.door) and #(_ammuCardDoor.coords - myPos) <= 1.5 then
                    if AreRequirementsUnlocked(_ammuCardDoor.requiredDoors) then
                        if not _ammuInUse["ammunation1_backentrance"] then
                            _ammuInUse["ammunation1_backentrance"] = source
                            
                            Logger:Info(
                                string.format(
                                    "%s %s (%s) Started Using Ammunation Card: %s",
                                    char:GetData("First"),
                                    char:GetData("Last"),
                                    char:GetData("SID"),
                                    _ammuCardDoor.door
                                )
                            )

                            Callbacks:ClientCallback(source, "Robbery:Games:Laptop", {
                                location = {
                                    coords = _ammuCardDoor.coords,
                                    heading = _ammuCardDoor.heading,
                                },
                                duration = 7000,
                                robbery = "ammunation",
                            }, function(success, data)
                                if success then
                                    Logger:Info(
                                        string.format(
                                            "%s %s (%s) Used Ammunation Card: %s",
                                            char:GetData("First"),
                                            char:GetData("Last"),
                                            char:GetData("SID"),
                                            _ammuCardDoor.door
                                        )
                                    )

                                    Inventory.Items:RemoveSlot(slot.Owner, slot.Name, 1, slot.Slot, 1)
                                    _ammuGlobalReset = os.time() + AMMUNATION_RESET_TIME

                                    Citizen.SetTimeout(math.random(7000, 10000), function()
                                        Sounds.Play:Location(
                                            source,
                                            _ammuCardDoor.coords,
                                            30.0,
                                            "alarm.ogg",
                                            0.1
                                        )

                                        Doors:SetLock(_ammuCardDoor.door, false)
                                        Status.Modify:Add(source, "PLAYER_STRESS", 3)
                                    end)
                                else
                                    Logger:Info(
                                        string.format(
                                            "%s %s (%s) Failed Using Ammunation Card: %s",
                                            char:GetData("First"),
                                            char:GetData("Last"),
                                            char:GetData("SID"),
                                            _ammuCardDoor.door
                                        )
                                    )

                                    local newValue = slot.CreateDate - (60 * 60 * 24)

                                    if os.time() - itemData.durability >= newValue then
                                        Inventory.Items:RemoveId(slot.Owner, slot.invType, slot)
                                    else
                                        Inventory:SetItemCreateDate(slot.id, newValue)
                                    end

                                    _ammuGlobalReset = os.time() + AMMUNATION_RESET_TIME
                                    Status.Modify:Add(source, "PLAYER_STRESS", 6)
                                end
                                _ammuInUse["ammunation1_backentrance"] = false
                            end)
                        else
                            Execute:Client(
                                source,
                                "Notification",
                                "Error",
                                "Someone Else Is Already Using This Door",
                                6000
                            )
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

    Inventory.Items:RegisterUse("adv_lockpick", "AmmunationRobbery1", function(source, slot, itemData)
        local char = Fetch:CharacterSource(source)
        local pState = Player(source).state

        if pState.inAmmunation then
            local ped = GetPlayerPed(source)
            local myCoords = GetEntityCoords(ped)

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
				end

                for k, v in ipairs(_ammuOfficeDoors) do
                    if #(v.coords - myCoords) <= 1.5 then
                        if AreRequirementsUnlocked(v.requiredDoors) then
                            if not _ammuInUse[v.door] then
                                _ammuInUse[v.door] = source
                                Logger:Info(
                                    string.format(
                                        "%s %s (%s) Started Lockpicking Ammunation Door: %s",
                                        char:GetData("First"),
                                        char:GetData("Last"),
                                        char:GetData("SID"),
                                        v.door
                                    )
                                )

                                Callbacks:ClientCallback(source, "Robbery:Games:Lockpick", {}, function(success)
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
                                            string.format(
                                                "%s %s (%s) Lockpicked Ammunation Door: %s",
                                                char:GetData("First"),
                                                char:GetData("Last"),
                                                char:GetData("SID"),
                                                v.door
                                            )
                                        )

                                        _ammuGlobalReset = os.time() + AMMUNATION_RESET_TIME
                                        Doors:SetLock(v.door, false)
                                        Status.Modify:Add(source, "PLAYER_STRESS", 3)
                                    else
                                        Logger:Info(
                                            string.format(
                                                "%s %s (%s) Failed Lockpicking Ammunation Door: %s",
                                                char:GetData("First"),
                                                char:GetData("Last"),
                                                char:GetData("SID"),
                                                v.door
                                            )
                                        )

                                        _ammuGlobalReset = os.time() + AMMUNATION_RESET_TIME
                                        Doors:SetLock(v.door, true)
                                        Status.Modify:Add(source, "PLAYER_STRESS", 6)

                                        local newValue = slot.CreateDate - math.ceil(itemData.durability / 4)
                                        if os.time() - itemData.durability >= newValue then
                                            Inventory.Items:RemoveId(char:GetData("SID"), 1, slot)
                                        else
                                            Inventory:SetItemCreateDate(slot.id, newValue)
                                        end
                                    end
                                    _ammuInUse[v.door] = false
                                end)
                            else
                                Execute:Client(
                                    source,
                                    "Notification",
                                    "Error",
                                    "Someone Else Is Already Using This Door",
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
end