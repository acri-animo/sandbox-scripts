--Hope this works--
local lootSpots = {}
local lootShelves = {}
local pcSpot = false

function BigPharmNeedsReset()
    for _, v in ipairs(_bigPharmDoors) do
        if not Doors:IsLocked(v.door) then
            return true
        end
    end

	local lootDoor = _bigPharmLootDoor[1]
	if lootDoor then
		if not Doors:IsLocked(lootDoor.door) then
			return true
		end
	end

	local entryDoor = _bigPharmEntryDoor[1]
	if entryDoor then
		if not Doors:IsLocked(entryDoor.door) then
			return true
		end
	end

    local desk = _bigPharmDesks[1]
    if desk then
        local deskState = GlobalState[string.format("BigPharm:Offices:PC:%s", desk.data.deskId)]
        if deskState and deskState > GetCloudTimeAsInt() then
            return true
        end
    end

	for _, v in ipairs(_bigPharmLoot) do
		if not lootSpots[v.id] then
			return true
		end
	end
	
	for _, v in ipairs(_bigPharmShelves) do
		if not lootShelves[v.id] then
			return true
		end
	end

    return false
end

AddEventHandler("Robbery:Client:Setup", function()
	Polyzone.Create:Poly("bigpharm", {
		vector2(-3152.0561523438, 1100.8382568359),
		vector2(-3158.2260742188, 1086.5908203125),
		vector2(-3174.4729003906, 1093.89453125),
		vector2(-3168.6748046875, 1108.2385253906)
	}, {
		--debugPoly = true,
	})

	Targeting.Zones:AddBox("BigPharm_secure", "shield-keyhole", vector3(-3157.36, 1097.8, 20.85), 1.0, 1.0, {
		heading = 359,
		--debugPoly = true,
		minZ = 11.8,
		maxZ = 22.05,
	}, {
		{
			icon = "phone",
			text = "Secure Pharmacy",
			event = "Robbery:Client:BigPharm:StartSecuring",
			jobPerms = {
				{
					job = "police",
					reqDuty = true,
				},
			},
			data = {},
			isEnabled = BigPharmNeedsReset,
		},
	}, 3.0, true)

	Targeting.Zones:AddBox("BigPharm_ElectricHack1", "box-taped", vector3(-3167.49, 1097.28, 20.79), 0.8, 1.2, {
		heading = 336,
		--debugPoly = true,
		minZ = 17.69,
		maxZ = 21.69,
	}, {
		{
			icon = "terminal",
			text = "Hack Power Interface",
			item = "adv_electronics_kit",
			event = "Robbery:Client:BigPharm:ElectricBox:Hack",
			data = {
				boxId = 1,
				ptFxPoint = vector3(-3167.49, 1097.28, 20.79),
			},
			isEnabled = function(data, entity)
				return not GlobalState["BigPharm:Secured"]
					and (
						not GlobalState[string.format("BigPharm:Power:%s", 1)]
						or GetCloudTimeAsInt()
							> GlobalState[string.format("BigPharm:Power:%s", 1)]
					)
			end,
		},
	}, 3.0, true)

	Targeting.Zones:AddBox("BigPharm_ElectricHack2", "box-taped", vector3(-3160.17, 1089.37, 20.86), 0.8, 0.6, {
		heading = 336,
		--debugPoly = true,
		minZ = 18.41,
		maxZ = 22.41,
	}, {
		{
			icon = "fire",
			text = "Disable Fuse Box",
			item = "thermite",
			event = "Robbery:Client:BigPharm:ElectricBox:Thermite",
			data = {
				boxId = 2,
				thermitePoint = {
					coords = vector3(-3160.300, 1089.428, 20.855),
					heading = 66.564,
				},
				ptFxPoint = vector3(-3160.300, 1089.428, 20.855),
			},
			isEnabled = function(data, entity)
				return not GlobalState["BigPharm:Secured"]
					and (
						not GlobalState[string.format("BigPharm:Power:%s", 2)]
						or GetCloudTimeAsInt()
							> GlobalState[string.format("BigPharm:Power:%s", 2)]
					)
			end,
		},
	}, 3.0, true)


	Targeting.Zones:AddBox("BigPharm_workstation1", "computer", vector3(-3163.47, 1096.41, 20.93), 0.8, 0.8, {
		heading = 337,
		--debugPoly = true,
		minZ = 17.88,
		maxZ = 21.88,
	}, {
		{
			icon = "terminal",
			text = "Hack Workstation",
			item = "adv_electronics_kit",
			event = "Robbery:Client:BigPharm:PC:Hack",
			data = {
				id = {
					deskId = 1,
				},
			},
			isEnabled = function(data, entity)
				return not GlobalState["BigPharm:Secured"]
					and (
						not GlobalState[string.format("BigPharm:Offices:PC:%s", 1)]
						or GetCloudTimeAsInt()
							> GlobalState[string.format("BigPharm:Offices:PC:%s", 1)]
					)
			end,
		},
	}, 3.0, true)

	for k, v in ipairs(_bigPharmLoot) do
        Targeting.Zones:AddBox("bigpharmloot-" .. k, "syringe", v.coords, v.length, v.width, v.options, {
            {
                icon = "hand-holding-medical",
                text = "Grab Medical Supplies",
                event = "Robbery:Client:BigPharm:FuckWithLoot",
                data = { id = k }
            },
        }, 2.0, true)
    end

	for k, v in ipairs(_bigPharmShelves) do
        Targeting.Zones:AddBox("bigpharmself-" .. k, "prescription-bottle-medical", v.coords, v.length, v.width, v.options, {
            {
                icon = "hand-holding-medical",
                text = "Loot shelf",
                event = "Robbery:Client:BigPharm:LootShelf",
                data = { id = k }
            },
        }, 2.0, true)
    end
end)


AddEventHandler("Characters:Client:Spawn", function()
	BigPharmThreads()
end)


AddEventHandler("Polyzone:Enter", function(id, testedPoint, insideZones, data)
	if id == "bigpharm" then
		LocalPlayer.state:set("inBigPharm", true, true)
	end
end)


AddEventHandler("Polyzone:Exit", function(id, testedPoint, insideZones, data)
	if id == "bigpharm" then
		if LocalPlayer.state.inBigPharm then
			LocalPlayer.state:set("inBigPharm", false, true)
		end
	end
end)


AddEventHandler("Robbery:Client:BigPharm:StartSecuring", function(entity, data)
	Progress:Progress({
		name = "secure_bigpharm",
		duration = 30000,
		label = "Securing Pharmacy",
		useWhileDead = false,
		canCancel = true,
		ignoreModifier = true,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
		animation = {
			anim = "cop3",
		},
	}, function(status)
		if not status then
			Callbacks:ServerCallback("Robbery:BigPharm:SecureBank", {})
		end
	end)
end)


AddEventHandler("Robbery:Client:BigPharm:ElectricBox:Hack", function(entity, data)
	Callbacks:ServerCallback("Robbery:BigPharm:ElectricBox:Hack", data, function() end)
end)


AddEventHandler("Robbery:Client:BigPharm:ElectricBox:Thermite", function(entity, data)
	Callbacks:ServerCallback("Robbery:BigPharm:ElectricBox:Thermite", data, function() end)
end)


AddEventHandler("Robbery:Client:BigPharm:PC:Hack", function(entity, data)
	if pcSpot then
		Notification:Error("You've already looted this lumen...")
		return
	end

	Callbacks:ServerCallback("Robbery:BigPharm:PC:Hack", data, function(lumen) 
		if lumen then
			pcSpot = true
		else
			Notification:Error("Oops, something went wrong.")
		end
	end)
end)

AddEventHandler("Robbery:Client:BigPharm:LootShelf", function(entity, data)
	if lootShelves[data.id] then
		Notification:Error("You've already looted this shelf lumen...")
		return
	end

	Progress:Progress({
		name = "bigpharm_lootshelf",
		duration = math.random(25000, 30000),
		label = "Looting shelf",
		useWhileDead = false,
		canCancel = true,
		ignoreModifier = true,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
		animation = { anim = "parkingmeter" },
	}, function(cancelled)
		if not cancelled then
			lootShelves[data.id] = true
			Callbacks:ServerCallback("Robbery:BigPharm:LootShelf", data, function() end)
		end
	end)
end)


AddEventHandler("Robbery:Client:BigPharm:FuckWithLoot", function(entity, data)
    local lootAnimation = { anim = "medic" }

    if data.id == 2 then
        lootAnimation = { anim = "search" }
    end

	if lootSpots[data.id] then
		Notification:Error("You've already looted this lumen...")
		return
	end

    Progress:Progress({
        name = "bigpharm_lootshit",
        duration = math.random(25000, 30000),
        label = "Looting medical supplies",
        useWhileDead = false,
        canCancel = true,
        ignoreModifier = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = lootAnimation,
    }, function(cancelled)
        if not cancelled then
			lootSpots[data.id] = true
            Callbacks:ServerCallback("Robbery:BigPharm:FuckWithLoot", data, function() end)
        end
    end)
end)

